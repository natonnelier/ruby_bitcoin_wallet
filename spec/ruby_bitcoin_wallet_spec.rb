require 'spec_helper'

describe RubyBitcoinWallet do
  subject { RubyBitcoinWallet.new }

  describe '#process' do
    let(:input) { 'My input.' }
    let(:output) { subject.process(input) }

    it 'creates private and public keys' do
      # expect(output.downcase).to eq output
    end

    it 'creates address' do
      # expect(output).to match /so grandmom./i
      # expect(output).to match /such sweater./i
      # expect(output).to match /very christmas./i
    end

    it 'returns error message' do
      # expect(output).to end_with 'wow.'
    end
  end
end