class User < ApplicationRecord
  has_many :spells, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed                                  
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token, :skip_this_for_dumbledore
  before_save :downcase_email
  
  before_create :assign_house 
  before_create :create_activation_digest
  validates :name,                 presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,                presence: true, length: { maximum: 255 },
                                   format: { with: VALID_EMAIL_REGEX },
                                   uniqueness: true 
  validates :date_of_birth,        presence: true
  #validates :has_muggle_relatives, presence: true, :inclusion => {:in => %w(true, false)}
  has_secure_password

PASSWORD_FORMAT_DIGIT = /\A 
  (?=.*\d)           # Must contain a digit
  /x

PASSWORD_FORMAT_UPPER_LOWER_CASE = /\A
  (?=.*[a-z])        # Must contain a lower case character
  (?=.*[A-Z])        # Must contain an upper case character
  /x

PASSWORD_FORMAT_SYMBOL = /\A
  (?=.*[[:^alnum:]]) # Must contain a symbol
/x

validates :password,
  format: { with: PASSWORD_FORMAT_DIGIT, message: "must contain a digit"},
  on: :create

validates :password,
  format: { with: PASSWORD_FORMAT_UPPER_LOWER_CASE, message: "must contain lower or upper case"},
  on: :create  

validates :password, 
  presence: true, 
  length: { minimum: 8 }, 
  format: { with: PASSWORD_FORMAT_SYMBOL, message: "must contain a symbol." }, 
  confirmation: true, 
  on: :create 
  
  validates :password,
  allow_nil: true, 
  format: { with: PASSWORD_FORMAT_DIGIT, message: "must contain a digit"},
  on: :update

validates :password,
  allow_nil: true, 
  format: { with: PASSWORD_FORMAT_UPPER_LOWER_CASE, message: "must contain lower or upper case"},
  on: :update  

validates :password, 
  allow_nil: true, 
  length: { minimum: 8 }, 
  format: { with: PASSWORD_FORMAT_SYMBOL, message: "must contain a symbol." }, 
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
    remember_digest    
  end

  # Returns a session token to prevent session hijacking.
  # We reuse the remember digest for convenience.
  def session_token
    remember_digest || remember
  end  

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end  

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end  

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end  

  # Returns a user's status feed.
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Spell.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
                     .includes(:user, image_attachment: :blob)                     
  end

  # Follows a user.
  def follow(other_user)
    following << other_user unless self == other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end  

  def assign_house
    if self.skip_this_for_dumbledore.nil?
      self.house = ["Gryffindor", "Hufflepuff", "Slytherin", "Ravenclaw"].sample
    end
  end

  private

  # Converts email to all lowercase
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest 
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
