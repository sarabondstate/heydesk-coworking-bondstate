class UpdateCurrentStablesPlanId < ActiveRecord::Migration[5.0]
  def change
  	@stables = Stable.where(plan_id: nil,active: true)
  	@stables.each do |stable_obj|
      stable_obj.plan_id = 3
      stable_obj.save
  	end
  end
end
