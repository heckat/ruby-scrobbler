# frozen_string_literal: true

# manage connection to Lastfm
class LastfmService
  require 'lastfm'
  require_relative './encryption'
  require_relative './scrobbler_database'
  require_relative './scrobbler_database_interface'
  include Encryption
  include ScrobblerDatabase
  include ScrobblerDatabaseInterface

  attr_reader :db, :lastfm

  def initialize
    @db = DatabaseConnection.new
    @local_password = nil
    @lastfm = nil
  end

  def load_api_user
    return unless @local_password

    api_info = @db.select_user(API_KEY_TYPE)
    return unless api_info

    secret = decode_decrypt(@local_password, api_info['salt'], api_info['session_key'])
    @lastfm = Lastfm.new(api_info['username'], secret)
  end

  def load_user
    return unless @lastfm

    user_info = @db.select_user
    return unless user_info

    secret = decode_decrypt(@local_password, user_info['salt'], user_info['session_key'])
    @lastfm.session = secret
  end

  def get_input(prompt = '', is_secret: true)
    input = nil
    while input.nil? || input.empty?
      print "#{prompt} "
      input = is_secret ? $stdin.getpass.chomp : $stdin.gets.chomp
    end
    input
  end

  def set_local_password
    password1 = get_input('Enter password for local encryption:', is_secret: true)
    password2 = get_input('Re-enter password for local encryption:', is_secret: true)
    if password2 == password1
      @local_password = password1
      puts 'Local password set.'
    else
      puts 'Make sure to enter the same password twice.'
    end
  end

  def get_credentials(name_prompt, pass_prompt)
    name = get_input("Enter #{name_prompt}:", is_secret: false)
    pass = get_input("Enter #{pass_prompt}:", is_secret: true)
    [name, pass]
  end

  def api_auth(salt = DEFAULT_SALT)
    api_key, api_secret = get_credentials('api key', 'api secret')
    return unless (@lastfm = Lastfm.new(api_key, api_secret))

    encrypted_secret = encrypt_encode(@local_password, salt, api_secret)
    timestamp = Time.now.getutc.strftime('%Y-%m-%d %H:%M:%S')
    @db.insert_user(
      { username: api_key, session_key: encrypted_secret, salt: salt,
        type: API_KEY_TYPE, datetime_obtained: timestamp, status: AUTH_ACTIVE }
    )
  end

  def user_auth(salt = DEFAULT_SALT)
    return unless @lastfm

    username, password = get_credentials('username', 'password')
    return unless (session = @lastfm.auth.get_mobile_session(username: username, password: password))

    @lastfm.session = session['key']
    encrypted_secret = encrypt_encode(@local_password, salt, session['key'])
    timestamp = Time.now.getutc.strftime('%Y-%m-%d %H:%M:%S')
    @db.insert_user(
      { username: username, session_key: encrypted_secret, salt: salt,
        type: USER_TYPE, datetime_obtained: timestamp, status: AUTH_ACTIVE }
    )
  end

  def scrobble(track)
    return unless @lastfm&.session && track.name && track.artist

    scrobble_status = @lastfm.track.scrobble(
      track: track.name,
      artist: track.artist,
      album: track.album,
      timestamp: track.time.strftime('%s')
    )
    status = scrobble_status ? SEND_SUCCESS : SEND_ERROR_TEMP
    @db.insert_track(track.name, track.artist, track.album, track.time.strftime('%Y-%m-%d %H:%M:%S'), status)
  end
end
