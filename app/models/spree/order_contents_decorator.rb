Spree::OrderContents.class_eval do

  private
  #this whole thing needs a refactor!

  def add_to_line_item(variant, quantity, options = {})
    line_item = grab_line_item_by_variant(variant, false, options)

    line_item ||= order.line_items.new(
      quantity: 0,
      variant: variant,
    )

    line_item.quantity += quantity.to_i
    puts "----- Inside OrderContents class_eval flexi variants"
    puts "options are #{options}"

    ###### HACK FOR FIXING .with_indifferent_access is undefined
    options2 = {}
    options2['ad_hoc_option_values'] = options['ad_hoc_option_values'] if options['ad_hoc_option_values']
    options2['product_customizations'] = options['product_customizations'] if options['product_customizations']
    options2['customization_price'] = options['customization_price'] if options['customization_price']
    ######

    if options2 != {}
      line_item.options = ActionController::Parameters.new(options2).permit(Spree::PermittedAttributes.line_item_attributes).to_h
    end

    unless options.empty?
      product_customizations_values = options[:product_customizations] || []
      line_item.product_customizations = product_customizations_values
      product_customizations_values.each { |product_customization| product_customization.line_item = line_item }
      product_customizations_values.map(&:save) # it is now safe to save the customizations we built

      # find, and add the configurations, if any.  these have not been fetched from the db yet.              line_items.first.variant_id
      # we postponed it (performance reasons) until we actually know we needed them
      ad_hoc_option_value_ids = ( options[:ad_hoc_option_values].present? ? options[:ad_hoc_option_values] : [] )
      product_option_values = ad_hoc_option_value_ids.map do |cid|
        Spree::AdHocOptionValue.find(cid) if cid.present?
      end.compact
      line_item.ad_hoc_option_values = product_option_values

      offset_price = product_option_values.map(&:price_modifier).compact.sum + product_customizations_values.map {|product_customization| product_customization.price(variant)}.compact.sum

      line_item.price = variant.price_in(order.currency).amount + offset_price
    end
    
    if Spree.solidus_version < '2.5' && line_item.new_record?
      create_order_stock_locations(line_item, options[:stock_location_quantities])
    end

    line_item.target_shipment = options[:shipment]
    line_item.save!
    line_item
  end

  # Bringing in since it was taken out of version 2.5
  def create_order_stock_locations(line_item, stock_location_quantities)
    return unless stock_location_quantities.present?
    order = line_item.order
    stock_location_quantities.each do |stock_location_id, quantity|
      order.order_stock_locations.create!(stock_location_id: stock_location_id, quantity: quantity, variant_id: line_item.variant_id) unless quantity.to_i.zero?
    end
  end
end
