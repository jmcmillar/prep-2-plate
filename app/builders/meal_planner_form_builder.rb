# Wrap each form builder method with our own method that adds a wrapping div
# and label. Try not to override existing method names, in case you want to use
# the regular text_field somewhere without the extra markup.
class MealPlannerFormBuilder < ActionView::Helpers::FormBuilder
    VALID_INPUTS = %i[
      text_field
      password_field
      text_area
      color_field
      search_field
      telephone_field
      phone_field
      date_field
      time_field
      datetime_field
      datetime_local_field
      month_field
      week_field
      url_field
      email_field
      number_field
      range_field
      rich_text_area
      file_field
      hidden_field
    ].freeze
  
    def actions(cancel_path:, submit_text: "Save")
      @template.tag.div(class: "flex flex-row justify-end") do
        @template.link_to("Cancel", cancel_path, class: "inline-block h-10 rounded bg-gray-200 px-4 py-2 text-gray-500 font-medium mr-2 hover:bg-gray-300 hover:text-gray-600") +
          submit(submit_text, class: "h-10 rounded bg-secondary px-4 py-2 text-white font-medium hover:bg-gray-500")
      end
    end
  
    def check_box_input(method, options = {}, checked_value = "1", unchecked_value = "0")
      label_text, label_options = extract_label_text_and_options(options)
      label_options = label_options.merge(class: @template.class_names("form-check-label", label_options[:class]))
      options = options.merge(class: @template.class_names("rounded border-gray-300 text-gray-600 shadow-sm focus:border-gray-300 focus:ring focus:ring-offset-0 focus:ring-gray-200 focus:ring-opacity-50 mr-1", options[:class]))
      @template.tag.div(class: "mb-3 flex items-center") do
        check_box(method, options, checked_value, unchecked_value) +
          label(method, label_text, label_options)
      end
    end

    def collection_check_box_input_group_tags(
      method,
      collection,
      value_method,
      text_method,
      options = {},
      html_attributes = {}
    )
      label_text, label_options = extract_label_text_and_options(options)
      class_name = html_attributes.delete(:class)
      data_attributes = { 
        controller: "checkbox-group",
        "checkbox-group-collection-value": collection,
        "checkbox-group-whitelist-value": collection.pluck(text_method),
      }
      @template.tag.div(class: "mb-3", data: data_attributes) do
        @template.render(
          'components/collection_check_box_input_group',
          class_name: @template.class_names(class_name, "hidden"),
          collection: collection,
          form: self,
          html_attributes: html_attributes,
          label_options: label_options,
          label_text: label_text,
          method: method,
          options: options,
          text_method: text_method,
          value_method: value_method
        ) + @template.tag.input(
          type: "text",
          class: "mt-1 px-4 py-3 block w-full rounded-md border border-gray-300 focus:border-gray-300 focus:ring focus:ring-gray-200 focus:ring-opacity-50",
          value: options[:value]
        )
        end
    end
  
    def collection_check_box_input_group(
      method,
      collection,
      value_method,
      text_method,
      options = {},
      html_attributes = {}
    )
      label_text, label_options = extract_label_text_and_options(options)
      class_name = html_attributes.delete(:class)
  
      @template.render(
        'components/collection_check_box_input_group',
        class_name: class_name,
        collection: collection,
        form: self,
        html_attributes: html_attributes,
        label_options: label_options,
        label_text: label_text,
        method: method,
        options: options,
        text_method: text_method,
        value_method: value_method
      )
    end
  
    def collection_radio_button_inputs(method, collection, value_method, text_method, options = {}, html_options = {})
      label_text, label_options = extract_label_text_and_options(options)
      @template.tag.div(class: "mb-3") do
        label(nil, label_text, label_options) +
          collection_radio_buttons(method, collection, value_method, text_method, options, html_options) do |radio|
            @template.tag.div(class: "form-check") do
              radio.radio_button(class: "form-check-input") +
                radio.label(class: "form-check-label")
            end
          end
      end
    end
  
    def collection_select_input(method, collection, value_method, text_method, options = {}, html_options = {})
      label_text, label_options = extract_label_text_and_options(options)
      html_options = html_options.merge(class: @template.class_names("px-4 py-3 block w-full rounded-md border border-gray-300 focus:border-gray-300 focus:ring focus:ring-gray-200 focus:ring-opacity-50", html_options[:class]))
      @template.tag.div(class: "mb-3") do
        label(method, label_text, label_options) +
          collection_select(method, collection, value_method, text_method, options, html_options)
      end
    end

    def searchable_collection_select_input(method, collection, value_method, text_method, options = {}, html_options = {})
      label_text, label_options = extract_label_text_and_options(options)
      html_options[:data] = { controller: "searchable-select" }
      html_options = html_options.merge(class: @template.class_names("px-4 py-3 block w-full rounded-md border border-gray-300 focus:border-gray-300 focus:ring focus:ring-gray-200 focus:ring-opacity-50", html_options[:class]))
      @template.tag.div(class: "mb-3") do
        label(method, label_text, label_options) +
          collection_select(method, collection, value_method, text_method, options, html_options)
      end
    end

    def multiple_searchable_collection_select_input(method, collection, value_method, text_method, options = {}, html_options = {})
      label_text, label_options = extract_label_text_and_options(options)
      html_options[:data] = { controller: "searchable-select" }
      html_options = html_options.merge(class: @template.class_names("px-4 py-3 block w-full rounded-md border border-gray-300 focus:border-gray-300 focus:ring focus:ring-gray-200 focus:ring-opacity-50", html_options[:class]))
      @template.tag.div(class: "mb-3") do
        label(method, label_text, label_options) +
          collection_select(method, collection, value_method, text_method, options, html_options.merge(multiple: true))
      end
    end
  
    def select_input(method, choices = [], options = {}, html_options = {})
      label_text, label_options = extract_label_text_and_options(options)
      html_options = html_options.merge(class: @template.class_names("px-4 py-3 block w-full rounded-md border border-gray-300 focus:border-gray-300 focus:ring focus:ring-gray-200 focus:ring-opacity-50", html_options[:class]))
      @template.tag.div(class: "mb-3") do
        label(method, label_text, label_options) +
          select(method, choices, options, html_options)
      end
    end
  
    def input(method, as: :text_field, **options)
      raise ArgumentError, "not a valid input" unless VALID_INPUTS.include?(as)
  
      label_text, label_options = extract_label_text_and_options(options)
      options = options.merge(
        class: @template.class_names(
          { "mt-1 px-4 py-3 block w-full rounded-md border border-gray-300 focus:border-gray-300 focus:ring focus:ring-gray-200 focus:ring-opacity-50" => as != :rich_text_area },
          options[:class]
        )
      )
  
      case as
      when :date_field
        options = options.merge(
          data: (options[:data] || {}).merge(
            controller: @template.class_names("flatpickr", options.dig(:data, :controller)),
            flatpickr_allow_input: true,
            flatpickr_alt_input: true,
            flatpickr_alt_format: I18n.t("date.formats.picker_display"),
            flatpickr_date_format: I18n.t("date.formats.picker_value")
          )
        )
      when :datetime_field, :datetime_local_field
        options = options.merge(
          data: (options[:data] || {}).merge(
            controller: @template.class_names("flatpickr", options.dig(:data, :controller)),
            flatpickr_enable_time: true,
            flatpickr_allow_input: true,
            flatpickr_alt_input: true,
            flatpickr_alt_format: I18n.t("time.formats.picker_display"),
            flatpickr_date_format: I18n.t("time.formats.picker_value")
          )
        )
      end
  
      @template.tag.div(class: "mb-3") do
        label(method, label_text, label_options) +
          public_send(as, method, options)
      end
    end
  
    def label(method, text = nil, options = {}, &block)
      @template.render Form::LabelComponent.new(method, text, **options)
    end
  
    private
  
    def extract_label_text_and_options(options)
      label_text = options.delete(:label_text)
      label_options = (options.delete(:label_options) || {}).merge({required: options.fetch(:required, false)})
  
      [label_text, label_options]
    end
  end
  