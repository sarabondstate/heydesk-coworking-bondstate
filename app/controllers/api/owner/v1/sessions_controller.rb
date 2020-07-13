class Api::Owner::V1::SessionsController < Api::Owner::V1::ApiController
  skip_before_action :authenticate_user, only: :create

  api! 'Log in the user and get a token.'
  param :user_session, Hash, required: true do
    param :email, String, required: true
    param :password, String, required: true
  end
  description 'This return user_credentials which should be used on every call authenticating the user. Profile_type can be `owner`'
  example '{
    "id": 144,
    "email": "owner@superhorse.dk",
    "name": "Rich Guy",
    "updated_at": "2017-09-07T09:51:37.165Z",
    "created_at": "2017-09-07T09:51:37.165Z",
    "user_credentials": "kGC9ivq57AfGlc0oL54q",
     "terms": "bla bla",
  }'
  error code: 422, desc: 'WRONG_LOGIN: Unable to login. Wrong email or password.'
  error code: 403, desc: 'APP_NOT_ALLOWED: User is not allowed or has no content in the app.'
  def create
    session = UserSession.new(user_session_params)
    if session.save
      unless session.user.is_an_owner?
        session.destroy
        render json: {
            error: 'APP_NOT_ALLOWED',
            message: 'User is not allowed or has no content in the app.'
        }, status: 403
      else
        render json: logging_in_data(session.user, params)
      end
    else
      render json: {
          error: 'WRONG_LOGIN',
          message: 'Unable to login'
      }, status: 422
    end
  end


  api! 'A way to get user information without the need of saving password.'
  #see 'sessions#create', 'POST for the same output'
  error code: 403, desc: 'APP_NOT_ALLOWED: User is not allowed or has no content in the app.'
  def autologin
    unless current_user.is_an_owner?
      session.destroy
      render json: {
          error: 'APP_NOT_ALLOWED',
          message: 'User is not allowed or has no content in the app.'
      }, status: 403
    else
      render json: logging_in_data(current_user, params)
    end
  end

  api! 'Invalidates the user_credentials token.'
  def destroy
    current_user.reset_single_access_token!
    render json: {}
  end

  private

  # Permit only email and password
  def user_session_params
    params.require(:user_session).permit(:email, :password)
  end

  def logging_in_data(user, params = {})
    data = user.as_api_response(:owner_logging_in)
    data[:terms] = translate('general.terms').gsub("%{web_url}",request.base_url)
    if user.stripe_id.present?
      customer = user.get_stripe_customer
      @stripe_client = StripeService.new(customer)
      if customer.subscriptions.total_count > 0
        data[:is_owner_subscribed] = @stripe_client.subscription_status
      else
        data[:is_owner_subscribed] = 2
      end
    else
      data[:is_owner_subscribed] = 0
    end
    data
  end


end
