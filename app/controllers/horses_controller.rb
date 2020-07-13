class HorsesController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:update_horse_position]

  def index
    get_horse_add_status
    @horses = current_stable.horses
    @myHorses = @horses.where(active: true).joins(:common_horse).order('sorting ASC, common_horses.name ASC')
  end

  def new
    @common_horse = CommonHorse.new
  end

  def horse_info
    @common_horse = CommonHorse.find(params[:id])
    render partial: 'horse_info'
  end

  def single_import_preview
    @common_horse = CommonHorse.find(params[:id])
    render partial: 'single_import_preview'

  end

  def import_single
    if current_stable.horses_allow_add
      horse = Horse.with_deleted.find_or_create_by(stable_id: current_stable.id, common_horse_id: params[:common_horse][:id])
      horse.update_attribute(:deleted_at, nil)
      flash[:info] = translate('horses.import_success')
    end
    redirect_to horses_path

  end

  def multiple_import_preview

    unless is_all_mode_allowed?('all')
      redirect_to horses_path
    end

    @trainer_id = params[:trainer_id]
    @common_horses = CommonHorse.where(sportsinfo_trainer_id: @trainer_id)
    get_horse_add_status
  end


  def import_multiple
    unless is_all_mode_allowed?('all')
      redirect_to horses_path
    end

    unless params[:common_horse_ids].nil?
      if params[:common_horse_ids].count <= params[:max_horses].to_i || params[:max_horses].to_i == -3
        # Set the trainer id on the user, making sure we cannot bulk import again
        current_user.update_attribute :trainer_id, params[:trainer_id]

        params[:common_horse_ids].each do |id|
          if current_stable.horses_allow_add
            horse = Horse.with_deleted.find_or_create_by(stable_id: current_stable.id, common_horse_id: id)
            horse.update_attribute(:deleted_at, nil)
          end
        end
        flash[:info] = translate('horses.import_success')
        redirect_to horses_path
      else
        flash[:info] = translate('horses.import_fail')
        redirect_to multiple_import_preview_horses_path(params[:trainer_id])
      end
    end
  end

  def search
    @mode = params[:mode]

    unless is_all_mode_allowed?(@mode)
      redirect_to horses_path
    end

    @query = params[:query].strip

    @common_horses = {}
    if @query.empty?
      redirect_to horses_path
    else
      @common_horses = CommonHorse.where("LOWER(name) LIKE ? OR LOWER(registration_number) LIKE ?" , "%"+@query.downcase+"%", "%"+@query.downcase+"%").where.not(sportsinfo_id: nil)

      if @mode == 'all'
        @common_horses = @common_horses.where.not(sportsinfo_trainer_id: nil)
      end

      @common_horses = @common_horses.paginate(:page => params[:page], :per_page => 25)

    end
    
    get_horse_add_status
  end

  def edit
    @common_horse = CommonHorse.find(params[:id])
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

      if Horse.create(stable: current_stable, common_horse: @common_horse)
        redirect_to horses_path
      else
        flash[:danger] = translate('users.not_found')
        redirect_to horses_path and return
      end
    else
      render action: :new
    end
  end

  def create_horse_from_id
    common_horse = CommonHorse.find_by_registration_number(params[:common_horse][:registration_number])
    if common_horse.nil?
      flash[:danger] = translate('horses.not_found')
      redirect_to new_horse_path and return
    end
    stable = common_horse.stables.try(:first)
    if stable.nil? == false and stable != current_stable
      flash[:danger] = translate('horses.in_other_stable')
      redirect_to new_horse_path and return
    end

    # If we reassign a horse to a stable it is just marked as deleted
    horse = Horse.with_deleted.find_or_create_by(stable_id: current_stable.id, common_horse_id: common_horse.id)
    horse.update_attribute(:deleted_at, nil)
    flash[:info] = translate('horses.horse_added', name: common_horse.name)
    redirect_to horses_path
  end

  def destroy
    horse = Horse.find(params[:id])
    horse.delete
    redirect_to horses_path
  end

  # This method updates the horse positions by params [:id]
  def update_horse_position
    current_stable.update_horse_sorting(params[:ids])
    head :ok
  end

  private

  def get_horse_add_status
    result = current_stable.get_add_horse_status
    @add_horse_status_msg = result[1]
    @disabled = result[0]
    @remaining_max_horses = result[2]
  end

  def is_all_mode_allowed? mode
    if mode == 'all' && !current_user.trainer_id.nil?
      false
    else
      true
    end
  end

  def horse_params
    params.require(:common_horse).permit(:name, :registration_number, :birthday, :nationality, :breeder, :owner, :chip_number, :gender, :mom, :dad, :winning_percentage, :number_of_starts, :earnings_danish, :earnings_norwegian, :earnings_swedish, races_attributes: [:id, :race_position, :track, :earnings, :date, :_destroy])
  end
end
