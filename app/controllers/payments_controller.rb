class PaymentsController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    payment_result = CloudPayment.process(
      user_uid: current_user.cloud_payments_uid,
      amount_cents: params[:amount] * 100,
      currency: 'RUB'
    )

    delivery_result = Sdek.setup_delivery(
      address: current_user.address,
      person:current_user.name,
      weight: product.weight
      )

    if payment_result[:status] == 'completed' && delivery_result[:result] = 'succeed'
      OrderMailer.delivery_email(delivery_result).deliver_later
      redirect_to :successful_payment_path
    else
      redirect_to :failed_payment_path, note: 'Что-то пошло не так'
    end
  end
end
