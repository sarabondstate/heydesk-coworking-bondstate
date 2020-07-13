class MyListsController < ApplicationController
  load_and_authorize_resource except: :index


  def index
    @my_lists = MyList.where(stable_id: current_stable).where(user_id: nil)
  end

  def create
    @my_list.stable = current_stable
    if @my_list.save
      redirect_to my_lists_path
    else
      render action: :new
    end
  end

  def update
    if @my_list.update_attributes(my_list_params)
      redirect_to my_lists_path
    else
      render action: :edit
    end
  end

  def destroy
    @my_list.destroy
    redirect_to my_lists_path
  end

  def new

  end

  def edit

  end

  private
  def my_list_params
    params.require(:my_list).permit(:title, :icon, horse_ids: [], tag_ids: [])
  end

end