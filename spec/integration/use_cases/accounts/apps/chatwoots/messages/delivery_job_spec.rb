require 'rails_helper'

RSpec.describe Accounts::Apps::Chatwoots::Messages::DeliveryJob, type: :request do
  describe 'success' do
    let(:account) { create(:account) }
    let(:chatwoot) { create(:apps_chatwoots, :skip_validate) }
    let(:contact) { create(:contact, account:, additional_attributes: { chatwoot_id: 2 }) }
    let(:event) do
      create(:event, app: chatwoot, account:, contact:, content: 'Hi Lorena', from_me: true, scheduled_at: Time.now,
                     kind: 'chatwoot_message', additional_attributes: { chatwoot_inbox_id: 2 })
    end

    let(:conversation_response) do
      File.read('spec/integration/use_cases/accounts/apps/chatwoots/get_conversations.json')
    end
    let(:message_response) { File.read('spec/integration/use_cases/accounts/apps/chatwoots/send_message.json') }

    it do
      stub_request(:get, /conversations/)
        .to_return(body: conversation_response, status: 200, headers: { 'Content-Type' => 'application/json' })
      stub_request(:post, /messages/)
        .to_return(body: message_response, status: 200, headers: { 'Content-Type' => 'application/json' })

      result = described_class.perform_now(event.id)

      expect(result[:ok].additional_attributes['chatwoot_id']).to eq(227)
    end
  end
end
