require 'digest/sha2'
require 'digest/rmd160'

module Util

  COIN = 100_000_000
  CENT =   1_000_000

  NETWORKS = {
      bitcoin: {
          project: :bitcoin,
          address_version: "00",
          p2sh_version: "05"
      }
  }

  def self.int_to_base58(int_val, leading_zero_bytes=0)
    alpha = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    base58_val, base = '', alpha.size
    while int_val > 0
      int_val, remainder = int_val.divmod(base)
      base58_val = alpha[remainder] + base58_val
    end
    base58_val
  end

  def self.base58_to_int(base58_val)
    alpha = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    int_val, base = 0, alpha.size
    base58_val.reverse.each_char.with_index do |char,index|
      raise ArgumentError, 'Value not a valid Base58 String.' unless char_index = alpha.index(char)
      int_val += char_index*(base**index)
    end
    int_val
  end

  def self.decode_base58(base58_val)
    s = base58_to_int(base58_val).to_s(16); s = (s.bytesize.odd? ? '0'+s : s)
    s = '' if s == '00'
    leading_zero_bytes = (base58_val.match(/^([1]+)/) ? $1 : '').size
    s = ("00"*leading_zero_bytes) + s  if leading_zero_bytes > 0
    s
  end

  def self.base58_checksum?(base58)
    hex = decode_base58(base58) rescue nil
    return false unless hex
    checksum( hex[0...42] ) == hex[-8..-1]
  end

  def self.checksum(hex)
    b = [hex].pack("H*") # unpack hex
    Digest::SHA256.hexdigest( Digest::SHA256.digest(b) )[0...8]
  end

  def network
    @network_options ||= NETWORKS[:bitcoin].dup
  end

end