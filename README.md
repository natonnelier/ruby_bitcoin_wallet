# RubyBitcoinWallet

Ruby Bitcoin Wallet includes a set of ruby methods that, following Bitcoin's protocol, manage
the creation of valid private and public keys and addresses. Also, making use of coinbase API,
it provides direct interaction with the Bitcoin blockchain, allowing the checking of address balances
and transactions, search for a specific transactions or directly create one.

## Installation

Add this line to your application's Gemfile:

    gem 'ruby_bitcoin_wallet'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_bitcoin_wallet

## Usage

Create public and private key's hash:

keys = RubyBitcoinWallet::generate_key

Generate Address:

address = RubyBitcoinWallet::pubkey_to_address(keys[1])

Check if address is valid:

RubyBitcoinWallet::valid_address?(address)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ruby_bitcoin_wallet/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
