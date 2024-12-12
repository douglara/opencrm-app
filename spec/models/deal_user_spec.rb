# == Schema Information
#
# Table name: deal_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deal_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_deal_users_on_deal_id  (deal_id)
#  index_deal_users_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (deal_id => deals.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe DealUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
