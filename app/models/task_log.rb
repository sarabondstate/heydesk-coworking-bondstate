class TaskLog < ApplicationRecord
  belongs_to :task

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :task_id
    template.add :user_id
    template.add :key
    template.add :from
    template.add :to
    template.add :custom_name
    template.add :created_at
    template.add :updated_at
  end

end
