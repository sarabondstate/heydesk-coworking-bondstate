class Api::V1::TagsController < Api::V1::ApiController
  load_and_authorize_resource :stable, only: :index
  load_and_authorize_resource :horse, only: [:horse_tags, :show]

  include ApplicationHelper
  include CommonActions::UserActions

  api! 'Lists tags in that stable'
  param :type, TagType.all.pluck(:title), 'Filter tags to type'
  example '[
    {
        "id": 13,
        "tag_name": "træning",
        "tag_type": "training"
    },
    {
        "id": 14,
        "tag_name": "sko",
        "tag_type": "todo"
    }
]'
  def index
    tags = @stable.tags
    tags = tags.includes(:tag_type).where(tag_types: {title: params[:type]}) unless params[:type].nil?
    render_for_api :basic, json: tags
  end

  api! 'Get tags\' updated_at. Used at the "Topics" screen.'
  desc 'Beware that update_at is in utc and can be null'
  example '[
    {
        "id": 23,
        "name": "sko",
        "updated_at": "2017-09-18T10:50:27.782Z"
    },
    {
        "id": 24,
        "name": "træning",
        "updated_at": "2017-09-18T10:50:27.782Z"
    },
    {
        "id": 25,
        "name": "vaccination",
        "updated_at": null
    }
]'
  def horse_tags
    ht = HorsesTags.get_all_for_horse(@horse).includes(:tag).where.not(tag_updated: nil).order(tag_updated: :desc)
    render_for_api :basic, json: ht
  end

  api! 'Lists related tasks/comments/etc relevant for tag and horse. Ordered by time desc.'
  desc 'Look at the extra parameter "class_type" to see what kind of object it is. Currently only "Task" and "Comment" exists.'
  param :user_since, DateTime, 'Only get updates of users'
  param :limit, :number, 'Limit. Default 10'
  example '{tasks: [...], comments: [...], tags: [...], users: [...]}'
  def show
    objects = HorsesTags.get_newest_relations(@horse, Tag.find(params[:id]), params[:limit].try(:to_i) || 10)
    objects = convert_list_of_objects_to_json(objects)
    objects[:users] = user_index(@horse.stable, params[:user_since])
    objects[:tags] = @horse.stable.tags.as_api_response(:basic)

    render json: objects
  end

end
