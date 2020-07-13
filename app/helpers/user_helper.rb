module UserHelper
  def roles_allowed_to_create(user)
    # TODO: Translate roles
    roles_allowed = []
    roles_allowed.push(User::ROLE_TRAINER) if (user.admin? && !user.is_a_trainer?)
    roles_allowed.push(User::ROLE_EMPLOYEE, User::ROLE_EMPLOYEE_B, User::ROLE_EMPLOYEE_C, User::ROLE_EMPLOYEE_D, User::ROLE_VET, User::ROLE_BLACKSMITH) # User::ROLE_OWNER removed from list of possible roles
  end

  def translated_roles_allowed_to_create_as_select(user)

    roles_allowed_to_create(user).map do |role|

      [t("general.#{role}"), role]

    end.to_h

  end

  def translated_role_description_allowed_to_create_as_select(user)
    roles_allowed_to_create(user).map do |role|
      [t("general.#{role}_description"), role]
    end
  end
end