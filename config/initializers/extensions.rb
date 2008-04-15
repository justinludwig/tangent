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

# extend field-level error display
# to set fieldWithErrors class on field
# instead of wrapping field with extra div
# and to add fieldErrorMsg with error msg following field
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    msg = instance.error_message
    msg = msg.join "; " if msg && msg.respond_to?(:join)
  
    if html_tag =~ /<(?:input|textarea|select|label)[^>]*?class=["']/
      html_tag = "#{$&}#{$`}fieldWithErrors #{$'}";
    else
      html_tag.sub(/<(?:input|textarea|select|label)/, "#{$&} class=\"fieldWithErrors\"")
    end
    
    html_tag << " <span class=\"fieldErrorMsg\">#{msg}</span> " if msg && html_tag !~ /<label/
    html_tag
end

# extend TimeZone to specify default
# todo: rails 2.1 will have better timezone handling
TimeZone.class_eval do
  def self.default
    TimeZone['Pacific Time (US & Canada)']
  end
end

