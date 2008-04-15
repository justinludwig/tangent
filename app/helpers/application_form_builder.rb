## Tangent, an online sign-up sheet
## Copyright (C) 2008 Justin Ludwig and Adam Stuenkel
## 
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::FormTagHelper
  include ApplicationHelper
  
  def property_line(type, method, options = {})
    pl_options = {
      :label => options.delete(:label),
      :description => options.delete(:description),
      :required => options.delete(:required)
    }
    
    options[:class] = "medium" unless options[:class]
    text = send(type, method, options)
    
    pl_options[:label] = method.to_s.humanize unless pl_options[:label]
    property_line_tag text, field_id(method), pl_options
  end
  
  def text(method, options = {})
    options[:id] = field_id(method) unless options[:id]
    text_tag @object.send(method), options
  end

  def datetime(method, options = {})
    options[:id] = field_id(method) unless options[:id]
    value = formatted_datetime @object.send(method)
    text_tag value, options
  end

  def datetime_input(method, options = {})
    content_tag 'span', text_field(method, options), :class => 'datetime-input'
  end
  
  def labeled_check_box(method, options = {})
    label = options.delete(:label)
    label = method.humanize unless label
    
    css = options.delete(:class)
    css = css ? "checkbox #{css}" : "checkbox"
    
    label method, check_box(name, nil, checked, options) << " " << label, :class => css
  end
  
  def styled_submit(value = "Submit", options = {})
    styled_submit_tag value, options
  end

  protected

    def field_id(method)
      "#{@object_name}_#{method}"
    end

    def field_name(method)
      "#{@object_name}[#{method}]"
    end
  
end
