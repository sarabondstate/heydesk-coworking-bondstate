class UsersController < ApplicationController
  load_and_authorize_resource except: [:index, :edit, :destroy, :add_user]
  load_resource only: [:edit, :destroy, :add_user]

  def index
    @users = current_stable.users
  end

  def create
    if params['step_one']=='step_one'
      # Check email
      user = User.find_by_email(params[:user][:email])
      # If the user exist, just redirect to 'edit'
      redirect_to user_add_user_path(user) and return if user
      @user = User.new(user_params)
      @step_one = true if @user.email.empty?
      render action: :new
      return
    end

    return render action: :new if params[:user].empty? or params[:user][:role_as_string].empty?
    authorize! :update, @user
    @user = User.new(user_params)
    if @user.save
      # A new user is created in the database
      @user.user_stable_roles << UserStableRole.new(stable: current_stable, role: params[:user][:role_as_string])
      UserMailer.user_is_created(@user, current_stable, params[:user][:password]).deliver_now
      redirect_to users_path
    else
      render action: :new
    end
  end
  def add_user
    @user = User.find(params[:user_id])
    render action: :add_user
  end

  def edit
    if UserStableRole.where(user: @user, stable: current_stable).blank?
      redirect_to users_path
    end
  end

  def new
    @step_one = true
  end

  def update

    if @user.update_attributes(user_params)
      # The existing user should be added to the stable
      if @user.id != current_user.id
        @user_stable_role = @user.user_stable_roles.with_deleted.where(stable_id:current_stable.id).first_or_create
        @user_stable_role.update(role: params[:user][:role_as_string],deleted_at: nil)
        UserMailer.user_is_added_to_stable(@user, current_stable).deliver_now
      end
      return redirect_to users_path
    end
    render action: :new
  end

  def destroy
    user_stable_role = UserStableRole.where(user: @user, stable: current_stable)
    authorize! :destroy, user_stable_role.first
    user_stable_role.destroy_all
    redirect_to users_path
  end

  private
  def is_a_employee_a?
    current_user.user_stable_roles.where(role: 'employee').joins(:stable).where(stables: {active: true}).count > 0
  end

  def user_params
    params.require(:user).permit(:firstname,:lastname, :email, :password, :password_confirmation)
  end
end
