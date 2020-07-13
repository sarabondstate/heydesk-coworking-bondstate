class Stable < ApplicationRecord
  acts_as_paranoid
  has_many :users, through: :user_stable_roles
  has_many :user_stable_roles
  has_many :horses
  has_many :tags
  has_many :setup_topics
  has_many :templates
  has_many :custom_fields
  # The order of creating tags and templates is important
  after_create :create_standard_tags
  after_create :create_standard_templates
  after_create :create_standard_my_lists
  after_create :create_standard_setup_topics
  after_create :create_standard_custom_fields
  before_create :set_locale_for_stable
  belongs_to :plan, :required => false
  belongs_to :stable_type, :required => false
  validates_presence_of :name

  #validates_presence_of :telephone

  scope :active, -> { where(active: true) }
  scope :active_n_type_race, -> { where(stable_type_id: 2).active }

  def trainer
    self.users.where(user_stable_roles: {role:'trainer'}).first
  end

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :name
    template.add :country
  end

  api_accessible :all_active_stables, extend: :basic do |template|
    template.add :address
    template.add :plan_id
    template.add :stable_type_id
    template.add :locale
    template.add :active
    template.add :updated_at
    template.add :created_at
    template.add :deleted_at
    template.add :city
    template.remove :country
    template.add :trainer_id
  end

  api_accessible :owner_basic, extend: :basic do |template|
    template.remove :id
  end

  def country
    if self.trainer.nil?
      "DK"
    else
      self.trainer.country || "DK"
    end
  end

  def is_race_stable?
    self.stable_type_id == StableType.find_by(stable_type: 'b').id
  end

  def horses_allow_add
    return (self.active && self.plan && self.plan.max_horses && self.horses.length < self.plan.max_horses) || (self.active && self.plan && !self.plan.max_horses)
  end

  def get_add_horse_status
    @add_horse_status_msg = ""
    @disabled = false
    if self.trainer && self.trainer.stripe_id && self.plan
      unless self.active
        @disabled = true
        @add_horse_status_msg = I18n.t('horses.subscription_is_canceled')
        @remaining_max_horses = -2
      else
        @disabled = self.horses_allow_add ? false : true
        @add_horse_status_msg = I18n.t('horses.reach_max_horses') if @disabled
        @remaining_max_horses = self.plan.max_horses ? self.plan.max_horses - self.horses.count : -3
      end
    else
      @disabled = true
      @add_horse_status_msg = I18n.t('horses.horse_add_select_plan')
      @remaining_max_horses = -1
    end
    return [@disabled,@add_horse_status_msg,@remaining_max_horses]
  end

  def create_missed_templates
    create_standard_templates
  end


  def update_horse_sorting(ids)
    ids.each_with_index do |horse_id, index|
      Horse.where(stable_id: self.id, id: horse_id).each do |h|
        h.sorting = index
        h.save
      end
    end
  end

  def self.to_csv(stables_lst)
    desired_columns = ["Name", "Address","Telephone","Zip","City","Created At","CVR","Horses"]

    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      row = nil
      stables_lst.each do |stable_obj|
        row = stable_obj.attributes.values_at(*desired_columns.map{|wd| wd.downcase.gsub(' ','_')})
        row[desired_columns.count - 1] = stable_obj.horses.size
        csv << row

      end
    end

  end

  private

  def set_locale_for_stable
    self.locale = I18n.locale.to_s
  end

  def create_standard_setup_topics
    self.setup_topics << SetupTopic.new(title: I18n.t('predefined.setup_topics.shoes'))
    self.setup_topics << SetupTopic.new(title: I18n.t('predefined.setup_topics.equipment'))
    self.setup_topics << SetupTopic.new(title: I18n.t('predefined.setup_topics.feed'))
  end

  def create_standard_custom_fields

    def create_for_custom_field(name, tag_type, custom_field_type, tag_names)
      custom_field = CustomField.where(name: I18n.t('predefined.custom_fields.' + name), stable_id: self.id, tag_type: TagType.find_by_title(tag_type), custom_field_type: CustomFieldType.find_by_name(custom_field_type)).first_or_create
      Array(tag_names).each do |tag_name|
        tags = Tag.where(stable: self, tag_name: I18n.t('predefined.tags.' + tag_name))
        tags.each do |tag|
          custom_field.tags << tag unless custom_field.tags.include?(tag)
        end
      end
    end

    create_for_custom_field('pulse', 'training', 'pulse', ['training', 'pulse'])
    create_for_custom_field('temperature', 'training', 'temperature', ['training', 'temperature'])

  end

  def create_standard_my_lists

    def create_for_type(my_list_name, tag_names, icon)
        my_list = MyList.where(title: I18n.t('predefined.my_lists.' + my_list_name), stable_id: self.id, icon: icon).first_or_create
        Array(tag_names).each do |tag_name|
          tags = Tag.where(stable: self, tag_name: I18n.t('predefined.tags.' + tag_name))
          tags.each do |tag|
            my_list.tags << tag unless my_list.tags.include?(tag)
          end
        end
    end

    create_for_type('invoice', ['invoicing'], 'invoice')
    create_for_type('shoes', ['shoes'], 'shoes')
    create_for_type('veterinarian', ['veterinarian'], 'veterinarian')
    create_for_type('treatment', ['treatment'], 'treatment')
  end

  def create_standard_tags
    def create_for_type(type, tags)
      type = TagType.find_by_title(type)
      tags.each do |name|
        Tag.where(tag_name: I18n.t('predefined.tags.' + name), stable: self, tag_type: type).first_or_create
      end
    end

    create_for_type('training', ['training','temperature','pulse'])
    create_for_type('todo', ['treatment','invoicing','veterinarian','shoes','vaccination','worm_treatment'])
    create_for_type('observation', ['did_not_eat_up','fever'])
    # Race (only for race type stable)
    if is_race_stable?
      create_for_type('race', ['invoicing'])
    end
  end

  def create_standard_templates

    def create_for_type(type_name, template_names, tag_names = nil)
      type = TagType.find_by_title(type_name)
      template_names.each do |name|
        template = Template.where(name: (type_name == 'race' ? name : I18n.t('predefined.templates.' + name)), stable: self, tag_type: type).first_or_initialize # 'race' should not be translated
        Array(tag_names).each do |tag_name|
          tag = Tag.where(stable: self, tag_name: I18n.t('predefined.tags.' + tag_name), tag_type: type).first_or_create
          template.tags << tag unless template.tags.include?(tag)
        end
        template.save
      end
    end

    # Training (this is the same for both types of stables)
    create_for_type('training', ['slow','motion','gallop','interval'], ['training','temperature','pulse'])

    # Todo (these are the same for both types of stables)
    create_for_type('todo', ['veterinarian'], ['veterinarian', 'invoicing'])
    create_for_type('todo', ['treatment'], ['treatment', 'invoicing'])
    create_for_type('todo', ['shoes'], ['shoes','invoicing'])
    create_for_type('todo', ['worm_treatment'], ['worm_treatment','invoicing'])
    create_for_type('todo', ['vaccination'], ['vaccination', 'invoicing'])

    # Observation (these are the same for both types of stables)
    create_for_type('observation', ['did_not_eat_up'], ['did_not_eat_up'])
    create_for_type('observation', ['fever'], ['fever'])

    # Race (only for race type stable)
    if is_race_stable?
      create_for_type('race', ['BILLUND TRAV','BORNHOLMS BRAND PARK','NYKØBING F TRAVBANE','CHARLOTTENLUND TRAVBANE','FYENS VÆDDELØBSBANE','JYDSK VÆDDELØBSBANE','KLAMPENBORG GALOPBANE','RACING ARENA AALBORG','SKIVE TRAV','ARVIKA','AXEVALLA','BERGSÅKER','BLOMMERÖD GALOPP','BODEN','BOLLNÄS','BRO PARK  GALOPP','DANNERO','ESKILSTUNA','FÄRJESTAD','GÄRDET GALOPP','GÄVLE','GÖTEBORG GALOPP','HAGMYREN','HALMSTAD','HOTING','JÄGERSRO','JÄGERSRO GALOPP','KALMAR','KARLSHAMN','LINDESBERG','LYCKSELE','MANTORP','OVIKEN','ROMME','RÄTTVIK','SKELLEFTEÅ','SOLVALLA','SOLÄNGET','STRÖMSHOLM  GALOPP','TINGSRYD','UMÅKER','VAGGERYD','VISBY','ÅBY','ÅMÅL','ÅRJÄNG','ÖREBRO','ÖSTERSUND','BERGEN','BIRI','BJERKE','DRAMMEN','FORUS','HARSTAD','JARLSBERG','KLOSTERSKOGEN','LEANGEN','MOMARKEN','SØRLANDET','ØVREVOLL GALOPPBANE'],['invoicing'])
    end
  end
end
