class SetAdmins < ActiveRecord::Migration[5.0]
  def change
    User.where(email: %w(daudt@daudt.com sbalay@gmail.com)) do user
      user.admin = true
      user.save!
    end
  end
end
