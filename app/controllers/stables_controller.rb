class StablesController < ApplicationController
  load_and_authorize_resource except: [:change_stable,:generate_standard_templates]

  def index
  end

  def show
  end

  def edit
  end

  def new
  end

  def update
    if @stable.update_attributes(stable_params)
      redirect_to stables_path
    else
      render action: :edit
    end
  end

  def create
    @stable = Stable.new(stable_params)
    if @stable.save
      redirect_to stables_path
    else
      render action: :edit
    end
  end

  def change_stable
    set_current_stable Stable.find(params[:stable_id])
    redirect_to :back
  end

  def generate_standard_templates
    Stable.find(params[:stable_id]).create_missed_templates
    render:text=>"done"
  end

  private
  def stable_params
    params.require(:stable).permit(:name, :address, :zip, :city, :trainer_id, :active, :telephone)
  end
end
