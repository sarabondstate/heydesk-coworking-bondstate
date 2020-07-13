class Api::V1::SessionsController < Api::V1::ApiController
  skip_before_action :authenticate_user, only: :create

  include CommonActions::UserActions
  include CommonActions::HorseActions

  api! 'Log in the user and get a token.'
  param :user_session, Hash, required: true do
    param :email, String, required: true
    param :password, String, required: true
  end
  description 'This return user_credentials which should be used on every call authenticating the user. Profile_type can be `owner`, `employee`, `external_employee` or `trainer`.'
  example '{
    "id": 144,
    "email": "emp1@stable.dk",
    "name": "Employee Gut 1",
    "updated_at": "2017-09-07T09:51:37.165Z",
    "created_at": "2017-09-07T09:51:37.165Z",
    "user_credentials": "kGC9ivq57AfGlc0oL54q",
    "stables": [
        {
            "id": 31,
            "name": "test stald",
            "role": "employee"
        }
    ],
    "selected_stable": {
        "id": 31,
        "data": {
            "users": [...],
            "horses": [...],
            "tags": [...]
        }
    }
}'
  error code: 422, desc: 'WRONG_LOGIN: Unable to login. Wrong email or password.'
  error code: 403, desc: 'APP_NOT_ALLOWED: User is not allowed or has no content in the app.'
  def create
    session = UserSession.new(user_session_params)

    if session.save
      unless session.user.can_use_app?
        session.destroy
        render json: {
            error: 'APP_NOT_ALLOWED',
            message: 'User is not allowed or has no content in the app.'
        }, status: 403
      else
        render json: logging_in_data(session.user, session.user.stables.first)
      end
    else
      render json: {
          error: 'WRONG_LOGIN',
          message: 'Unable to login'
      }, status: 422
    end
  end

  api! 'A way to get user information without the need of saving password.'
  param :stable_id, :number
  param :user_since, DateTime, 'Only get updates of users'
  param :horse_since, DateTime, 'Only get updates of horses'
  #see 'sessions#create', 'POST for the same output'
  error code: 403, desc: 'APP_NOT_ALLOWED: User is not allowed or has no content in the app.'
  def autologin
    unless current_user.can_use_app?
      session.destroy
      render json: {
          error: 'APP_NOT_ALLOWED',
          message: 'User is not allowed or has no content in the app.'
      }, status: 403
    else
      stable = params[:stable_id] ? Stable.find(params[:stable_id]) : current_user.stables.first
      authorize! :read, stable
      render json: logging_in_data(current_user, stable, params)
    end
  end

  api! 'Invalidates the user_credentials token.'
  def destroy
    current_user.reset_single_access_token!
    render json: {}
  end

  private
  def user_session_params
    params.require(:user_session).permit(:email, :password)
  end

  def logging_in_data(user, stable, params = {})
    data = user.as_api_response(:logging_in)
    data[:selected_stable] = {
      id: stable.id,
      users: user_index(stable, params[:user_since]),
      horses: horse_index(stable, params[:horse_since]),
      tags: stable.tags.as_api_response(:basic)
    }
    return data
  end
end
