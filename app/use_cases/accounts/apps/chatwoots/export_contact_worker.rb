class Accounts::Apps::Chatwoots::ExportContactWorker
  include Sidekiq::Worker
  sidekiq_options queue: :chatwoot_webhooks

  def perform(chatwoot_id, contact_id)
    contact = Contact.find_by_id(contact_id)
    chatwoot = Apps::Chatwoot.find_by_id(chatwoot_id)
    Accounts::Apps::Chatwoots::ExportContact.call(chatwoot, contact) if contact.present? && chatwoot.present?
  end
end
