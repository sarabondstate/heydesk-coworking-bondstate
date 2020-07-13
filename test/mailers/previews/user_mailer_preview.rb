class UserMailerPreview < ActionMailer::Preview
  def password_reset_instructions
    UserMailer.password_reset_instructions(User.first)
  end
  def user_is_created
    UserMailer.user_is_created(User.first, Stable.first, 'mypassword')
  end
  def user_is_added_to_stable
    UserMailer.user_is_added_to_stable(User.first, Stable.first)
  end
  def trainer_is_created
    UserMailer.trainer_is_created(User.first, 'mypassword')
  end

end