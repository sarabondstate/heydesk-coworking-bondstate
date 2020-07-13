class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    # Temp make everyone a trainer
    has_max_power = true || user.is_a_trainer? || user.has_trainer_power?

    can :read, Stable, users: {id: user.id}
    can [:update, :is_trainer?], Stable do |stable|
      # Temp make everyone a trainer
      true || user.user_stable_roles.where(stable: stable).where(role: 'trainer').count > 0
    end

    # User can read horse if they can read the stable
    can :read, Horse do |horse|
      result = can? :read, horse.stable
      if user.is_horse_restricted_in_stable?(horse.stable)
        user_stable_role = user.user_stable_roles.where(stable: horse.stable).first
        result = result && (user_stable_role.horses.include? horse)
      end
      result
    end

    # User can read users if they can read the stable
    can :read, User do |u|
      u.stables.any? { |stable|
        can? :read, stable
      }
    end

    can :read, Task do |task|
      result = can? :read, task.stable
      if user.is_employee_b_in_stable?(task.stable)
        result = result && task.emp_b_selected_task?
      elsif user.is_employee_c_in_stable?(task.stable)
        result = result && task.emp_c_selected_task?
      elsif user.is_vet_in_stable?(task.stable)
        result = result && task.has_vet_tags?
      elsif user.is_blacksmith_in_stable?(task.stable)
        result = result && task.has_shoes_tags?
      end
      result
    end

    can :create, Task do |task|
      can? :read, task.stable
    end

    can [:complete], Task do |task|
      can? :read, task
    end

    can :update, Task do |task|
      can? :read, task
    end

    can [:set_avatar], Horse do |horse|
      can? :read, horse
    end

    can [:create, :read, :update, :destroy], MyList do |my_list|
      if my_list.new_record?
        true
      else
        user.stable_access? my_list.stable
      end
    end

    cannot [:create, :update], MyList do |my_list|
      !my_list.horses.all? { |horse|
        can? :read, horse
      }
    end

    can [:read, :create], Comment do |comment|
      can? :read, comment.task
    end

    can :manage, HorseFlag, user_id: user.id


    can [:update, :destroy], Task do |task|
      task.user_id == user.id
    end


    can [:read, :update], HorseSetup do |horse_setup|
      can? :read, horse_setup.horse
    end

    # Trainer stuff
    if has_max_power
      can [:update, :destroy], Task do |task|
        can? :is_trainer?, task.stable
      end
      can [:update, :destroy], UserStableRole do |user_stable_role|
        can? :is_trainer?, user_stable_role.stable
      end
      can [:create, :update], User
      can [:new, :create], Tag
      can [:new, :create], Template
      can [:update, :destroy], Template do |template|
        can? :is_trainer?, template.stable
      end
      can [:new, :create], SetupTopic
      can [:manage], SetupTopic do |setup_topic|
        can? :is_trainer?, setup_topic.stable
      end
      can :manage, Tag do |tag|
        can? :is_trainer?, tag.stable
      end
      can [:new, :create], CustomField
      can [:update, :destroy], CustomField do |custom_field|
        can? :is_trainer?, custom_field.stable
      end
    end
  end
end
