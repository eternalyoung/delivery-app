class OrderController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    order_result = Order.(params: {
      user: current_user,
      product:,
      payment_gateway: CloudPayment,
      delivery_gateway: Sdek
    })

    if order_result.successful?
      redirect_to :successful_payment_path
    else
      redirect_to :failed_payment_path, note: order_result[:error]
    end
  end
end
