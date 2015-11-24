require "ruby_bitcoin_wallet/version"

require 'openssl'
require 'ruby_bitcoin_wallet/util'
require 'ruby_bitcoin_wallet/open_ssl'
require 'ruby_bitcoin_wallet/api_service'

module RubyBitcoinWallet

  COIN = 100_000_000
  CENT =   1_000_000

  NETWORKS = {
      bitcoin: {
          project: :bitcoin,
          magic_head: "\xF9\xBE\xB4\xD9",
          address_version: "00",
          p2sh_version: "05",
          privkey_version: "80",
          default_port: 8333,
          protocol_version: 70001,
          coinbase_maturity: 100,
          reward_base: 50 * COIN,
          reward_halving: 210_000,
          retarget_interval: 2016,
          retarget_time: 1209600, # 2 weeks
          target_spacing: 600, # block interval
          max_money: 21_000_000 * COIN,
          min_tx_fee: 10_000
      }
  }

  def bitcoin_elliptic_curve
    ::OpenSSL::PKey::EC.new("secp256k1")
  end

  def generate_key
    key = bitcoin_elliptic_curve.generate_key
    inspect_key( key )
  end

  def inspect_key(key)
    [ key.private_key_hex, key.public_key_hex ]
  end

  def pubkey_to_address(pubkey, type = :pubkey_hash)
    hash160_to_address( hash160(pubkey) )
  end

  def hash160_to_address(hex)
    encode_address hex, address_version
  end

  def encode_address(hex, version)
    hex = version + hex
    encode_base58(hex + checksum(hex))
  end

  def network
    @network_options ||= NETWORKS[:bitcoin].dup
  end

  def encode_base58(hex)
    leading_zero_bytes  = (hex.match(/^([0]+)/) ? $1 : '').size / 2
    ("1"*leading_zero_bytes) + Util.int_to_base58( hex.to_i(16) )
  end

  def checksum(hex)
    b = [hex].pack("H*") # unpack hex
    Digest::SHA256.hexdigest( Digest::SHA256.digest(b) )[0...8]
  end

  def hash160(hex)
    bytes = [hex].pack("H*")
    Digest::RMD160.hexdigest Digest::SHA256.digest(bytes)
  end

  def network=(name)
    raise "Network descriptor '#{name}' not found."  unless NETWORKS[name.to_sym]
    @network_options = nil # clear cached parameters
    @network = name.to_sym
    @network_project = network[:project] rescue nil
    Dogecoin.load  if dogecoin? || dogecoin_testnet?
    Namecoin.load  if namecoin? && defined?(Namecoin)
    @network
  end

  def valid_address?(address)
    hex = Util.decode_base58(address) rescue nil
    return false unless hex && hex.bytesize == 50
    return false unless [address_version, p2sh_version].include?(hex[0...2])
    Util.base58_checksum?(address)
  end

  def balance_and_transactions(address)
    ApiService.address_balance_and_transactions(address)
  end

  def address_balance(address)
    address_balance_and_txs = balance_and_transactions(address)
    return address_balance_and_txs unless address_balance_and_txs['final_balance']
    address_balance_hash = {
        final_balance: address_balance_and_txs['final_balance'],
        total_received: address_balance_and_txs['total_received'],
        total_sent: address_balance_and_txs['total_sent']
    }
  end

  def address_transactions(address)
    address_balance_and_txs = balance_and_transactions(address)
    return address_balance_and_txs unless address_balance_and_txs['txs']
    address_balance_and_txs['txs']
  end

  def address_version; NETWORKS[:bitcoin][:address_version]; end
  def p2sh_version; NETWORKS[:bitcoin][:p2sh_version]; end

end
