module TagHelper

  def limit_tags(tags, stable)

    if current_user.is_employee_b_in_stable?(stable)
     tags = tags.select {|tag| !tag.is_invoice_tag? }
    elsif current_user.is_employee_c_in_stable?(stable)
     tags = tags.select {|tag| !tag.is_invoice_tag? && !tag.is_treatment_tag? }
    elsif current_user.is_vet_in_stable?(stable)
      tags = tags.select {|tag| tag.is_vet_tag? }
    elsif current_user.is_blacksmith_in_stable?(stable)
      tags = tags.select {|tag| tag.is_shoe_tag? }
    end

    tags

  end

end