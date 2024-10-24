# frozen_string_literal: true

# SQL to create tables
module ScrobblerDatabaseSetup
  def track_table_sql
    <<~SQL
      CREATE TABLE IF NOT EXISTS track (
        id INTEGER PRIMARY KEY,
        title TEXT,
        artist TEXT,
        album TEXT,
        timestamp TEXT,
        status INTEGER  --ENUM: READY_TO_SEND, SEND_SUCCESS, SEND_IGNORED, SEND_ERROR_TEMP, SEND_ERROR_PERM
      );
    SQL
  end

  def track_index_sql
    <<~SQL
      CREATE INDEX IF NOT EXISTS index_track_status_time ON track (
        status,
        unixepoch(timestamp)
      )
    SQL
  end

  def user_table_sql
    <<~SQL
      CREATE TABLE IF NOT EXISTS user (
        id INTEGER PRIMARY KEY,
        type INTEGER,  --ENUM: API_KEY, USER
        username TEXT,
        session_key TEXT,
        salt TEXT,
        datetime_obtained TEXT,
        status INTEGER
      )
    SQL
  end

  def error_table_sql
    <<~SQL
      CREATE TABLE IF NOT EXISTS error (
        id INTEGER PRIMARY KEY,
        track_id INTEGER,
        timestamp TEXT,
        code INTEGER,
        name TEXT
      )
    SQL
  end
end
