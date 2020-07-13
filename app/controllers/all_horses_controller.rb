class AllHorsesController < ApplicationController

  def index
    @common_horses = CommonHorse.all
  end

  def edit
    @common_horse = CommonHorse.find(params[:id])
  end

  def new
    @common_horse = CommonHorse.new
  end

  def update
    @common_horse = CommonHorse.find(params[:id])
    if @common_horse.update_attributes(horse_params)
      redirect_to horses_path
    else
      render action: :edit
    end
  end

  def create
    @common_horse = CommonHorse.new(horse_params)
    if @common_horse.save
      redirect_to horses_path
    else
      render action: :new
    end
  end

  private
  def horse_params
    params.require(:common_horse).permit(:name, :registration_number, :birthday, :nationality, :breeder, :owner, :chip_number, :gender, :mom, :dad, :winning_percentage, :number_of_starts, :earnings_danish, :earnings_norwegian, :earnings_swedish, races_attributes: [:id, :race_position, :track, :earnings, :date, :_destroy])
  end
end
