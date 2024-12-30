require 'rails_helper'

RSpec.describe Accounts::Apps::Chatwoots::FindOrCreateConversation, type: :request do
  describe 'success' do
    let(:account) { create(:account) }
    let(:chatwoot) { create(:apps_chatwoots, :skip_validate) }
    let(:conversation_response) do
      File.read('spec/integration/use_cases/accounts/apps/chatwoots/get_conversations.json')
    end
    let(:create_conversation_response) do
      File.read('spec/integration/use_cases/accounts/apps/chatwoots/create_conversation.json')
    end

    it 'should have conversation' do
      stub_request(:get, /conversations/)
        .to_return(body: conversation_response, status: 200, headers: { 'Content-Type' => 'application/json' })

      result = Accounts::Apps::Chatwoots::FindOrCreateConversation.call(chatwoot, 2, 2)
      expect(result[:ok]['id']).to eq(2)
    end

    it 'should create conversation' do
      stub_request(:post, /conversations/)
        .to_return(body: create_conversation_response, status: 200, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, /conversations/)
        .to_return(body: { payload: [] }.to_json, status: 200, headers: { 'Content-Type' => 'application/json' })

      result = Accounts::Apps::Chatwoots::FindOrCreateConversation.call(chatwoot, 2, 2)
      expect(result[:ok]['id']).to eq(10)
    end
  end
end
