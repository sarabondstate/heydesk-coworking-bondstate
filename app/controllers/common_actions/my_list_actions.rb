module CommonActions
  module MyListActions

    include MyListHelper

    ##
    # Returns my lists in stable.
    def my_lists_index(stable, user)
      my_lists = MyList.where(stable_id: stable.id, user_id: nil).or(MyList.where(user_id: user.id))

      my_lists = limit_my_lists(my_lists, stable)

      return my_lists.map {|my_list|
        {
            id: my_list.id,
            title: my_list.title,
            horses: my_list.horses.pluck(:id),
            tags: my_list.tags.pluck(:id),
            predefined: my_list.is_predefined?(my_list),
            created_at: my_list.created_at,
            updated_at: my_list.updated_at,
            icon_url: (my_list.icon.nil? ? '' : 'http://'+request.host+'/assets/'+my_list.icon+'.png')
        }
      }
    end
  end
end
