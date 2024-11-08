# frozen_string_literal: true

# provide simple methods for encryption and decryption
module Encryption
  require 'openssl'
  require 'digest/sha1'
  require 'base64'

  def encrypt_encode(key, salt, plaintext)
    encryptor = OpenSSL::Cipher.new('aes-256-cbc')
    encryptor.encrypt
    encryptor.pkcs5_keyivgen(key, salt)
    encrypted = encryptor.update(plaintext)
    encrypted << encryptor.final
    Base64.strict_encode64(encrypted.to_s)
  end

  def decode_decrypt(key, salt, encoded)
    encrypted = Base64.strict_decode64(encoded)
    decryptor = OpenSSL::Cipher.new('aes-256-cbc')
    decryptor.decrypt
    decryptor.pkcs5_keyivgen(key, salt)
    plaintext = decryptor.update(encrypted)
    plaintext << decryptor.final
    plaintext.to_s
  end
end
