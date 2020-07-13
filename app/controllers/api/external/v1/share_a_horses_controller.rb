class Api::External::V1::ShareAHorsesController < ActionController::Base
  before_action :check_auth_keys

  def create
    user_params = params[:user]
    horses_params = params[:horses]

    user = User.find_by(owner_identifier: user_params[:id])
    unless user.nil?
      # A owner with given id already exists
      render json: { message: "Ownership exists" }, status: :conflict
      return
    end

    user = User.find_by(email: user_params[:email]) if user.nil?
    new_user = false
    if user.nil?
      # no user found with email: Create new
      user = User.new
      user.email = user_params[:email]
      user.owner_identifier = user_params[:id]
      # This is bad - we dont have a name so we will temporary use the owner id.....
      user.name = user.firstname = user.lastname = user.username = "#{user_params[:id]}"
      user.terms_accepted = false

      # Generate a password....
      password = ('0'..'z').to_a.shuffle.first(8).join
      user.password = user.password_confirmation = password


      new_user = true
    else
      # User found. Make the user an owner
      user.owner_identifier = user_params[:id]
    end
    if user.save
      horses_lst = update_ownership(user, horses_params)
      if new_user
        # Send welcome mail with password....
        UserMailer.owner_was_created(user, password, request.base_url).deliver_now
      else
        UserMailer.user_was_made_owner(user).deliver_now
      end
      render json: { message: "Ownership created"}, status: :ok
    else
      render json: { message: user.errors.full_messages.first }, status: :bad_request
    end
  end

  def update
    user_params = params[:user]
    horses_params = params[:horses]

    user = User.find_by(owner_identifier: user_params[:id])

    if user.nil?
      render json: { message: "Ownership doesn't exist" }, status: :not_found
    else

      # Update email if needed...
      unless user.email == user_params[:email]
        user.update_attributes(email: user_params[:email])
      end

      update_ownership(user, horses_params)
      render json: { message: "Ownership updated"}, status: :ok
    end
  end

  def destroy
    user_params = params[:user]
    user = User.find_by(owner_identifier: user_params[:id])
    if user.nil?
      render json: { message: "Owner doesn't exist" }, status: :not_found
    else
      user.update_attributes(owner_identifier: nil)
      user.ownerships.destroy_all
      render json: { message: "Ownership destroyed"}, status: :ok
    end
  end

  private
  def check_auth_keys
    if Rails.env.production?
      auth_key = 'e6fc12a18f7cdb02be8993cf82730bc1b810c36932d0e28a65cb6479b1315f929cf6260af34188f48438474eda7feeec0a0fe0f322972095d0663232cce34884'
    else
      auth_key = '2db56415b3cff131de9020261d5943be9e28edb52978682c4a53d9fc847924c41cd4350ecf68fb9b5fd4da226fe0adae4d4ef426d9c8c7a0245680fe202c3b07'
    end
    render json: { message: "Not allowed" }, status: :unauthorized if params[:auth] != auth_key
  end

  def update_ownership(user, horses_params)
    horses_lst = []
    user.ownerships.destroy_all
    horses_params.each do |hp|
      horse = CommonHorse.find_by(sportsinfo_id: hp)
      Ownership.create(user: user, common_horse: horse) unless horse.nil?
      horses_lst << horse
    end

    return horses_lst
  end
end
