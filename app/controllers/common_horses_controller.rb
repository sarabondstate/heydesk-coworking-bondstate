class CommonHorsesController < ApplicationController

  def new
    get_horse_add_status
    @common_horse = CommonHorse.new
  end
  
  def edit
    @common_horse = CommonHorse.find(params[:id])
  end
  
  def update
    @common_horse = CommonHorse.find(params[:id])

    
     # @common_horse.update_attributes(common_horse_params)

    if @common_horse.sportsinfo_id.nil?

      if(params[:common_horse][:price]=="")
         params[:common_horse][:price]=0
      end

      @common_horse.update_attributes(common_horse_params)
    end

    horse = @common_horse.horses.where(stable_id: current_stable.id).where(common_horse_id: @common_horse.id).first
    unless horse.nil?
      horse.update_attributes(horse_params)
      horse.save
    end

    redirect_to horses_path
  end


  def create
    if current_stable.horses_allow_add
      @common_horse = CommonHorse.new(common_horse_params)
      if @common_horse.save
        horse = Horse.new(stable: current_stable, common_horse: @common_horse)
        if horse.save
          redirect_to horses_path
        else
          flash[:danger] = translate('horses.not_found')
          redirect_to horses_path and return
        end
      else
        render action: :new
      end
    else
      render action: :new
    end
  end

  private

  def get_horse_add_status
    result = current_stable.get_add_horse_status
    @add_horse_status_msg = result[1]
    @disabled = result[0]
  end

  def common_horse_params
    params.require(:common_horse).permit(:name, :registration_number, :birthday, :nationality, :breeder, :owner, :chip_number, :gender, :mom, :dad, :winning_percentage, :number_of_starts, :earnings_danish, :earnings_norwegian, :earnings_swedish,:price , races_attributes: [:id, :race_position, :track, :earnings, :date, :_destroy])
  end

  def horse_params
    params.require(:common_horse).require(:horse).permit(:active)
  end
end
