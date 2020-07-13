class StableType < ApplicationRecord

  has_many :stables

  def self.add_bulk
		if all.length == 0
	      list = []
	      types_params = { id: 1, stable_type: "a" }
	      list << types_params

	      types_params = { id: 2, stable_type: "b" }
	      list << types_params

		  list.each {|passed_params|
		      new(passed_params).save
	        }
		end
	return true
  end

end
