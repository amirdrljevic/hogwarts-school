class User < ApplicationRecord
  before_save { self.email = email.downcase }
  validates :name,                 presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,                presence: true, length: { maximum: 255 },
                                   format: { with: VALID_EMAIL_REGEX },
                                   uniqueness: true 
  validates :date_of_birth,        presence: true
  validates :has_muggle_relatives, presence: true
  has_secure_password

  PASSWORD_FORMAT = /\A
  (?=.{8,})          # Must contain 8 or more characters
  (?=.*\d)           # Must contain a digit
  (?=.*[a-z])        # Must contain a lower case character
  (?=.*[A-Z])        # Must contain an upper case character
  (?=.*[[:^alnum:]]) # Must contain a symbol
/x

validates :password, 
  presence: true, 
  length: { minimum: 8 }, 
  format: { with: PASSWORD_FORMAT }, 
  confirmation: true, 
  on: :create 

validates :password, 
  allow_nil: true, 
  length: { minimum: 8 }, 
  format: { with: PASSWORD_FORMAT }, 
  confirmation: true, 
  on: :update

  #validates :password, presence: true, length: { minimum: 8 }
end
