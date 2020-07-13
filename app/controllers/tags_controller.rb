class TagsController < ApplicationController
  load_and_authorize_resource except: :index

  def index
    @tags = current_stable.tags.where.not(tag_type_id: 5)
  end

  def new
  end

  def edit
  end

  def update
    if @tag.update_attributes(tag_params)
      redirect_to tags_path
    else
      render action: :edit
    end
  end

  def create
    @tag.stable = current_stable
    if @tag.save
      redirect_to tags_path
    else
      render action: :new
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_path
  end

  private
  def tag_params
    params.require(:tag).permit(:tag_name, :tag_type_id)
  end
end
