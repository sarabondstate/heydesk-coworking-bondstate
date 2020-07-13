include HorsesTagUpdates
class Task < ApplicationRecord
  acts_as_paranoid
  belongs_to :taskable, polymorphic: true
  has_many :comments, dependent: :destroy
  has_many :task_logs, dependent: :destroy
  has_and_belongs_to_many :tags
  belongs_to :horse
  belongs_to :stable
  belongs_to :user
  belongs_to :completed_by, class_name: 'User', foreign_key: :completed_by_id
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by_id
  belongs_to :type, class_name: 'TagType'
  has_many :custom_field_values
  has_many :task_images, dependent: :destroy
  accepts_nested_attributes_for :custom_field_values

  validates_presence_of :user
  validates_presence_of :stable

  before_save :make_sure_observations_are_completed
  after_update :write_task_logs

  #default_scope { includes(:custom_field_values) }
  updates_horses_tag
  model_notifies 'stable.users', 'user' do |method, task|
    # Only notify if an observation is created
    task.type.title == 'observation'
  end

  after_save :set_permissions

  def has_treatment_tags?
    self.tags.where(tag_name: Tag.tag_treatment(self.stable.locale.to_sym)).count > 0
  end

  def has_vet_tags?
    self.tags.where(tag_name: [Tag.tag_treatment(self.stable.locale.to_sym), Tag.tag_vet(self.stable.locale.to_sym)]).count > 0
  end

  def has_shoes_tags?
    self.tags.where(tag_name: Tag.tag_shoe(self.stable.locale.to_sym)).count > 0
  end

  def has_invoice_tags?
    self.tags.where(tag_name: [Tag.tag_invoice(self.stable.locale.to_sym), Tag.tag_invoicing(self.stable.locale.to_sym)]).count > 0
  end

  def has_invoice_tags_but_not_race_task?
    if (self.type.title != 'race')
      self.tags.where(tag_name: Tag.tag_invoice(self.stable.locale.to_sym)).count > 0
    else
      true
    end
  end

  def has_training_tags?
    self.tags.where(tag_name: [Tag.tag_training(self.stable.locale.to_sym)]).count > 0
  end

  def emp_b_selected_task?
    self.permission & User::PERMISSION_BITMAP_EMPLOYEE_B > 0
  end

  def emp_c_selected_task?
    self.permission & User::PERMISSION_BITMAP_EMPLOYEE_C > 0
    #return !has_treatment_tags? && (self.type.title == 'race' || (self.type.title != 'race' && !has_invoice_tags?))
  end

  def self.select_tasks(tasks, stable, user)
    starttime = DateTime.now
    DeveloperMessage.new_message(self.class, "select_tasks: Starting to select tasks")
    user_permission = user.get_permission(stable)

    tasks = tasks.where("permission & ? > 0", user_permission)

    if user.is_horse_restricted_in_stable?(stable)
      user_stable_role = user.user_stable_roles.where(stable: stable).first
      horse_ids = user_stable_role.horses.pluck(:id)
      tasks = tasks.where("horse_id  IN (?)", horse_ids)
    end

    DeveloperMessage.new_message(self.class, "select_tasks: Done selecting tasks, took #{DateTime.now.to_i - starttime.to_i} seconds")

    tasks
  end

  def self.select_tasks_for_empD(tasks, stable, user)
    starttime = DateTime.now
    DeveloperMessage.new_message(self.class, "select_tasks: Starting to select tasks")
    user_permission = user.get_permission(stable)

    tasks = tasks.where("permission > ?", user_permission)

    if user.is_horse_restricted_in_stable?(stable)
      user_stable_role = user.user_stable_roles.where(stable: stable).first
      horse_ids = user_stable_role.horses.pluck(:id)
      tasks = tasks.where("horse_id  IN (?)", horse_ids)
    end

    DeveloperMessage.new_message(self.class, "select_tasks: Done selecting tasks, took #{DateTime.now.to_i - starttime.to_i} seconds")

    tasks
  end

  def as_hash_with_extra_info(user)
    task = self.as_api_response(:basic)
    wa = Ability.new(user).can? :update, self
    task[:write_access] = wa
    task
  end

  def task_hash_with_extra_info(user, media_type)
    task = self.as_api_response(:basic)
    wa = Ability.new(user).can? :update, self
    task[:write_access] = wa
    task[:media_type] = media_type
    task
  end

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :horse_id
    template.add :stable_id
    template.add :title
    template.add proc {|t| !t.completed_at.nil?}, as: :completed
    template.add :completed_by_id, as: :completed_by
    template.add :updated_by_id, as: :updated_by
    template.add :completed_at
    template.add :date
    template.add proc{|t| t.time.try(:to_s, :time)}, as: :time
    template.add :note

    template.add :internal_note
    template.add 'user_id', as: :created_by
    template.add :tag_ids
    template.add 'type.title', as: :type
    template.add 'task_images', as: :task_image, template: :basic
    template.add :images_lst

    template.add :permission

    # Not used at the moment
    #template.add :taskable_type, as: :type
    #template.add :taskable, as: :type_specific

    template.add :created_at
    template.add :updated_at
    template.add proc {|t| !t.deleted_at.nil?}, as: :deleted
    template.add :custom_field_values, :template => :basic
  end

  api_accessible :basic_with_type, extend: :basic do |template|
    template.add 'class.to_s', as: :class_type
  end

  api_accessible :basic_for_my_plan, extend: :basic do |template|
    template.add :write_access
    template.add :media_type
  end

  api_accessible :owner_basic, extend: :basic do |template|
    template.remove :stable_id
    template.remove :internal_note
    template.remove :deleted
    template.add :horse, template: :owned_horse
    template.add :stable
  end

  api_accessible :owned_horse_tasks do |template|
    template.add :id
    template.add :horse_id
    template.add :title
    template.add :completed_by_id, as: :completed_by
    template.add :updated_by_id, as: :updated_by
    template.add :completed_at
    template.add :date
    template.add 'user_id', as: :created_by
    template.add 'type.title', as: :type
    template.add :created_at
    template.add :updated_at
    template.add :note
    template.add :internal_note
    template.add :time
    template.add :horse, template: :owned_horse
    template.add :task_images, template: :basic
  end

  api_accessible :mto_basic do |template|
    template.add :id
    template.add :title
    template.add :note
    template.add :internal_note
    template.add 'user_id', as: :created_by
    template.add :task_images, template: :basic
    template.add :created_at
  end

  def images_lst
    # Dont seem like we are using TaskImage anywhere. So just return []
    []
    # Otherwise we will use this faster rendering:
    #self.task_images.as_api_response(:basic)

    ## Instead of the original below

    # imgs_lst = []
    # begin
    #   task_imgs_objs =  self.task_images#TaskImage.where(task_id: id)
    #   if(task_imgs_objs.length > 0)
    #     task_imgs_objs.each do |img|
    #       imgs_lst << img.as_api_response(:basic)
    #       end
    #   end
    # rescue
    # end
    # imgs_lst
  end

  def write_access
    return true
  end

  def media_type
    @media_type = self.task_images.first.image_content_type.include?("video") ? "video" : "image" rescue "no attachment"
  end

  # Should be run before modifying tags
  def before_modify_tags
    # Save a list of tags
    @oldTags = self.tags.map {|f| f}
  end

  # Should be run after modifying tags
  def after_modify_tags
    if @oldTags.sort != self.tags.sort
      # If tags have changed, then save to log
      log_write('tags', @oldTags.pluck(:tag_name).join(', '), self.tags.pluck(:tag_name).join(', '));
    end
  end

  # Should be run before modifying custom field values
  def before_modify_custom_fields
    @oldCustomFieldsValues = {}
    # Save a list of custom field values
    self.custom_field_values.each do |f|
      @oldCustomFieldsValues[f.id] = f.attributes
    end
  end

  # Should be run after modifying custom fields
  def after_modify_custom_fields
    self.custom_field_values.each do |c|
      if @oldCustomFieldsValues.key?(c.id)
        # If custom field already exists, then check if value_one or value_two have changed
        log_write('custom_field1', @oldCustomFieldsValues[c.id]['value_one'], c.value_one, c.custom_field.name);
        log_write('custom_field2', @oldCustomFieldsValues[c.id]['value_two'], c.value_two, c.custom_field.name);
      else
        # If custom field does not exist, then create a log entry for that
        log_write('custom_field1', '', c.value_one, c.custom_field.name);
        unless c.value_two.blank?
          log_write('custom_field2', '', c.value_two, c.custom_field.name);
        end
      end
    end
  end

  ##
  # Sets the permission property of a task based on tags
  def set_permissions
    invoice = self.type.title == 'race' ? "1" : "0"
    race = self.type.title != 'race' ? "1" : "0"
    # invoice = has_invoice_tags? ? "1" : "0"
    training = has_training_tags? ? "1" : "0"
    vet = has_vet_tags? ? "1" : "0"
    treatment = has_treatment_tags? ? "1" : "0"
    shoes = has_shoes_tags? ? "1" : "0"

    permission_string = invoice + race + training + vet + treatment + shoes
    permission = permission_string.to_i(2)

    self.update_columns(permission: permission)
  end

  private
  def make_sure_observations_are_completed
    if self.type.title == 'observation' and self.completed_at.nil?
      self.completed_at = DateTime.now
      self.completed_by = self.user
    end
  end

  # Write changes to log after task is saved
  def write_task_logs

    log_write('title', self.title_was, self.title);
    log_write('note', self.note_was, self.note);
    log_write('internal_note', self.internal_note_was, self.internal_note);
    log_write('date', self.date_was, self.date);
    log_write('time', (self.time_was.nil? ? '' : self.time_was.strftime("%H:%M")), (self.time.nil? ? '' : self.time.strftime("%H:%M")));
    log_write('completion', (self.completed_at_was.nil? ? 'false' : 'true'), (self.completed_at.nil?  ? 'false' : 'true'));

    if self.horse_id_changed?
      old_horse_name = ''
      new_horse_name = ''
      old_horse = nil
      new_horse = nil

      old_horse = Horse.find(self.horse_id_was) unless self.horse_id_was.nil?
      new_horse = Horse.find(self.horse_id) unless self.horse_id.nil?

      old_horse_name = old_horse.common_horse.name unless old_horse.nil?
      new_horse_name = new_horse.common_horse.name unless new_horse.nil?

      if old_horse_name != new_horse_name
        log_write('horse', old_horse_name, new_horse_name);
      end
    end

  end

  def log_write(key, from, to, custom_name = nil)
    from.try(:strip!)
    to.try(:strip!)
    if from != to
      task_updated_user_id = updated_by ? updated_by.id : user.id
      TaskLog.create(task_id: self.id, user_id: task_updated_user_id, key: key, from: from, to: to, custom_name: custom_name)
    end
  end

end
