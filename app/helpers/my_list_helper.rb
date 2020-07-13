module MyListHelper
  def predefined_icons()
    icons = []
    icons.push('invoice')
    icons.push('shoes')
    icons.push('veterinarian')
    icons.push('treatment')
  end

  def translated_predefined_icon_to_create_as_select()
    predefined_icons().map do |icon|
      [t("predefined.my_lists.#{icon}"), icon]
    end.to_h
  end

  def limit_my_lists(my_lists, stable)

    if current_user.is_employee_b_in_stable?(stable)
      my_lists = my_lists.select {|my_list| !my_list.has_invoice_tags? }
    elsif current_user.is_employee_c_in_stable?(stable)
      my_lists = my_lists.select {|my_list| !my_list.has_invoice_tags? && !my_list.has_treatment_tags? }
    elsif current_user.is_vet_in_stable?(stable)
      my_lists = my_lists.select {|my_list| my_list.has_vet_tags? }
    elsif current_user.is_blacksmith_in_stable?(stable)
      my_lists = my_lists.select {|my_list| my_list.has_shoes_tags? }
    end

    my_lists

  end

end