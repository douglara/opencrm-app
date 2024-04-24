# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accounts::Apps::EvolutionApis::Instance::RefreshStatus, type: :request do
  describe '.call' do
    let(:account) { create(:account) }
    let(:evolution_api) { create(:apps_evolution_api, :connected, account: account) }

    it 'when instance does not exist' do
      stub_request(:get, /connectionState/).with(body: '', headers: evolution_api.request_instance_headers).to_return(
        body: '{"status":404,"error":"Not Found","response":{"message":["The \"9244ecdbda2c251315e6\" instance does not exist"]}}', status: 404, headers: { 'Content-Type' => 'application/json' }
      )
      described_class.new(evolution_api).call
      expect(evolution_api.connection_status).to eq('disconnected')
    end

    it 'when instance is connected' do
      stub_request(:get, /connectionState/).with(body: '', headers: evolution_api.request_instance_headers).to_return(
        body: '{"instance":{"instanceName":"dd7de5acfca04cd65459","state":"open"}}', status: 200, headers: { 'Content-Type' => 'application/json' }
      )
      described_class.new(evolution_api).call
      expect(evolution_api.connection_status).to eq('connected')
    end
  end
end
