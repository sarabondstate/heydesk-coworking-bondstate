module HorseHelper
  def translated_horse_genders_as_select()
    horses = []
    horses.push([t('genders.stallion'), 'stallion'], [t('genders.mare'), 'mare'], [t('genders.gelding'), 'gelding'])
  end

  def limit_horses(horses, stable)

    if current_user.is_horse_restricted_in_stable?(stable)
      user_stable_role = current_user.user_stable_roles.where(stable: stable).first
      horse_ids = user_stable_role.horses.pluck(:id)
      horses = horses.select  {|horse| horse_ids.include? horse.id }
    end

    horses

  end

end