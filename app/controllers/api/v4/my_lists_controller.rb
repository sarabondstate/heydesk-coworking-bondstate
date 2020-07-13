class Api::V4::MyListsController < Api::V4::ApiController
  load_and_authorize_resource :stable, only: [:index, :create]
  load_and_authorize_resource

  include CommonActions::MyListActions

  def_param_group :my_list do
    param :my_list, Hash, action_aware: true, required: true do
      param :title, String, required: true
      param :horse_ids, :array_of_ints_or_empty, 'Id of connected horse. The user should have read access to the horses. On updates, delete all by sending an empty array.'
      param :tag_ids, :array_of_ints_or_empty, 'On updates, delete all by sending an empty array.'
    end
  end

  api! 'View custom lists'
  example '[
    {
        "id": 2,
        "title": "Two horses and one tag",
        "horses": [
            37,
            38
        ],
        "tags": [
            3
        ],
        "created_at": "2017-09-13T09:16:55.832Z",
        "updated_at": "2017-09-13T09:16:55.832Z",
        "icon_url": "http://www.mosson.dk/assets/shoes.png""
    }
]'

  def index
    my_lists = my_lists_index(current_stable, current_user)
    render json: my_lists
  end

  #MyList.where(stable_id: current_stable).where(user_id: nil)

  api! 'Create new'
  param_group :my_list
  def create
    my_list = MyList.new(my_list_params)
    my_list.stable = @stable
    my_list.user = current_user

    authorize! :create, my_list
    my_list.save!

    render_for_api :basic, json: my_list
  end

  api! 'Update'
  param_group :my_list
  def update
    authorize! :update, @my_list

    @my_list.assign_attributes(my_list_params)

    authorize! :update, @my_list
    @my_list.save!

    render_for_api :basic, json: @my_list
  end

  api! 'Destroy'
  def destroy
    authorize! :destroy, @my_list
    @my_list.destroy
    render json: {}, status: 200
  end

  private
  def my_list_params
    params.require(:my_list).permit(:title, horse_ids: [], tag_ids: [])
  end
end
