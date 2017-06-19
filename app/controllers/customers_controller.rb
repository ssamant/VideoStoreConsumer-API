class CustomersController < ApplicationController
  SORT_FIELDS = %w(name registered_at postal_code)

  before_action :parse_query_args

  def index
    if @sort
      data = Customer.all.order(@sort)
    else
      data = Customer.all
    end

    data = data.paginate(page: params[:p], per_page: params[:n])

    render json: data.as_json(
      only: [:id, :name, :registered_at, :address, :city, :state, :postal_code, :phone, :account_credit],
      methods: [:movies_checked_out_count]
    )
  end

  def show
    customer = Customer.find_by(id: params[:id])
    if customer
      render json: customer.as_json(
        only: [:id, :name, :registered_at, :address, :city, :state, :postal_code, :phone, :account_credit, :rentals],
        methods: [:movies_checked_out_count],
        include: [:rentals]
      )
    else
      render status: :bad_request, json: { errors: errors }
    end
  end

private
  def parse_query_args
    errors = {}
    @sort = params[:sort]
    if @sort and not SORT_FIELDS.include? @sort
      errors[:sort] = ["Invalid sort field '#{@sort}'"]
    end

    unless errors.empty?
      render status: :bad_request, json: { errors: errors }
    end
  end
end
