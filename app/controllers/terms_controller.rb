class TermsController < ApplicationController
  skip_before_action :check_terms_accepted_and_logged_in

  def index
    @terms = translate('general.terms')
  end

  def accept_terms
    if current_user.update_attribute(:terms_accepted, true)
      redirect_to :controller => 'users'
    end
  end

  def update_record
    Stable.all.each do |stable|
      user = stable.users.where(user_stable_roles: {role:'trainer'}).first
      stable.update_attributes(trainer_id: user.id) if user.present?
    end
    redirect_to :back
  end

end
