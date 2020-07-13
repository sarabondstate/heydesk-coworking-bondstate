module ApplicationHelper
  def menu_item(name, url = nil)

    str = '<li class="nav-item">
      <a class="nav-link" href="'+(url ? url : '/'+url_for(name))+'">'+translate('menu.'+name)+'</a>
    </li>'

    return str.html_safe
  end

  # Icons. See https://useiconic.com/open for available icons
  def icon(name, title='')
    str = '<span class="oi oi-'+name+'" title="'+title+'" aria-hidden="true"></span>'
    return str.html_safe
  end

  def convert_list_of_objects_to_json(objects)
    converted_objects = {}
    objects.each do |object|
      converted_objects[object.class.to_s.downcase.pluralize] = [] unless converted_objects.include?(object.class.to_s.downcase.pluralize)
      if object.is_a?(Task)
        @media_type = object.task_images.first.image_content_type.include?("video") ? "video" : "image" rescue "no attachment"
        converted_objects[object.class.to_s.downcase.pluralize] << object.task_hash_with_extra_info(current_user, @media_type)
      else
        converted_objects[object.class.to_s.downcase.pluralize] << object.as_api_response(:basic)
      end
    end

    return converted_objects
  end

  def tag_types_and_tags_as_json
    tag_types = TagType.all.index_by(&:id)
    tag_types.each_key do |title|
      tag_types[title] = tag_types[title].tags.where(stable: current_stable).order(:tag_name)
    end.to_json
  end

  def tags_with_type
    tags_with_type_arr = []
    current_stable.tags.where.not(tag_type_id: 5).each do |t|
      t.tag_name = t.tag_name + ' ('+translate('types.'+t.tag_type.title)+')'
      tags_with_type_arr.push(t)
    end
    return tags_with_type_arr
  end

  def sign_up_products_as_json
    #products = Product.all.index_by(&:country).to_json
    products = Product.all
    converted_products = {}
    products.each do |p|
      converted_products[p.country] = {
          'price' => number_to_currency(p.price/100, locale: country_to_locale(p.country)),
          'vat' => number_to_currency(p.vat/100, locale: country_to_locale(p.country)),
          'full' => number_to_currency(p.full_price/100, locale: country_to_locale(p.country))
      }
    end
    return converted_products.to_json
  end

  # Supercharged improved turbo translate method (tt)
  # Replaces new line with <br />
  def translate(str, options = {})
    raw I18n.t(str).gsub(/\n/, '<br />')
  end

  def country_to_locale(country)
    case country
      when 'DK'
        locale = 'da'
      when 'SE'
        locale = 'se'
      when 'NO'
        locale = 'no'
      else
        locale = 'en'
    end
    return locale
  end

  def locale_to_country(locale)
    case locale.to_s
      when 'da'
        country = 'DK'
      when 'se'
        country = 'SE'
      when 'no'
        country = 'NO'
      else
        country = ''
    end
    return country
  end

  def plan_disabled(plan)
    if current_user
      if(current_stable.plan_id)
        return true if current_stable.plan_id == plan.id
      end
      number_of_horses = current_stable.horses.length
      return true if plan.max_horses && number_of_horses > plan.max_horses #disabled
    end
    return false
  end

  def current_selected_plan(plan)
    if current_user && current_stable.plan_id
        return true if current_stable.plan_id == plan.id
    end
    return false
  end

end
