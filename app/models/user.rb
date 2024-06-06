# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  full_name              :string           default(""), not null
#  language               :string           default("en"), not null
#  phone                  :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  accepts_nested_attributes_for :account
  
  attribute :language, :string, default: ENV.fetch('LANGUAGE', 'en')
  
  validates :phone,
            allow_blank: true,
            format: { with: /\+[1-9]\d{1,14}\z/ }

  after_update_commit do
    broadcast_replace_later_to "users_#{account_id}", target: self, partial: '/accounts/users/user',
                                                      locals: { user: self }
  end

  after_create_commit do
    broadcast_append_later_to "users_#{account_id}", target: 'users', partial: '/accounts/users/user',
                                                     locals: { user: self }
  end

  after_destroy_commit do
    broadcast_remove_to "users_#{account_id}", target: self
  end

  def get_jwt_token
    Users::JsonWebToken.encode_user(self)
  end
end
