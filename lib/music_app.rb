# frozen_string_literal: true

# MusicApp provides a simple wrapper for the Appscript
#   representation of Music.app and the current track
module MusicApp
  require 'rb-scpt'
  include Appscript

  MUSIC_APP_NAME = 'Music'

  # the Player class holds the reference to the current track
  class Player
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

      @current_track ||= app(MUSIC_APP_NAME).current_track
    end

    def static_track
      return unless current_track

      Track.new(@current_track.name.get, @current_track.artist.get, @current_track.album.get)
    end
  end

  # standard format for track info
  class Track
    attr_reader :name, :title, :artist, :album, :time

    def initialize(title, artist, album, time = Time.now.getutc)
      @name = @title = title
      @artist = artist
      @album = album
      @time = time
    end
  end
end
