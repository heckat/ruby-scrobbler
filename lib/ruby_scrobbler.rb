# frozen_string_literal: true

# RubyScrobbler app
class RubyScrobbler
  require_relative './music_app'
  require_relative './lastfm_service'
  include MusicApp

  DEFAULT_INTERVAL = 30

  attr_reader :player, :lastfm

  def initialize
    @player = MusicPlayer.new
    @lastfm = LastfmService.new
    @track_playing = nil
    @key = ''
  end

  def formatted_time
    Time.now.getutc.strftime('%Y-%m-%d %H:%M:%S')
  end

  def try_to_read(io, timeout, break_time)
    @key = io.read_nonblock(1)&.downcase if Time.now.getutc.to_i < break_time
  rescue IO::WaitReadable
    sleep timeout * 0.1
    retry
  rescue StandardError => e
    puts "try_to_read(): #{e.class} (#{e.message})"
    @key ||= ''
    sleep timeout * 0.1 while Time.now.getutc.to_i < break_time
  end

  def get_key(timeout = 1)
    @key = ''
    source = $stdin
    break_time = Time.now.getutc.to_i + timeout
    source.raw(time: 1, intr: true) do |io|
      io.flush
      io.echo = false
      try_to_read(io, timeout, break_time)
      io.echo = true
    end
  end

  def possibly_scrobble
    track_now = @player.static_track
    if @track_playing.nil? || @track_playing != track_now
      @track_playing = track_now
    elsif !@track_playing.sent
      puts "#{formatted_time} Sending: #{@track_playing}"
      @track_playing.sent = true
      lastfm.scrobble(@track_playing)
    end
  end

  def handle_key
    case @key
    when 'f'
      possibly_scrobble
    when 't'
      puts "#{formatted_time} Playing: #{@track_playing}"
    end
  end

  def listen(interval = DEFAULT_INTERVAL)
    while @key != 'q'
      possibly_scrobble

      (1..interval).each do |_|
        get_key
        handle_key
        break if @key == 'q'
      end
    end
    @key = ''
  end
end
