class CategoriesController < ApplicationController
  def index
    @category = Category.includes(:loan_requests).all
  end

  def show
    @category = Category.includes(:loan_requests).find(params[:id])
  end
end
