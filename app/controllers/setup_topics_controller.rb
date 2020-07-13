class SetupTopicsController < ApplicationController
  load_and_authorize_resource except: :index

  def index
    @setup_topics = current_stable.setup_topics
  end

  def new
  end

  def edit
  end

  def update
    if @setup_topic.update_attributes(setup_topic_params)
      redirect_to setup_topics_path
    else
      render action: :edit
    end
  end

  def create
    @setup_topic.stable = current_stable
    if @setup_topic.save
      redirect_to setup_topics_path
    else
      render action: :new
    end
  end

  def destroy
    @setup_topic.destroy
    redirect_to setup_topics_path
  end

  private
  def setup_topic_params
    params.require(:setup_topic).permit(:title)
  end
end
