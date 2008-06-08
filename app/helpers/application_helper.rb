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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include PrivilegedSystem
  
  PUSH_BUTTON_HTML = 
    '<span class="yui-button yui-push-button"><span class="first-child"><button\1\3>\2</button></span></span>'

  # head tags

  def yui_stylesheet_link_tag
    stylesheet_link_tag(
      "http://yui.yahooapis.com/2.5.2/build/reset-fonts-grids/reset-fonts-grids.css",
      "http://yui.yahooapis.com/2.5.2/build/assets/skins/sam/skin.css" 
    )
  end

  def yui_javascript_include_tag
    javascript_include_tag(
      "http://yui.yahooapis.com/2.5.2/build/yuiloader/yuiloader-beta-min.js",
      "http://yui.yahooapis.com/2.5.2/build/event/event-min.js"
    )
  end

  # form input tags
  
  def property_line_tag(text, id, options = {})
    required = options[:required]
    css = (required ? "property required" : "property")
    
    label = options[:label]
    if label == :none
      escape_label = true
      label = "&nbsp;"
      id = nil
    else
      label = id.humanize unless label
    end

    description = options[:description]
    description = (description ? "required; " + description : "required") if required
    
    html = "<div class=\"#{css}\">\n"
    html << content_tag("label", label, { :for => id, :class => "property-label" }, escape_label) << "\n"
    html << "<span class=\"property-value\">#{text}</span>\n"
    html << "<span class=\"property-description\">#{description}</span>\n" if description
    html << "</div>\n"
  end
  
  def text_tag(value, options = {})
    content_tag "span", value, options
  end
  
  def labeled_check_box_tag(name, label, checked, options = {})
    id = options[:id] ? options[:id] : name
    label = name.humanize unless label
    
    css = options.delete(:class)
    css = css ? "checkbox #{css}" : "checkbox"
    
    content_tag(
      "label",
      check_box_tag(name, nil, checked, options) << " " << label,
      :for => id,
      :class => css
    )
  end
  
  def html_editor_tag(method, options = {})
    content_tag 'span', text_area_tag(name, value, options), :class => 'html-editor'
  end

  def datetime_input_tag(name, value, options = {})
    content_tag 'span', text_field_tag(name, value, options), :class => 'datetime-input'
  end

  # button tags
  
  def styled_button_to(name, options = {}, html_options = {})
    button_to(name, options, html_options).sub(
      /<input([^>]*?type="submit"[^>]*?)value="([^>]*?)"([^>]*?)\/>/,
      PUSH_BUTTON_HTML
    )
  end
  
  def styled_button_to_function(name, onclick, options = {})
    button_to_function(name, onclick, options).sub(
      /<input([^>]*?)value="([^>]*?)"([^>]*?)\/>/,
      PUSH_BUTTON_HTML
    )
  end
  
  def styled_button_to_back(name, options = {})
    styled_button_to_function name, "history.back()", options
  end
  
  def styled_submit_tag(value = "Submit", options = {})
    submit_tag(value, options).sub(
      /<input([^>]*?)value="([^>]*?)"([^>]*?)\/>/,
      PUSH_BUTTON_HTML
    )
  end

  # link tags
  
  def titled_image_tag(source, options = {})
    options[:title] = options[:alt] unless options[:title]
    image_tag source, options
  end
  
  def confirmed_image_link_to(url, method, icon, alt, msg, title)
      link_to_function(
        titled_image_tag(icon, :alt => alt),
        "App.confirm('#{msg}', { text: '#{alt}', handler: function() { App.controllerRequest('#{method}', '#{url}') } }, null, '#{title}');",
        :href => url
      )
  end
  
  def link_to_delete(model)
      type = model.class.table_name.humanize.downcase.singularize
      msg = "Are you sure you want to delete this #{type}?"
      confirmed_image_link_to url_for(model), "delete", "silk/cross.png", "Delete", msg, "Confirm Delete"
  end

  def links_to_page(model)
    will_paginate model
  end

  def link_to_order_by(text, order, ascending = true)
      # determine current order and ascending
      current_order = params[:order] || ''
      current_ascending = current_order !~ /-$|DESC$/
      current_order = current_order.sub /([a-z_]+)(.*)/, '\1'
      current = true if order == current_order

      # if current, reverse ascending
      order << '-' if (current ? current_ascending : !ascending)

      # create link with order, preserving existing GET params
      options = { :order => order }
      options = params.merge(options) if request.get?
      html = link_to text, options

      # add up/down arrow if current
      html << titled_image_tag((current_ascending ? 'silk/bullet_arrow_up.png' : 'silk/bullet_arrow_down.png'), :alt => (current_ascending ? 'Ascending' : 'Descending')) if current
      html
  end

  # output tags
  
  def formatted_datetime(date)
    return "" unless date
    date.strftime '%A, %B %e, %Y at %l:%M %p %Z'
  end
  
  def list_datetime(date)
    return "" unless date
    date.strftime '%m/%d/%Y %I:%M %p'
  end

  def link_to_array(models)
    models.map { |m| link_to m, m } .join ', '
  end

end
