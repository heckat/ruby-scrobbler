# frozen_string_literal: true

require 'minitest/autorun'
require 'securerandom'
require_relative '../lib/scrobbler_database_interface'
require_relative '../lib/scrobbler_database'

# TODO: why does this no longer work inside the class
include ScrobblerDatabase
include ScrobblerDatabaseSetup

# TestScrobblerDatabaseInterface tests that interface methods insert and select as expected
class TestScrobblerDatabaseInterface < Minitest::Test
  def setup
    @filename = "/tmp/test-scrobbler-database-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}-#{SecureRandom.uuid}.sqlite3"
    @db = ScrobblerDatabaseInterface::DatabaseConnection.new(@filename)
    @db.conn.results_as_hash = true
    @title = "I'm Not A Patriot But"
    @artist = 'Wat Tyler'
    @album = 'Diamond Life'
    @status = ScrobblerDatabase::READY_TO_SEND
    @timestamp = Time.now.getutc.strftime('%Y-%m-%d %H:%M:%S')
    @user_metadata = {
      type: ScrobblerDatabase::USER_TYPE,
      datetime_obtained: @timestamp,
      status: ScrobblerDatabase::AUTH_ACTIVE
    }
    @user_credentials = { username: 'test_nobody_user', session_key: 'test_nobody_key', salt: 'abcd1234' }
  end

  def test_track_insert
    @db.conn.transaction(:immediate)
    @db.insert_track(@title, @artist, @album, @timestamp, @status)
    row = @db.conn.get_first_row('SELECT * FROM track')
    @db.conn.commit
    assert_equal @title, row['title']
    assert_equal @artist, row['artist']
    assert_equal @album, row['album']
    assert_equal @timestamp, row['timestamp']
    assert_equal @status, row['status']
  end

  # avoid "Method has too many lines" and "Assignment Branch Condition size is too high"
  # complaints from ruby cop when values are assigned to variables
  def test_user_insert
    @db.conn.transaction(:immediate)
    @db.insert_user(credentials: @user_credentials, metadata: @user_metadata)
    row = @db.conn.get_first_row('SELECT * FROM user')
    @db.conn.commit
    assert_equal @user_metadata[:type], row['type']
    assert_equal @timestamp, row['datetime_obtained']
    assert_equal @user_metadata[:type], row['status']
    assert_equal @user_credentials[:username], row['username']
    assert_equal @user_credentials[:session_key], row['session_key']
    assert_equal @user_credentials[:salt], row['salt']
  end

  # avoid "Method has too many lines" and "Assignment Branch Condition size is too high"
  # complaints from ruby cop when values are assigned to variables
  def test_error_insert
    @db.conn.transaction(:immediate)
    @db.insert_error(42, @timestamp, 29, 'Rate limit exceeded')
    row = @db.conn.get_first_row('SELECT * FROM error')
    @db.conn.commit
    assert_equal 42, row['track_id']
    assert_equal @timestamp, row['timestamp']
    assert_equal 29, row['code']
    assert_equal 'Rate limit exceeded', row['name']
  end

  def test_track_select
    @db.conn.transaction(:immediate)
    @db.insert_track(@title, @artist, @album, @timestamp, @status)
    result = @db.track_ready_to_send
    row = result.first
    @db.conn.commit
    refute_nil row
    assert_equal @title, row['title']
    assert_equal @artist, row['artist']
    assert_equal @album, row['album']
    assert_equal @status, row['status']
  end
end
