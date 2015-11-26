require 'spec_helper'

describe RubyBitcoinWallet do
  class Wallet
  end

  before(:all) do
    @wallet = Wallet.new
    @wallet.extend RubyBitcoinWallet
  end

  describe 'Creating keys and address' do
    let(:keys) { @wallet.generate_key }
    let(:address) { @wallet.pubkey_to_address(keys[1]) }

    it 'generate_key returns valid strings' do
      expect(keys[0]).to be_a_kind_of(String)
      expect(keys[1]).to be_a_kind_of(String)
    end

    it 'creates address from public key' do
      expect(address).to be_a_kind_of(String)
      expect(address[0]).to eq('1').or eq('3')
    end

    it 'checks address validity' do
      expect(@wallet.valid_address?(address)).to be(true)
    end
  end

  describe 'Return blockchain data' do
    context 'with valid address' do
      let(:valid_address) { '1HawYer58J9Vy3iju1w7jsRVci5tzaxkwn' }

      it 'returns address balance' do
        balance = @wallet.address_balance(valid_address)
        expect(balance[:final_balance]).to be_a_kind_of(Integer)
        expect(balance[:total_received]).to be_a_kind_of(Integer)
        expect(balance[:total_sent]).to be_a_kind_of(Integer)
      end

      it 'returns array of address transactions' do
        transactions = @wallet.address_transactions(valid_address)
        expect(transactions).to be_a_kind_of(Array)
        expect(transactions.first['hash']).to be_a_kind_of(String)
        expect(transactions.first['block_height']).to be_a_kind_of(Integer)
      end
    end

    context 'with invalid address' do
      let(:invalid_address) { '2566358J9Vy3iju1w7jsRVci5tzaxkwn' }

      it 'returns invalid address message for balance' do
        balance = @wallet.address_balance(invalid_address)
        expect(balance).to eq("No data registered for address #{invalid_address}")
      end

      it 'returns invalid address message for transactions' do
        transactions = @wallet.address_transactions(invalid_address)
        expect(transactions).to eq("No data registered for address #{invalid_address}")
      end
    end
  end
end