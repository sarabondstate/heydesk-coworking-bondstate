class UpdateHorseGenders < ActiveRecord::Migration[5.0]
  def change

    # Common horse now has a before_save that streamlines the gender of a horse, but existing horses should also be updated

    CommonHorse.where(gender: 'Hoppe').update_all(gender: 'mare')
    CommonHorse.where(gender: 'hp').update_all(gender: 'mare')

    CommonHorse.where(gender: 'Hingst').update_all(gender: 'stallion')
    CommonHorse.where(gender: 'h').update_all(gender: 'stallion')

    CommonHorse.where(gender: 'Vallak').update_all(gender: 'gelding')
    CommonHorse.where(gender: 'v').update_all(gender: 'gelding')

  end
end
