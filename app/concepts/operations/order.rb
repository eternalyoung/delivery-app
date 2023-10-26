class Order < Trailblazer::Operations
  step :purchase_via_payment_gateway
  step :validate_purchase_result
  step :delivery_via_delivery_gateway
  step :validate_delivery_result
  step :create_delivery_record
  failure :error!
  step :notify_user

  def purchase_via_payment_gateway(options, params)
    options[:payment_result] = params[:payment_gateway].process(
      user_uid: params[:user].payment_getaway_uid,
      amount_cents: params[:product].amount_cents,
      currency: 'RUB'
    )
  end

  def validate_purchase_result(options, params)
    options[:payment_result].successful?
  end

  def delivery_via_delivery_gateway(options, params)
    options[:delivery_result] = params[:delivery_gateway].setup_delivery(
      address: current_user.address,
      person:current_user.name,
      weight: product.weight
      )[:result]
  end

  def validate_delivery_result(options, params)
    options[:delivery_result].successful?
  end

  def create_delivery_record(options, params)
    options[:delivery_record] = Delivery.create(
      user: params[:user],
      product: params[:params]
    )
  end

  def error!(options, params)
    options["error"] = "Something went wrong with user's id#{params[:user].id} order on product id#{params[:product_id]}!"
  end
 
  def notify_user(options, params)
    OrderMailer.delivery_email(options[:delivery_record]).deliver_later
  end
end
