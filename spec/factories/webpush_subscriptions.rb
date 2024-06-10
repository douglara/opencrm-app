# == Schema Information
#
# Table name: webpush_subscriptions
#
#  id         :bigint           not null, primary key
#  auth_key   :string           default(""), not null
#  endpoint   :string           default(""), not null
#  p256dh_key :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_webpush_subscriptions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :webpush_subscription do
    user
    endpoint { Faker::Internet.url }
    auth_key { Faker::Crypto.sha256 }
    p256dh_key { Faker::Crypto.sha1 }
  end
end
