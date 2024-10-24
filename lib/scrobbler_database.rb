# frozen_string_literal: true

# SQL to insert and select records
module ScrobblerDatabase
  # track.status enum:
  READY_TO_SEND = 0
  SEND_SUCCESS = 1
  SEND_IGNORED = 2
  SEND_ERROR_TEMP = 3
  SEND_ERROR_PERM = 4

  # user.type enum:
  API_KEY_TYPE = 0
  USER_TYPE = 1

  # user.status enum:
  AUTH_FAILED = 0
  AUTH_ACTIVE = 1

  def insert_track_sql
    <<~SQL
      INSERT INTO track (
        title,
        artist,
        album,
        timestamp,
        status
      ) VALUES (?, ?, ?, ?, ?)
    SQL
  end

  def insert_user_sql
    <<~SQL
      INSERT INTO user (
        type,
        username,
        session_key,
        salt,
        datetime_obtained,
        status
      ) VALUES (?, ?, ?, ?, ?, ?)
    SQL
  end

  def insert_error_sql
    <<~SQL
      INSERT INTO error (
        track_id,
        timestamp,
        code,
        name
      ) VALUES (?, ?, ?, ?)
    SQL
  end

  def select_track_to_send_sql
    <<~SQL
      SELECT
        id,
        title,
        artist,
        album,
        timestamp,
        status
      FROM track
      WHERE unixepoch(timestamp) > unixepoch(?)
        AND status IN (#{READY_TO_SEND}, #{SEND_ERROR_TEMP})
      LIMIT ?
    SQL
  end

  def select_track_by_date_sql
    <<~SQL
      SELECT
        id,
        title,
        artist,
        album,
        timestamp,
        status
      FROM track
      WHERE unixepoch(timestamp)
        BETWEEN unixepoch(?) AND unixepoch(?)
      LIMIT ?
    SQL
  end
end
