class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, except: :destroy
  skip_before_action :check_terms_accepted_and_logged_in
  #layout 'log_in'

  def new
    @user_session = UserSession.create({})
    @user = User.new
  end

  def create
    @user_session = UserSession.new(user_session_params)
    if @user_session.save
      unless @user_session.user.can_use_web_login?
        @user_session.destroy
        flash[:danger] = translate('log_in.no_web_access')
        @user_session = UserSession.create({})
      end
      redirect_to '/'
    else
      flash.now[:danger] = translate('log_in.wrong_credentials')
      @user_session.remember_me = user_session_params[:remember_me]
      @user_session.errors.clear
      @user = User.new
      render action: :new
    end
  end

  def index
    redirect_to '/'
  end

  def destroy
    current_user_session.destroy
    session.destroy
    redirect_to '/'
  end

  private
  def redirect_if_logged_in
    unless current_user.nil?
      redirect_to :controller => 'dashboard'
    end
  end

  def user_session_params
    params.require(:user_session).permit(:email, :password, :remember_me)
  end
end
