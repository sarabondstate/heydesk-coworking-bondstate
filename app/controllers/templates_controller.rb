class TemplatesController < ApplicationController
  load_and_authorize_resource except: :index

  def index
    @templates = current_stable.templates
  end

  def new
  end

  def edit
  end

  def update
    if @template.update_attributes(template_params)
      redirect_to templates_path
    else
      render action: :edit
    end
  end

  def create
    @template.stable = current_stable
    if @template.save
      redirect_to templates_path
    else
      render action: :new
    end
  end

  def destroy
    @template.destroy
    redirect_to templates_path
  end

  private
  def template_params
    params.require(:template).permit(:name, :tag_type_id, :prefilled_title, :note, horse_ids: [], tag_ids: [])
  end
end
