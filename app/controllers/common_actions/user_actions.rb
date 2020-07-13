module CommonActions
  module UserActions
    ##
    # Returns users in stable. Formatted as hash
    def user_index(stable, since=null)
      user_stable_roles = UserStableRole.where(stable: stable).joins(:user)
      user_stable_roles = user_stable_roles.with_deleted.where('users.public_updated_at > ? OR user_stable_roles.updated_at > ?', DateTime.parse(since), DateTime.parse(since)) if since

      user_stable_roles.includes(:user).map do |user_stable_role|
        latest_updated_at = [user_stable_role.updated_at, user_stable_role.user.public_updated_at].max
        user = user_stable_role.user.as_api_response(:basic)
        user[:updated_at] = latest_updated_at
        user[:role] = user_stable_role.role
        user[:deleted] = !user_stable_role.deleted_at.nil?
        user
      end
    end

    def trainers
      user_stable_roles = UserStableRole.where(role: "trainer").joins(:user).joins(:stable).where(stables: {active: true, stable_type_id: 2})
      user_stable_roles.includes(:user).map do |user_stable_role|

        user = user_stable_role.user.as_api_response(:user_trainer)
        user[:role] = user_stable_role.role
        user[:stable_id] = user_stable_role.stable_id
        user
      end
    end
  end
end
