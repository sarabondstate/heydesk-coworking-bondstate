class Plan < ApplicationRecord
	
  has_many :stables

  def self.add_bulk
  	begin
		if all.length == 0
	      list = []
	      plan_params = {id: 1, min_horses: 1, 
	                     max_horses: 3, 
	                     details: "a",
	                     price: 8, vat: 1.6 }
	      list << plan_params

	      plan_params = {id: 2,min_horses: 4,
	                     max_horses: 9, 
	                     details:  "b",
	                     price: 24, vat: 4.8 }
	      list << plan_params

	      plan_params = {id: 3,min_horses: 10, 
	                     max_horses: nil, 
	                     details:  "c",
	                     price: 48, vat: 9.6 }
	      
	      list << plan_params
		  list.each {|passed_params|
		      new(passed_params).save
	        }
	    else
	      Plan.find_by(details: "a").update(vat: 1.6) if Plan.find_by(details: "a").vat == nil
	      Plan.find_by(details: "b").update(vat: 4.8) if Plan.find_by(details: "b").vat == nil
	      Plan.find_by(details: "c").update(vat: 9.6) if Plan.find_by(details: "c").vat == nil
		end
	rescue
	end
	return true
  end

end
