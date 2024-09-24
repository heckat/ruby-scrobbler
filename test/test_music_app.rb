# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/music_app'

class TestMusicApp < Minitest::Test
  describe 'if Music.app is not running before request' do
    it 'should not be running after request' do
      unless Appscript.app(MusicApp::MUSIC_APP_NAME).is_running?
        MusicApp::Player.new.current_track
        refute Appscript.app(MusicApp::MUSIC_APP_NAME).is_running?
      end
    end
  end
end
