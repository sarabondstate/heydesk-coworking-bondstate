class UserStableRolesController < ApplicationController
  load_and_authorize_resource except: [:index, :edit, :destroy]
  load_resource only: [:edit, :destroy]

  def edit
    @user = @user_stable_role.user
    @horses = @user_stable_role.stable.horses
  end

  def update

    @user_stable_role.horses = []
    params[:horse_ids].each do |horse_id|
      @user_stable_role.horses << Horse.find(horse_id)
    end
    if @user_stable_role.save
      return redirect_to users_path
    end
    render action: :edit
  end
end
