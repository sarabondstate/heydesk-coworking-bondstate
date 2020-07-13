class Api::V1::UsersController < Api::V1::ApiController
  load_and_authorize_resource :stable, only: :index
  load_and_authorize_resource except: :forgotten_password
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

  api! 'If the user forgot their password. It will send an email with reset instructions'
  param :email, String, 'The email', required: true
  error :code => 404, desc: 'User with that email not found'
  def forgotten_password
    user = User.find_by_email!(params[:email])
    user.deliver_password_reset_instructions!
    render json: {}
  end
end
