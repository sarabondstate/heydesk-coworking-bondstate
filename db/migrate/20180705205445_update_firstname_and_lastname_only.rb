class UpdateFirstnameAndLastnameOnly < ActiveRecord::Migration[5.0]
  def change
  	@users = User.all
  	@users.each do |user_obj|
  	  begin
        name = user_obj.name
        values = name.split(" ")
	    firstname = values.delete_at(0)
	    lastname = values.join(' ').squeeze(' ')
	    user_obj.firstname = firstname
	    user_obj.lastname = lastname.blank? ? "." : lastname
	    user_obj.save(touch: false)
	  rescue
	  end
  	end
    
  end
end
