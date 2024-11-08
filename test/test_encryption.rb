# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/encryption'

# Encryption unit tests
class TestEncryption < Minitest::Test
  include Encryption

  def setup
    @key = 'All Things Must Password'
    @salt = 'Na1000mg'
    @plaintext = 'Comment te dire adieu?'
    @encrypted = '8g5Fvj1tqkCLesLJt24Npbq/MKLEuILfuZxFuWSshNQ='
  end

  def test_encrypt
    encrypted = encrypt_encode(@key, @salt, @plaintext)
    assert_equal @encrypted, encrypted
  end

  def test_decrypt
    assert_equal @plaintext, decode_decrypt(@key, @salt, @encrypted)
  end

  def test_encrypt_decrypt
    plaintext = 'The Invisible Line'
    encrypted = encrypt_encode(@key, @salt, plaintext)
    assert_equal plaintext, decode_decrypt(@key, @salt, encrypted)
  end
end
