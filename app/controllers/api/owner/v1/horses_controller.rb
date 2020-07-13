class Api::Owner::V1::HorsesController < Api::Owner::V1::ApiController

api! 'Lists horses owned by user'
example '[
  {
      "id": 37,
      "name": "Eternal Shadow",
      "registration_number": "0S0364",
      "birthday": "2012-09-18",
      "nationality": null,
      "gender": null,
      "breeder": null,
      "owner": owner,
      "chip_number" : null,
      "created_at": "2017-09-07T09:51:39.379Z",
      "updated_at": "2017-09-18T10:50:27.782Z",
  },
  {
      "id": 38,
      "name": "Eye of the Tiger",
      "registration_number": "0S0037",
      "birthday": "2012-09-18",
      "nationality": "DK",
      "gender": null,
      "breeder": null,
      "owner": owner,
      "chip_number" : null,
      "created_at": "2017-09-07T09:51:39.403Z",
      "updated_at": "2017-09-18T10:50:27.794Z",
  }
]'
def index
  @horses = current_user.owned_horses.includes(:stable, :common_horse)
  render_for_api :owned_horse, json: @horses
end

api! 'Get horse owned by user'
example '
  {
      "id": 37,
      "name": "Eternal Shadow",
      "registration_number": "0S0364",
      "birthday": "2012-09-18",
      "nationality": null,
      "gender": null,
      "breeder": null,
      "owner": owner,
      "chip_number" : null,
      "created_at": "2017-09-07T09:51:39.379Z",
      "updated_at": "2017-09-18T10:50:27.782Z",
  }'
def show
  @horse = current_user.owned_horses.includes(:stable, :common_horse).find (params[:id])
  render_for_api :show_owned_horse, json: @horse
end

api! 'Get race info for horse'
def race_info
  @horse = current_user.owned_horses.find (params[:horse_id])
  render_for_api :race_info, json: @horse.common_horse
end

api! 'Get training tasks for horse'
def training
  fetch_tasks("training")
end

api! 'Get race tasks for horse'
def races
  fetch_tasks("race")
end

api! 'Get all race tasks for owned horses'
def all_races
  tag_type = TagType.find_by(title: 'race')
  unless tag_type.nil?
    tasks = Task.joins(:tags).includes(:horse, :custom_field_values, :stable, :type).where("horse_id IN (?) AND tags.tag_type_id = ?", current_user.owned_horses.pluck(:id), (tag_type.id ||= 0) )
    render_for_api :owner_basic, json: tasks.order(date: :desc)
  else
    render json: []
  end
end

api! 'Get medias for horse'
def medias
  render json: []
end

private
def fetch_tasks(task_type_title)
  @horse = current_user.owned_horses.find (params[:horse_id])
  tag_type = TagType.find_by(title: task_type_title)
  unless tag_type.nil?
    tasks = @horse.tasks.joins(:tags).includes(:stable, :custom_field_values).where("tags.tag_type_id = ?", (tag_type.id ||= 0) )
    render_for_api :owner_basic, json: tasks.order(date: :desc)
  else
    render json: []
  end
end
end
