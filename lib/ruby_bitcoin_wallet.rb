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
          min_tx_fee: 10_000,
          min_relay_tx_fee: 10_000,
          free_tx_bytes: 1_000,
          dust: CENT,
          per_dust_fee: false,
          dns_seeds: [
              "seed.bitcoin.sipa.be",
              "dnsseed.bluematt.me",
              "dnsseed.bitcoin.dashjr.org",
              "bitseed.xf2.org",
              "dnsseed.webbtc.com",
          ],
          genesis_hash: "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
          proof_of_work_limit: 0x1d00ffff,
          alert_pubkeys: ["04fc9702847840aaf195de8442ebecedf5b095cdbb9bc716bda9110971b28a49e0ead8564ff0db22209e0374782c093bb899692d524e9d6a6956e7c5ecbcd68284"],
          known_nodes: [
              'relay.eligius.st',
              'mining.bitcoin.cz',
              'blockchain.info',
              'blockexplorer.com',
              'webbtc.com',
          ],
          checkpoints: {
              11111 => "0000000069e244f73d78e8fd29ba2fd2ed618bd6fa2ee92559f542fdb26e7c1d",
              33333 => "000000002dd5588a74784eaa7ab0507a18ad16a236e7b1ce69f00d7ddfb5d0a6",
              74000 => "0000000000573993a3c9e41ce34471c079dcf5f52a0e824a81e7f953b8661a20",
              105000 => "00000000000291ce28027faea320c8d2b054b2e0fe44a773f3eefb151d6bdc97",
              134444 => "00000000000005b12ffd4cd315cd34ffd4a594f430ac814c91184a0d42d2b0fe",
              168000 => "000000000000099e61ea72015e79632f216fe6cb33d7899acb35b75c8303b763",
              193000 => "000000000000059f452a5f7340de6682a977387c17010ff6e6c3bd83ca8b1317",
              210000 => "000000000000048b95347e83192f69cf0366076336c639f9b7228e9ba171342e",
              216116 => "00000000000001b4f4b433e81ee46494af945cf96014816a4e2370f11b23df4e",
              225430 => "00000000000001c108384350f74090433e7fcf79a606b8e797f065b130575932",
              290000 => "0000000000000000fa0b2badd05db0178623ebf8dd081fe7eb874c26e27d0b3b",
              300000 => "000000000000000082ccf8f1557c5d40b21edabb18d2d691cfbf87118bac7254",
              305000 => "0000000000000000142bb90561e1a907d500bf534a6727a63a92af5b6abc6160",
          }
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
    address_balance_and_txs['final_balance']
  end

  def address_transactions(address)
    address_balance_and_txs = balance_and_transactions(address)
    return address_balance_and_txs unless address_balance_and_txs['txs']
    address_balance_and_txs['txs']
  end

  def address_version; NETWORKS[:bitcoin][:address_version]; end
  def p2sh_version; NETWORKS[:bitcoin][:p2sh_version]; end

end
