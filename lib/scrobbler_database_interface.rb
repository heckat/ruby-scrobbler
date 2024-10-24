# frozen_string_literal: true

# ScrobblerDatabaseInterface provides structured interface to SQLite database
module ScrobblerDatabaseInterface
  require 'sqlite3'
  require_relative './scrobbler_database'
  require_relative './scrobbler_database_setup'
  include ScrobblerDatabase
  include ScrobblerDatabaseSetup

  DATABASE_FILENAME = "#{Dir.home}/Library/Application Support/ruby-scrobbler/scrobbler.sqlite3"
  SECONDS_PER_DAY = 86_400

  # DatabaseConnection manages database connection object
  class DatabaseConnection
    attr_reader :conn, :connection,
                :prepared_insert_track, :prepared_insert_user, :prepared_insert_error,
                :prepared_select_track_to_send, :prepared_select_track_by_date

    def initialize(db_filename = DATABASE_FILENAME)
      @conn = @connection = database_ready(db_filename)
      prepare_statements
    end

    def insert_track(title, artist, album, timestamp, status)
      @prepared_insert_track.execute(title, artist, album, timestamp, status)
    end

    def insert_user(credentials: {}, metadata: {})
      @prepared_insert_user.execute(
        metadata[:type],
        credentials[:username],
        credentials[:session_key],
        credentials[:salt],
        metadata[:datetime_obtained],
        metadata[:status]
      )
    end

    def insert_error(track_id, timestamp, code, name)
      @prepared_insert_error.execute(track_id, timestamp, code, name)
    end

    def track_ready_to_send
      timestamp = (Time.now.getutc - SECONDS_PER_DAY).strftime('%Y-%m-%d %H:%M:%S')
      @prepared_select_track_to_send.execute(timestamp, 10)
    end

    def track_by_date(
      start_time: Time.now.getutc.strftime('%s') - SECONDS_PER_DAY,
      end_time: Time.now.getutc.strftime('%s'),
      limit: 10
    )
      @prepared_select_track_by_date.execute(start_time, end_time, limit)
    end

    def database_ready(db_filename)
      db_dirname = File.dirname(db_filename)
      Dir.exist?(db_dirname) || Dir.mkdir(db_dirname, 0o755)
      conn = SQLite3::Database.new(db_filename)
      conn.execute(track_table_sql)
      conn.execute(track_index_sql)
      conn.execute(user_table_sql)
      conn.execute(error_table_sql)
      conn.results_as_hash = true
      conn
    end

    def prepare_statements
      @prepared_insert_track = @conn.prepare(insert_track_sql)
      @prepared_insert_user = @conn.prepare(insert_user_sql)
      @prepared_insert_error = @conn.prepare(insert_error_sql)
      @prepared_select_track_to_send = @conn.prepare(select_track_to_send_sql)
      @prepared_select_track_by_date = @conn.prepare(select_track_by_date_sql)
    end
  end
end