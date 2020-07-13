class Comment < ApplicationRecord
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :tagged_users, class_name: 'User', autosave: true
  belongs_to :user
  belongs_to :task

  before_save :save_tagged_users
  model_notifies 'tagged_users', 'user'

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :text
    template.add :task_id
    template.add 'user_id', as: :created_by
    template.add :tag_ids
    template.add 'task.type.title', as: :task_type
    template.add :tagged_users, template: :simple
    template.add :created_at
    template.add :updated_at
  end

  api_accessible :basic_with_type, extend: :basic do |template|
    template.add 'class.to_s', as: :class_type
  end

  private
  ##
  # Parse text, and saves the persons
  def save_tagged_users
    # Regex explanation
    # We need to match all occurrences of [u=123]text[/u]
    # \[u=(\d+)\] matches [u=123] and makes a reference to 123
    # [^\[]* matches all characters except [
    # \[\/u\] simply matches [/u]
    users = text.scan(/\[u=(\d+)\][^\[]*\[\/u\]/).flatten.map do |id_as_string|
      User.find(id_as_string)
    end
    self.tagged_users = users
  end
end
