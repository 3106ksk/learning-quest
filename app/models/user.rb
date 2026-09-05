class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable

  has_many :sessions, dependent: :destroy
  has_many :study_records, dependent: :destroy

  validates :account_name, presence: true, length: { maximum: 50 }
  validates :email, length: { maximum: 255 }
end
