class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  validates :name,                 presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,                presence: true, length: { maximum: 255 },
                                   format: { with: VALID_EMAIL_REGEX },
                                   uniqueness: true 
  validates :date_of_birth,        presence: true
  #validates :has_muggle_relatives, presence: true, :inclusion => {:in => %w(true, false)}
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

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  #Returns a random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?    
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end  
end
