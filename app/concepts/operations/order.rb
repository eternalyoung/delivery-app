class Order < Trailblazer::Operations
  step :purchase_by_gateway
  step :validate_purchase_result
  step :deliver_by_gateway
  step :validate_delivery_result
  failure :error!
  step :notify_user

  def purchase_by_gateway(options, params)
    options[:payment_result] = payment_gateway.process(
      user_uid: params[:user].cloud_payments_uid,
      amount_cents: params[:product].amount_cents,
      currency: 'RUB'
    )
  end

  def validate_purchase_result(options, params)
    options[:payment_result].successful?
  end

  def deliver_by_gateway(options, params)
    options[:delivery_result] = delivery_gateway.setup_delivery(
      address: current_user.address,
      person:current_user.name,
      weight: product.weight
      )[:result]
  end

  def validate_delivery_result(options, params)
    options[:delivery_result].successful?
  end

  def error!(options, params)
    options["error"] = "Something went wrong with order on product #{params[:product_id]}!"
  end
 
  def notify_user(options, params)
    OrderMailer.product_access_email(options[:product_access]).deliver_later
    OrderMailer.delivery_email(options[:delivery_result]).deliver_later
  end

  def payment_gateway
    CloudPayment
  end

  def delivery_gateway
    Sdek
  end
end
