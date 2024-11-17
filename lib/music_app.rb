# frozen_string_literal: true

# Provides a simple wrapper for the Appscript
# representation of Music.app and its current track
module MusicApp
  require 'rb-scpt'
  include Appscript

  MUSIC_APP_NAME = 'Music'

  # Maintains an Appscript reference to the track currently playing
  class MusicPlayer
    def initialize
      @current_track = nil
    end

    def running?
      Appscript.app(MUSIC_APP_NAME).is_running?
    end

    def playing?
      running? && Appscript.app(MUSIC_APP_NAME).player_state.get == :playing
    end

    def current_track
      return unless playing?

      @current_track ||= Appscript.app(MUSIC_APP_NAME).current_track
    end

    def static_track
      return unless current_track

      Track.new(@current_track.name.get, @current_track.artist.get, @current_track.album.get)
    end
  end

  # Defines a standard format for track info
  class Track
    attr_reader :name, :title, :artist, :album, :time
    attr_accessor :sent

    def initialize(title, artist, album, time = Time.now.getutc)
      @name = @title = title
      @artist = artist
      @album = album
      @time = time
      @sent = false
    end

    def equals(track)
      !track.nil? && track&.name == @name && track&.artist == @artist && track&.album == @album
    end

    alias == equals

    def to_s
      "#{@name} - #{@artist} (#{@album}) #{@sent ? '[sent]' : ''}"
    end
  end
end
