class Api::V3::HorsesController < Api::V3::ApiController
  load_and_authorize_resource :stable, only: :index
  load_and_authorize_resource only: :show

  include CommonActions::HorseActions

  api! 'Lists horses in that stable'
  desc 'The "user_flagged" is if the user has flagged/bookmarked the horse'
  param :since, String , 'Filters horses to only show those who have been updated since. You should use an `updated_at` from the latest call. Should look like 2017-08-31T07:30:21.818Z'
  example '[
    {
        "id": 37,
        "name": "Eternal Shadow",
        "stable_id": 31,
        "registration_number": "0S0364",
        "birthday": null,
        "nationality": null,
        "deleted": false,
        "created_at": "2017-09-07T09:51:39.379Z",
        "updated_at": "2017-09-18T10:50:27.782Z",
        "user_flagged": true
    },
    {
        "id": 38,
        "name": "Eye of the Tiger",
        "stable_id": 31,
        "registration_number": "0S0037",
        "birthday": "2012-09-18",
        "nationality": "DK",
        "deleted": false,
        "created_at": "2017-09-07T09:51:39.403Z",
        "updated_at": "2017-09-18T10:50:27.794Z",
        "user_flagged": false
    }
]'
  def index
    horses = horse_index(@stable, params[:since])
    render json: horses
  end

  api! 'Show horse details'
  desc 'This is NOT the same as horse index.'
  example '{
    "name": "Eternal Shadow",
    "registration_number": "0S0364",
    "gender": "Vallak",
    "birthday": "2012-09-18",
    "nationality": "DK",
    "breeder": null,
    "owner": null,
    "chip_number": null,
    "mom": null,
    "dad": null,
    "avatar": "http://mosson-staging.s3.amazonaws.com/horses/avatar/default/large/horse.png",
    "avatar_thumb": "http://mosson-staging.s3.amazonaws.com/horses/avatar/default/thumb/horse.png"
}'
  def show
    render_for_api :common_horse_v3, json: @horse
  end

  api! 'Race info'
  example '{
    "winning_percentage": 11,
    "number_of_starts": 43,
    "first_prices": 2,
    "second_prices": 1,
    "third_prices" : 3,
    "record_time": 17.4,
    "record_time_auto": 17.3,
    "earnings": [
        {
            "currency": "DKK",
            "earnings": 250
        },
        {
            "currency": "NOK",
            "earnings": 394.34
        }
    ],
    "races": [
        {
            "race_position": 1,
            "track": "Odense",
            "earnings": 1004,
            "date": "2017-11-08"
        },
        {
            "race_position": 3,
            "track": "Herning",
            "earnings": 600.4,
            "date": "2012-11-08"
        }
    ]
}'
  def race_info
    horse = Horse.find(params[:horse_id])
    authorize! :read, horse
    common_horse = horse.common_horse

    render_for_api :race_info, json: common_horse
  end
  
  
  api! 'Sets avatar as base64 string for a given horse. Return 200'
  param :horse, Hash, required: true do
    param :avatar, String, required: true
  end
  def set_avatar
    horse = Horse.find(params[:horse_id])
    authorize! :set_avatar, horse
    horse_params = params.require(:horse).permit(:id, :avatar)
    if horse.update!(avatar: horse_params[:avatar])
      render json: {}, status: 200
    end
  end

end
