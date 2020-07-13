class Api::V3::UsersController < Api::V3::ApiController
  load_and_authorize_resource :stable, only: [:index, :update]
  load_and_authorize_resource except: [:forgotten_password, :terms_accepted, :push_settings, :set_avatar]
  skip_before_action :authenticate_user, only: :forgotten_password

  include CommonActions::UserActions

  api! 'Lists all users associated with a stable. By default it will not list deleted tasks, unless you provide "since"'
  param :since, DateTime, 'Filters to only show those who have been updated since. You should use an `updated_at` from the latest call. This will also list deleted users. Profile_type can be `owner`, `employee`, `external_employee` or `trainer`'
  example '[
    {
        "id": 154,
        "email": "ex@stable.dk",
        "name": "Smeden",
        "updated_at": "2017-09-07T09:51:39.065Z",
        "created_at": "2017-09-07T09:51:39.066Z",
        "role": "employee",
        "deleted": false
    },
    {
        "id": 155,
        "email": "trainer@stable.dk",
        "name": "Træner 1",
        "updated_at": "2017-09-07T09:51:39.233Z",
        "created_at": "2017-09-07T09:51:39.233Z",
        "role": "trainer",
        "deleted": false
    }
]'
  def index
    users = user_index(@stable, params[:since])
    render json: users
  end

  api! 'Show a single user'
  def show
    render_for_api :basic, json: @user
  end

  api! 'Used to register when a user accepts terms from the app'
  param :terms_accepted, :boolean, 'The terms accepted value', required: true
  error :code => 400, desc: 'Could not update'
  def terms_accepted
    if current_user.update_attribute(:terms_accepted, params[:terms_accepted])
      render_for_api :basic, json: current_user
    else
      render json: {}, status: 400
    end
  end

  api! 'If the user forgot their password. It will send an email with reset instructions'
  param :email, String, 'The email', required: true
  error :code => 404, desc: 'User with that email not found'
  def forgotten_password
    user = User.find_by_email!(params[:email])
    user.deliver_password_reset_instructions!
    render json: {}
  end

  api! 'Edit a user'
  param :user, Hash, action_aware: true, required: true do
    param :name, String, 'The name', required: false
    param :email, String, 'The email', required: false
    param :password, String, 'The password', required: false
    param :password_confirmation, String, 'The password confirmation', required: false
    param :push_enabled, %w(true false), 'Should the user receive push notifications', required: false
    param :push_feedback_mention, %w(true false), 'Should the user receive push notifications when mentioned in feedback', required: false
    param :push_flagged_horse_feedback, %w(true false), 'Should the user receive push notifications when a flagged horse gets new feedback', required: false
    param :push_flagged_horse_observation, %w(true false), 'Should the user receive push notifications when a flagged horse gets a new observation', required: false
  end
  error :code => 400, desc: 'Could not update'
  def update
    begin
      current_user.update_attributes!(user_params)
      user = current_user.as_api_response(:basic)
      user[:role] = current_user.role_in(current_stable)
      user[:deleted] = !current_user.deleted_in?(current_stable)
      render json: user
      #render_for_api :basic, json: current_user
    rescue => ex
      render json: {error: 'INVALID_PARAM'}, status: 400
    end
  end

  api! 'Sets avatar as base64 string for a given user. Return 200'
  param :user, Hash, required: true do
    param :avatar, String, required: true
  end
  def set_avatar
    user_params = params.require(:user).permit(:id, :avatar)
    if current_user.update!(avatar: user_params[:avatar])
      render json: {}, status: 200
    end
  end

  api! 'Get push notification settings'
  example '{
  "push_enabled": false,
  "push_feedback_mention": true,
  "push_flagged_horse_feedback": false,
  "push_flagged_horse_observation": false
}'
  def push_settings
    render_for_api :push_settings, json: current_user
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :push_feedback_mention, :push_flagged_horse_feedback, :push_flagged_horse_observation)
  end
end
