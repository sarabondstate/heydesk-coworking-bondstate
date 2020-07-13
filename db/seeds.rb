# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

require "#{Rails.root}/app/helpers/horses_tag_updates.rb"
require "#{Rails.root}/app/helpers/model_notifies.rb"

CustomField.delete_all
CustomFieldType.delete_all
TagType.delete_all
Stable.delete_all
User.delete_all
# Employee.delete_all
# ExternalEmployee.delete_all
Trainer.delete_all
Horse.delete_all
CommonHorse.delete_all
Product.delete_all
Task.delete_all
Plan.delete_all
StableType.delete_all
PushNotification.delete_all

#Add Plans
Plan.add_bulk

#Add Stable types
StableType.add_bulk


#Products
p = []
p[0] = Product.create!(country: '', price: 3840, vat: 960)
p[1] = Product.create!(country: 'DK', price: 3840, vat: 960)
p[2] = Product.create!(country: 'NO', price: 3840, vat: 960)
p[3] = Product.create!(country: 'SE', price: 3840, vat: 960)

# Tag types
typetraining = TagType.create!(title: 'training')
typerace = TagType.create!(title: 'race')
typeobservation = TagType.create!(title: 'observation')
typetodo = TagType.create!(title: 'todo')

CustomFieldType.create([{name: 'temperature', number_of_inputs: 1},{name: 'pulse', number_of_inputs: 2}])

stables=Stable.create!([{name:"test stald", address:"gadenavn 1", zip:"5000", city:"Odense C", telephone:"31432009", active:true, cvr: "36030410"}, {name:"test stald1", address:"Edisonsvej 2", zip:"5000", city:"Odense C", telephone:"72170220", cvr: "36030410"}])

emp = nil
@push_flagged_horse_observation = false
for i in 1..5
  if @push_flagged_horse_observation 
    @push_flagged_horse_observation = false
  else
    @push_flagged_horse_observation = true
  end
  e=User.create!({email:"emp"+i.to_s + "@stable.dk",firstname:"Employee ",lastname:"Gut " + i.to_s, name:"Employee Gut " + i.to_s , password:"testeren", password_confirmation:"testeren", address: "Edisonsvej 2", phone: "72170220", zip: "5000", city: "Odense C", country: "Denmark", push_enabled: true, push_flagged_horse_observation: @push_flagged_horse_observation})
  e.user_stable_roles << UserStableRole.new(stable: stables.first, role: 'employee')
  e=User.create!({email:"emp1_"+i.to_s + "@stable.dk",firstname:"Employee ",lastname:"Gut 1_" + i.to_s, name:"Employee Gut 1_" + i.to_s , password:"testeren", password_confirmation:"testeren", address: "Edisonsvej 2", phone: "72170220", zip: "5000", city: "Odense C", country: "Denmark", push_enabled: true})
  e.user_stable_roles << UserStableRole.new(stable: stables.last, role: 'employee')
  emp = e
end

#ee=User.create!({email:"ex@stable.dk", name:"Smeden", password:"testeren", password_confirmation:"testeren", address: "Edisonsvej 2", phone: "72170220", zip: "5000", city: "Odense C", country: "Denmark"})
#ee.user_stable_roles << UserStableRole.new(stable: stables.first, role: 'external_employee')
#ee.user_stable_roles << UserStableRole.new(stable: stables.last, role: 'external_employee')

t=User.create!({email:"trainer@stable.dk",firstname:"Træner ",lastname:"1", name:"Træner 1", password:"testeren", password_confirmation:"testeren", admin: true, address: "Edisonsvej 2", phone: "72170220", zip: "5000", city: "Odense C", country: "Denmark", push_enabled: true})
t.user_stable_roles << UserStableRole.new(stable: stables.first, role: 'trainer')
t0=User.create!({email:"trainer0@stable.dk",firstname:"Træner ",lastname:"0", name:"Træner 0", password:"testeren", password_confirmation:"testeren", admin: true, address: "Edisonsvej 2", phone: "72170220", zip: "5000", city: "Odense C", country: "Denmark", push_enabled: true,push_all_horse_observation: true})
t0.user_stable_roles << UserStableRole.new(stable: stables.first, role: 'trainer')
t1=User.create!({email:"trainer1@stable.dk",firstname:"Træner ",lastname:"2", name:"Træner 2", password:"testeren", password_confirmation:"testeren", address: "Edisonsvej 2", phone: "72170220", zip: "5000", city: "Odense C", country: "Denmark", push_enabled: true})
t1.user_stable_roles << UserStableRole.new(stable: stables.last, role: 'trainer')


#Common_horses
ch = []
ch[0] = CommonHorse.create!(gender: 'hp', name: 'Eternal Shadow', registration_number: '0S0364', nationality: 'DK', sportsinfo_trainer_id: '2', sportsinfo_id: 1)
ch[1] = CommonHorse.create!(gender: 'hp', name: 'Eye of the Tiger', registration_number: '0S0037', nationality: 'DK', sportsinfo_trainer_id: '2', sportsinfo_id: 2)
ch[2] = CommonHorse.create!(gender: 'h', name: 'Elektra Dilli', registration_number: '0S0084', nationality: 'DK', sportsinfo_trainer_id: '1', sportsinfo_id: 3)
ch[3] = CommonHorse.create!(gender: 'v', name: 'Erbium Flame', registration_number: '0S0024', nationality: 'DK', sportsinfo_trainer_id: '1', sportsinfo_id: 4)

#Horses
h = []
h[0] = Horse.create!(stable: stables.first, common_horse: ch.first)
h[1] = Horse.create!(stable: stables.first, common_horse: ch[1])
h[2] = Horse.create!(stable: stables.last, common_horse: ch[2])
h[3] = Horse.create!(stable: stables.last, common_horse: ch[3])


# Tasks
# for i in 0..3
#   for y in (0..100).step(5)
#     TodoTask.create!.build_task(title:"todo task #{y.to_s}",type:typetodo,user:emp,stable: h[i].stable,horse: h[i], date: (Date.yesterday + y.days), note: 'javsa').save!
#     TrainingTask.create!.build_task(title:"training task #{y.to_s}",type:typetraining,user:emp,stable: h[i].stable,horse: h[i], date: (Date.yesterday + y.days), note: 'javsa').save!
#     ObservationTask.create!.build_task(title:"observation task #{y.to_s}",type:typeobservation,user:emp,stable: h[i].stable,horse: h[i], date: (Date.yesterday + y.days + 1), note: 'javsa').save!
#     ObservationTask.create!.build_task(title:"observation task #{y.to_s} no horse",type:typeobservation,user:emp,stable: h[i].stable, date: (Date.yesterday + y.days + 1), note: 'no horse').save!
#   end
# end

