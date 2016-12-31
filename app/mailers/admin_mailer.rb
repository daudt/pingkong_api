class AdminMailer < ApplicationMailer

  def new_user_waiting_for_approval(user)
    User.where(admin: true).each do |admin|
      @user = user
      @url = "#{api_users_url}/#{@user.uuid}/approve"
      mail(to: admin.email, subject: 'New user awaiting approval')
    end
  end

end
