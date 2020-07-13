class Product < ApplicationRecord
  # Returns the price on the only available product. Without tax in DKK
  def full_price
    self.price + self.vat
  end
end
