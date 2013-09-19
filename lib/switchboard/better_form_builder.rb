# This adds the name of the attribute to the field wrapper, so you can target, eg, ".input.phone_number" -- makes targeting much easier.
# Should really be in simple_form defaults; formtasic does this automatically.

class BetterFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, options = {}, &block)
    column      = find_attribute_column(attribute_name)
    options[:wrapper_html] ||= {}
    options[:wrapper_html][:class] = [options[:wrapper_html][:class], attribute_name].compact
    super
  end
end