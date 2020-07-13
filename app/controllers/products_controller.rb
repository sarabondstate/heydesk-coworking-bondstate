class ProductsController < ApplicationController
  load_and_authorize_resource except: :index

  def index
    @products = Product.all
  end

  def new
  end

  def edit
  end

  def update
    if @product.update_attributes(product_params)
      redirect_to products_path
    else
      render action: :edit
    end
  end

  def create
    if @product.save
      redirect_to products_path
    else
      render action: :new
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path
  end

  private
  def product_params
    params.require(:product).permit(:country, :price, :vat)
  end
end
