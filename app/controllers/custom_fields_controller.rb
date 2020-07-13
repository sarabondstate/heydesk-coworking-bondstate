class CustomFieldsController < ApplicationController
  load_and_authorize_resource except: :index

  def index
    @custom_fields = current_stable.custom_fields
  end

  def new
  end

  def edit
  end

  def update
    if @custom_field.update_attributes(custom_field_params)
      redirect_to custom_fields_path
    else
      render action: :edit
    end
  end

  def create
    @custom_field.stable = current_stable
    if @custom_field.save
      redirect_to custom_fields_path
    else
      render action: :new
    end
  end

  def destroy
    @custom_field.destroy
    redirect_to custom_fields_path
  end

  private
  def custom_field_params
    params.require(:custom_field).permit(:name, :tag_type_id, :custom_field_type_id, tag_ids: [])
  end
end
