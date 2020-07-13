class Api::V4::HorseFlagsController < Api::V4::ApiController
  #api! 'Show the current users flags. This is also included when you log in.'
  #def index
  #  render_for_api  :only_horses,json: current_user.horse_flags
  #end

  api! 'Create a marking of a horse. Returns 200 on success'
  param :horse_id, :number, required: true
  def create
    horse = Horse.find(params[:horse_id])
    authorize! :read, horse
    # Make sure only on flag can exist per horse/user combination
    HorseFlag.find_or_create_by!(horse: horse, user: current_user)
    render json: {}, status: 200
  end

  api! 'Delete a marking of a horse. Returns 200 on success'
  def destroy
    horse_flags = HorseFlag.where(horse_id: params[:id], user_id: current_user.id)
    authorize! :delete, horse_flags.first
    horse_flags.destroy_all
    render json: {}, status: 200
  end
end
