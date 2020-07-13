class Api::Owner::V1::UsersController < Api::Owner::V1::ApiController
  skip_before_action :authenticate_user, only: [:forgotten_password, :sign_up, :terms_conditions ]
  api! 'Show user'
  def show
    data = current_user.as_api_response(:owner_basic)
    data[:terms] = translate('general.terms').gsub("%{web_url}",request.base_url)
    render json: data, status: :ok
  end

  api! 'Edit a user'
  param :user, Hash, action_aware: true, required: true do
    param :name, String, 'The name', required: false
    param :email, String, 'The email', required: false
    param :password, String, 'The password', required: false
    param :password_confirmation, String, 'The password confirmation', required: false
    param :avatar, String, required: false
    param :push_enabled, %w(true false), 'Should the user receive push notifications', required: false
  end
  error :code => 400, desc: 'Could not update'
  def update
    begin
      current_user.update_attributes!(user_params)
      render_for_api :owner_basic, json: current_user
    rescue => ex
      render json: {error: ex.message}, status: 400
    end
  end

  api! 'If the user forgot their password. It will send an email with reset instructions'
  param :email, String, 'The email', required: true
  error :code => 404, desc: 'User with that email not found'
  def forgotten_password
    user = User.find_by_email!(params[:email])
    user.deliver_password_reset_instructions!
    render json: {message: "Recovery mail sent to #{user.email}"}
  end

  api! 'Sets avatar as base64 string for a given user. Return 200'
  param :user, Hash, required: true do
    param :avatar, String, required: true
  end
  def set_avatar
    user_params = params.require(:user).permit(:id, :avatar)
    if current_user.update!(avatar: user_params[:avatar], public_updated_at: DateTime.now)
      render json: { message: current_user.avatar_url }, status: 200
    end
  end

  api! 'Get push notification settings'
  example '{
    "push_enabled": false
  }'
  def push_settings
    render_for_api :owner_push_settings, json: current_user
  end

  #Add push tokens for the current users
  def update_push_token
     @push_token = PushToken.find_or_create_by(token: params[:push_token])
    if @push_token.update(user: current_user, token: params[:push_token])
      render json: {}, status: :ok
    else
      render :json => { :errors => @push_token.errors.full_messages }, status: 400
    end
  end

  #Add push tokens for the current users
  def delete_push_token
     @push_token = PushToken.find_by(token: params[:push_token])
    if @push_token && @push_token.destroy
        render json: {}, status: 200
    else
      render :json => { :errors => @push_token.errors.full_messages }, status: 400
    end
  end

  def sign_up
    begin
      @user = User.new(user_params)
      @user.username = (@user.username == '') ? @user.firstname : @user.username
      if @user.username.present?
        @user.owner_identifier = @user.username
        if @user.save
          render_for_api :owner_signup_basic, json: @user
        else
          errors = get_errors(@user.try(:errors).try(:full_messages))
          render json: errors
        end
      else
        render json: [{error: "Username is empty.", status: 400}]
      end
    rescue => ex
      render json: {error: ex.message}, status: 400
    end
  end

  def get_errors(errors)
    errors_hash = []
    errors.each do |error|
      hash = {}
      case error
      when "Email already in use"
        error_code = 250
      when "Password too short (minimum of 4 characters)"
        error_code = 350
      when "Password confirmation too short (minimum of 4 characters)"
        error_code = 350
      when "Password confirmation does not correspond with confirmation"
        error_code = 350
      else
        error_code = 400
      end
      hash["error"] = error
      hash["status"] = error_code
      errors_hash << hash
    end
    errors_hash
  end

  def cannot_find_horse
    trainer_email =  params[:trainer_email]
    language = params[:language]
    isValid=emails_valid(trainer_email)
    if isValid==true
    @user_mail = UserMailer.find_trainer(current_user, trainer_email,language,request.base_url)
    if @user_mail.deliver_now
        render json: { success: true, message: "Mail sent successfully"}
    else
        render json: { success: true, message: "Trainer email is empty"}
    end
    else

      render json: { error: true, message: "Invalid Email"}
    end
  end

  # def terms_conditions
  #   language = params[:language]
  #   owner_terms = translate('general.owner_terms',{:locale => language})
  #   render json: {success: true, owner_terms: owner_terms }, status: :ok
  # end

  def terms_conditions
    ln = params[:language].downcase
    language="en"
   if(ln =="en" || ln =="no" || ln =="se" || ln =="da" )
    language = ln
   end 
    owner_terms = translate('general.owner_terms',{:locale => language})
    render json: {success: true, owner_terms: owner_terms }, status: :ok
  end



  def emails_valid(emails_list)
      is_valid = true
      is_valid = false unless emails_list=~ /([^\s]+)@([^\s]+)/
      is_valid

  end

  def get_owners_state
    if current_user.stripe_id.present?
      customer = current_user.get_stripe_customer
      @stripe_client = StripeService.new(customer)
      if customer.subscriptions.total_count > 0
        is_owner_subscribed = @stripe_client.subscription_status
      else
        is_owner_subscribed = 2
      end
    else
      is_owner_subscribed = 0
    end
    owner_requests = current_user.owner_requests
    owned_horses = current_user.owned_horses
    my_request_count = owner_requests.count rescue 0
    owned_horse_count = owned_horses.count rescue 0
    pending_request_count = owner_requests.where(status: 0).count rescue 0
    rejected_request_count = owner_requests.where(status: 2).count rescue 0
    render json: {is_owner_subscribed: is_owner_subscribed, my_request_count: my_request_count, owned_horse_count: owned_horse_count, pending_request_count: pending_request_count, rejected_request_count: rejected_request_count }
  end

  # def cannot_find_horse
  #   trainer_email =  params[:trainer_email]
  #   language = params[:language]
  #   @user_mail = UserMailer.find_trainer(current_user, trainer_email,language,request.base_url)
  #   if @user_mail.deliver_now
  #     render json: { success: true, message: "Mail sent successfully"}
  #   else
  #     render json: { success: true, message: "Trainer email is empty"}
  #   end
  # end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :firstname, :lastname, :email, :phone, :username, :trainer_email, :avatar)
  end

end
