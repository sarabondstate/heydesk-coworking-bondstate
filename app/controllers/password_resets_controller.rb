class PasswordResetsController < ApplicationController
  before_action :load_user_using_perishable_token, except: [:index, :create]
  before_action :check_terms_accepted_and_logged_in, except: [:index, :create, :show, :update]

  def index
    @user = User.new
  end

  def create
    @user = User.find_by_email(params[:user][:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = t('password_resets.email_sent', email: @user.email)
      redirect_to new_session_path
    else
      flash[:notice] = translate('password_resets.could_not_find_email')
      @user = User.new
      redirect_to '/'
    end
  end

  def show
  end

  def update
    if @user
      if @user.update_attributes(password_resets_params)
        flash[:notice] = translate('password_resets.password_is_updated')
        # Make sure all devices log out
        @user.reset_single_access_token!
        # Make sure we do not log in
        current_user_session.destroy
        redirect_to new_session_path if @user.can_use_web_login?
      else
        render action: :show
      end
    end
  end

  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    flash[:notice] = translate('password_resets.token_expired') unless @user
  end

  def password_resets_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
