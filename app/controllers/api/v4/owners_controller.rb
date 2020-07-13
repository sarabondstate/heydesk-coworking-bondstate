class Api::V4::OwnersController < Api::V4::ApiController

  before_action :find_owner, only: [:accept_reject_request]
  before_action :find_ownership, only: [:trainer_remove_owner]

  def index
    if current_user.is_a_trainer?
      # owner_req = current_user.my_requests
      owner_req_modify = current_user.my_requests.where(:status => [0,1])
      owners = User.find(owner_req_modify.pluck(:user_id)) rescue []
      pending_requests = owner_req_modify.where(status: 0).count rescue 0
      render json: { owner_requests: owner_req_modify.as_api_response(:request_basic), pending_requests: pending_requests  }
    else
      render json: {success: false, message: 'User is not a trainer'}
    end
  end

  def accept_reject_request
    if params[:status] == 1
      @ownership = @owner.ownerships.find_or_create_by(common_horse_id: params[:common_horse_id])
      @owner_request.update(status: params[:status])
      if @ownership.save
        render json: {success: true, message: 'Request has been accepted.'}
      else
        render json: {success: false, message: @ownership.try(:errors).try(:full_messages)}
      end
    elsif params[:status] == 2
      @owner_request.update(status: params[:status])
      render json: {success: true, message: 'Request has been rejected.'}
    end
  end

  def trainer_remove_owner
    owner_request = current_user.my_requests.where(common_horse_id: params[:common_horse_id], user_id: params[:owner_id])
    if owner_request.destroy_all && @ownership.destroy_all
      render json: {success: true, message: 'Trainer ownership destroyed successfully'}
    else
      render json: { success: false, message: @ownership.try(:errors).try(:full_messages) }
    end
  end

  private

  def find_owner
    @owner = User.find(params[:owner_id])
    @owner_request = @owner.owner_requests.find_by(common_horse_id: params[:common_horse_id])
  end

  def find_ownership
    @ownership = Ownership.where(user_id: params[:owner_id], common_horse_id: params[:common_horse_id])
  end
end
