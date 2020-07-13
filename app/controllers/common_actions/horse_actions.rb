module CommonActions
  module HorseActions

    include HorseHelper
    ##
    # Returns horses in stable. It includes user_flagged. Formatted as hash
    # Params:
    # - stable: Stable to get horses from
    # - since: Defaults to nil
    # - include_inactive: Should disabled horses be displayed
    def horse_index(stable, since=nil, include_inactive=false)
      horses = stable.horses.with_deleted #.includes(:horse_flags).where(horse_flags: {user_id: [current_user.id, nil]})
      if !include_inactive
        horses = horses.where(active: true)
      end
      #horses = horses.where('horses.updated_at > ? OR horse_flags.updated_at > ?', DateTime.parse(since), DateTime.parse(since)) if since
      horses = horses.order('horses.sorting ASC')
      horses = horses.includes(:common_horse).merge(CommonHorse.order('common_horses.name ASC'))
      horses = limit_horses(horses, stable)

      horses = horses.as_api_response(:basic)
      user_flagged = current_user.horse_flags.select(:horse_id, :updated_at)#.pluck(:horse_id)
      user_flagged = Hash[*user_flagged.map{ |x| [x.horse_id, x] }.flatten]
      horses.map do |horse|
        horse[:user_flagged] = false
        if user_flagged.has_key?(horse[:id])
          horse[:user_flagged] = true
          horse[:updated_at] = [horse[:updated_at], user_flagged[horse[:id]].updated_at].max
        end
        horse
      end
      return horses
    end
  end
end
