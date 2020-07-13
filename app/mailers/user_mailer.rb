class UserMailer < ApplicationMailer

  # Styling emails just sucks! Use these styles for make sure that headlines, paragraphs and whatnot looks as good as possible!
  #
  # Use the following style for headlines:
  # <h1 style="color: #014B59;padding: 0;font-family: Arial, sans-serif;margin: 0 0 10px 0;line-height: 1.6;font-weight: 700;font-size: 18px;">CONTENT</h1>
  #
  # Use the following style for paragraphs:
  # <p style="color: #014B59;padding: 0;font-family: Arial, sans-serif;margin: 0, 0, 10px, 0;font-size: 14px;line-height: 1.6;">CONTENT</p>
  #
  # Use the following style for buttons:
  # <a href="URL" style="display: inline-block;color: #014B59;background-color: #68C1BE;border-radius: 20px;box-sizing: border-box;cursor: pointer;text-decoration: none;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-transform: capitalize;border-color: #3498db;font-family: Arial, sans-serif;">CONTENT</a>
  #
  # Use the following style for links:
  # <a href="URL" style="border:none; color: #014B59;font-family: Arial, sans-serif;font-size: 14px;line-height: 1.6;">CONTENT</a>


  default from: 'sara@bondstate.com'
  def find_trainer(user,trainer,language,base_url)
    subject = translate('emails.trainer_email.email_subject', :locale => language)
    @body = t('emails.trainer_email.email_body',{owner_name: user.name, owner_email: user.email, web_url: base_url,:locale => language } ).html_safe;
    mail(to: trainer, subject: subject)
  end






  def password_reset_instructions(user)
    subject = translate('emails.reset_password_email.email_subject')
    @body = t('emails.reset_password_email.email_body', {name: user.name, password_url: password_reset_url(user.perishable_token)}).html_safe;
    mail(to: user.email, subject: subject)
  end

  def user_is_created(user, stable, password)
    subject = translate('emails.user_created_email.user_created_email_subject')
    @body = t('emails.user_created_email.user_created_email_body', {name: user.name, stable: stable.name, password: password}).html_safe
    mail(to: user.email, subject: subject)
  end

  def user_is_added_to_stable(user, stable)
    subject = translate('emails.user_added_email.user_is_added_to_stable_email_subject', {stable: stable.name})
    @body = t('emails.user_added_email.user_is_added_to_stable_email_body', {name: user.name, stable: stable.name}).html_safe
    mail(to: user.email, subject: subject)
  end

  def trainer_is_created(user, password)
    subject = translate('emails.trainer_created_email.email_subject')
    @body = t('emails.trainer_created_email.email_body', {name: user.name, password: password}).html_safe
    mail(to: user.email, subject: subject)
  end

  def owner_was_created(user, password, base_url)

    subject = translate('emails.owner_created_email.owner_created_email_subject')
    # horse_name = horses &&  horses.size > 0 ? horses.collect(&:name).join(', ') : ""
    # trainer_name = horses &&  horses.size > 0 && horses.first.horses.first != nil && horses.first.horses.first.stable != nil && horses.first.horses.first.stable.trainer != nil ? horses.first.stable.trainer.name : ""
    @body = t('emails.owner_created_email.owner_created_email_body', {name: user.name, password: password, base_url: base_url}).html_safe
    mail(to: user.email, subject: subject)
  end

  def user_was_made_owner(user)
    subject = translate('emails.user_made_owner_email.user_made_owner_email_subject')
    # horse_name = horses ? horses.collect(&:name).join(', ') : ""
    # trainer_name = horses &&  horses.size > 0 && horses.first.horses.first != nil && horses.first.horses.first.stable != nil && horses.first.horses.first.stable.trainer != nil ? horses.first.stable.trainer.name : ""
    @body = t('emails.user_made_owner_email.user_made_owner_email_body', {name: user.name}).html_safe
    mail(to: user.email, subject: subject)
  end

end
