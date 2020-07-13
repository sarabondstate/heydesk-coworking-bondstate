class Api::V2::HorseSetupsController < Api::V2::ApiController
  load_and_authorize_resource :horse, only: :index
  load_and_authorize_resource only: [:show, :update]

  api! 'Get possible setups for a horse'
  example '[
    {
        "id": 67,
        "title": "Sko"
    }
]'
  def index
    horse_setups = @horse.stable.setup_topics.map do |setup_topic|
      HorseSetup.where(setup_topic: setup_topic, horse: @horse).first_or_create
    end
    render_for_api :basic, json: horse_setups
  end

  api!
  example '{
    "id": 67,
    "title": "Sko",
    "description": "A long description."
}'
  def show
    render_for_api :extended, json: @horse_setup
  end

  api! 'Update description'
  param :description, String, required: true
  def update
    @horse_setup.update_attribute(:description, params[:description])
    render_for_api :basic, json: @horse_setup
  end
end
