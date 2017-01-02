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

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  def send_admin_mail
    AdminMailer.new_user_waiting_for_approval(self).deliver
  end

  def num_matches
    matches.count
  end

  def num_wins
    winners.count
  end

  def num_losses
    num_matches - num_wins
  end

end
