class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_path_start_with?, :current_user_session, :current_user
  helper_method :set_current_stable, :current_stable
  before_action :check_terms_accepted_and_logged_in, :set_locale

  private

  #Used to set locale language on the website.
  def set_locale

    l = I18n.default_locale
    p = params[:lang]
    if p.nil?
      if cookies[:my_locale] && I18n.available_locales.include?(cookies[:my_locale].to_sym)
        l = cookies[:my_locale].to_sym
      end
    else
      if I18n.available_locales.include?(p.to_sym)
        l = p
      end
    end

    cookies.permanent[:my_locale] = l
    I18n.locale = l

  end

  #Used to check that current_user is not nil and that they have accepted terms or not.
  def check_terms_accepted_and_logged_in
    # Return to login page
    redirect_to root_path and return if current_user.nil?
    # Redirect to terms page
    redirect_to terms_path if current_user.terms_accepted == false
  end

  def current_path_start_with?(path)
    request.path.start_with?(path)
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session&.user
  end

  def set_current_stable stable
    authorize! :is_trainer?, stable
    session[:current_stable] = stable.id
  end
  # Is only used in web interface
  def current_stable
    if session[:current_stable].nil?
      set_current_stable current_user.user_stable_roles.where(role: ['trainer', 'employee']).joins(:stable).where(stables: {active: true}).order('stables.name asc').first.stable
    end
    begin
      Stable.find(session[:current_stable])
    rescue
      session[:current_stable] = nil
      current_stable
    end
  end
end
