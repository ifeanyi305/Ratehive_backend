class Api::V1::FeeRangesController < ApplicationController
  skip_before_action :authenticate_request, only: %i[index]
  before_action :check_admin, only: %i[create update_fee delete_fee]
  before_action :check_params, only: %i[create update_fee delete_fee]

  # Endpoint to get the fees for all price range
  def index
    @transaction_fees = FeeRange.order(:fee)

    render json: { data: @transaction_fees }, status: :ok
  end

  # Endpoint to create a new transaction fee for a given price range
  def create
    @transaction_fee = FeeRange.new(fee_params)
    if @transaction_fee.start_price > @transaction_fee.end_price
      return render json: { message: 'Start price cannot be greater than End price' },
                    status: :not_acceptable
    end

    if @transaction_fee.save
      render json: { message: 'Fee added successfully' }, status: :created
    else
      render json: { message: 'Fee creation failed', error: @transaction_fee.errors }, status: :unprocessable_entity
    end
  end

  # Endpoint to update transaction fee for a given price range
  def update_fee
    start_price = params[:data][:start_price]
    end_price = params[:data][:end_price]
    @fee_range = FeeRange.find_by(start_price:, end_price:)

    if @fee_range.present?
      @fee_range.fee = params[:data][:fee]
      @fee_range.save!
      render json: {
               message: "Transaction Fee for #{start_price} to #{end_price} Updated successfully"
             },
             stauts: :ok
    else
      render json: { message: 'No transaction fee for that price range' }, status: :not_found
    end
  end

  # Endpoint to delete transaction fee for a given price range
  def delete_fee
    start_price = params[:data][:start_price]
    end_price = params[:data][:end_price]
    @fee_range = FeeRange.find_by(start_price:, end_price:)

    if @fee_range.present?
      @fee_range.destroy!
      render json: {
               message: "Transaction Fee for #{start_price} to #{end_price} deleted successfully"
             },
             stauts: :ok
    else
      render json: { message: 'No transaction fee for that price range' }, status: :not_found
    end
  end

  private

  def fee_params
    params.require(:data).permit(:start_price, :end_price, :fee)
  end

  def check_params
    return unless !params[:data][:start_price] || !params[:data][:end_price] || !params[:data][:fee]

    render json: { message: 'You must provide start_price, end_price, and fee to complete this action' },
           status: :not_acceptable
  end
end
