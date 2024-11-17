Gem::Specification.new do |s|
  s.name     = "ruby_scrobbler"
  s.version  = "0.0.0"
  s.summary  = "Last.fm music scrobbling utility"
  s.authors  = "heckat"
  s.files    = [
                "lib/ruby_scrobbler.rb",
                "lib/encryption.rb",
                "lib/lastfm_service.rb",
                "lib/music_app.rb",
                "lib/scrobbler_database.rb",
                "lib/scrobbler_database_interface.rb",
                "lib/scrobbler_database_setup.rb"
               ]
  s.homepage = "http://127.0.0.1/"
end
