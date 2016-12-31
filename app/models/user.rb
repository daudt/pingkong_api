class User < ApplicationRecord
  has_many :rankings, dependent: :destroy
  has_and_belongs_to_many :matches
  has_many :winners, dependent: :destroy

  before_create :set_rating, :set_uuid
  after_create :send_admin_mail

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :omniauthable

  include DeviseTokenAuth::Concerns::User

  def set_rating
    self.rankings.new(rating: self.rating)
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super
    end
  end

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  def send_admin_mail
    AdminMailer.new_user_waiting_for_approval(self).deliver
  end

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    if !recoverable.approved?
      recoverable.errors[:base] << I18n.t("devise.failure.not_approved")
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end
    recoverable
  end

end
