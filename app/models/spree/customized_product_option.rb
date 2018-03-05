module Spree
  # in populate, params[:customization] contains all the fields supplied by
  # the customization_type_view. Those values are saved in this class
  class CustomizedProductOption < ActiveRecord::Base
    belongs_to :product_customization
    belongs_to :customizable_product_option
    delegate :array_type?, to: :customizable_product_option
    delegate :datetime_type?, to: :customizable_product_option

    mount_uploader :customization_image, CustomizationImageUploader

    def empty?
      value.blank? && !customization_image? && json_value.blank? && integer_value.blank? && boolean_value == nil && float_value.blank? && datetime_value.blank? 
    end

    # alternative set method
    def set_value_for_type=(a)
      case self.customizable_product_option.data_type
      when "file"
        self.customization_image = a
      when "multi-select"
        self.json_value = a
      when "single-select"
        self.json_value = a
      when "integer"
        self.integer_value = a
      when "boolean"
        self.boolean_value = a
      when "float"
        self.float_value = a
      when "datetime"
        return if a == nil
        # handle incoming formats differently
        if a.class == Time || a.class == DateTime
          self.datetime_value = a
        elsif a.class == ActionController::Parameters && a["time(1i)"] != nil
          # likely coming in from datetime html selectors
          self.datetime_value = DateTime.new(a["time(1i)"].to_i, a["time(2i)"].to_i, a["time(3i)"].to_i, a["time(4i)"].to_i, a["time(5i)"].to_i)
        else
          puts " --- datetime not provided in understandable format"
          puts a
          puts a.class
          raise "datetime not provided in an understandable format"
        end
      else
        self.value = a
      end
    end

    # alternative get method
    def get_value_for_type
      case self.customizable_product_option.data_type
      when "file"
        self.customization_image
      when "multi-select"
        self.json_value
      when "single-select"
        self.json_value
      when "integer"
        self.integer_value
      when "boolean"
        self.boolean_value
      when "float"
        self.float_value
      when "datetime"
        self.datetime_value
      else
        self.value
      end
    end

    def display_text
      case self.customizable_product_option.data_type
      when "file"
        "#{File.basename customization_image.url}"
      when "multi-select"
        self.json_value
      when "single-select"
        self.json_value
      when "integer"
        self.integer_value
      when "boolean"
        self.boolean_value
      when "float"
        self.float_value
      when "datetime"
        self.datetime_value
      else
        self.value
      end
    end
  end
end
