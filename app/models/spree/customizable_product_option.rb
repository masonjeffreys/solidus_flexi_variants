module Spree
  class CustomizableProductOption < ActiveRecord::Base
    belongs_to :product_customization_type
    delegate :calculator, to: :product_customization_type

    def array_type?
    	self.data_type == "multi-select" || self.data_type == "single-select"
    end

    def datetime_type?
    	self.data_type == "datetime"
    end

    def file_type?
    	self.data_type == "file"
    end

  end
end
