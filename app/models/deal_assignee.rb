class DealAssignee < ApplicationRecord
  belongs_to :deal
  belongs_to :user

  validates :user_id, uniqueness: { scope: :deal_id, message: :taken }
end
