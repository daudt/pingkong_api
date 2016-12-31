class ApproveCurrentUsers < ActiveRecord::Migration[5.0]
  def change
    User.all.each do |user|
      user.approved = true
      user.save!
    end
  end
end
