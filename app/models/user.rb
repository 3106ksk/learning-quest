class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :study_records, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email_address, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
end
