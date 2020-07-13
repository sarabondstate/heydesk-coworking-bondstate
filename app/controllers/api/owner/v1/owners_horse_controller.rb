class Api::Owner::V1::OwnersHorseController < Api::Owner::V1::ApiController

  skip_before_action :authenticate_user, only: :owner_request_dead
  before_action :find_common_horse, only: :request_trainer
  before_action :get_stable, only: :request_trainer
  # before_action :get_owner_request, only: :remove_ownership
  before_action :owned_horses, only: :owner_latest_activities
  include CommonActions::UserActions

  def request_trainer
    if current_user.is_an_owner?
      @owner_request = current_user.owner_requests.where(common_horse: @common_horse).first_or_initialize
      @owner_request.stable = @stable
      @owner_request.trainer_id = params[:trainer_id]
      if @owner_request.save
        render json: {success: true, owner_horse: @owner_request}
      else
        render json: { success: false, message: @owner_request.try(:errors).try(:full_messages) }
      end
    end
  end

  def all_stables
    common_horses = []
    my_horses = []
    users = trainers
    stables = Stable.active_n_type_race
    stables_response = stables.as_api_response(:all_active_stables)
    stables.each do |stable|
      stable.horses.active.each do |horse|
        common_horses << horse.horse_hash_with_extra_info(current_user)
      end
    end

    current_user.owner_requests.each do |owner_req|
      owner_req.common_horse.horses.each do |horse|
        my_horses << horse.horse_hash_with_extra_info(current_user)
      end
    end
    render json: {
      stables: stables_response.flatten,
      trainers: users,
      my_horses: my_horses.flatten,
      common_horses: common_horses.flatten
    }
  end

  def remove_ownership
    @ownership = current_user.ownerships.where(common_horse_id: params[:common_horse_id]).try(:first)
    @owner_request = current_user.owner_requests.where(common_horse_id: params[:common_horse_id]).try(:first)
    if @owner_request.present?
      if @owner_request.status == 1
        @ownership.destroy if @ownership.present?
        @owner_request.destroy
        render json: {success: true, message: 'Ownership destroyed successfully'}
      else
        @owner_request.destroy
        render json: {success: true, message: 'Owner Request without status 1 destroyed successfully'}
      end
    else
      render json: { success: false, message: "No ownership found." }
    end
  end

  def owner_latest_activities
    tasks = Task.where("type_id = ? or type_id = ?", 2,5)
    horse_tasks = tasks.where(horse_id: [@owned_horses.pluck(:id)]).order("created_at DESC").limit(20)
    render json: { latest_activities: horse_tasks.as_api_response(:owned_horse_tasks) }
  end

  def owner_request_dead
    @owner_reqs = OwnerRequest.all.order("created_at DESC").limit(20)
    @total = OwnerRequest.count
    # @owner_reqs.each do |req|
    #   stable = Stable.find(req.stable_id)
    #   trainer_id = stable.trainer_id
    #   req.trainer_id = trainer_id
    #   req.save
    # end
    render json: {success: true, owner_reqs: @owner_reqs, total: @total}
  end

  private

  def find_common_horse
    @common_horse = CommonHorse.find(params[:common_horse_id])
  end

  def get_stable
    @stable = Stable.find(params[:stable_id])
  end

  def owned_horses
    @owned_horses = current_user.owned_horses
  end

end
