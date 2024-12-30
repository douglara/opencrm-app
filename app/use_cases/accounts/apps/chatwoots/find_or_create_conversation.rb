class Accounts::Apps::Chatwoots::FindOrCreateConversation
  def self.call(chatwoot, contact_id, inbox_id)
    conversations = Accounts::Apps::Chatwoots::GetConversations.call(
      chatwoot, contact_id, inbox_id
    )

    return { ok: conversations.dig(:ok, 0) } if conversations.dig(:ok, 0, 'id').present?

    Accounts::Apps::Chatwoots::CreateConversation.call(
      chatwoot, contact_id, inbox_id
    )
  end
end
