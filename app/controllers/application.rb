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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include PrivilegedSystem
  
  # sliding_sessions
  REMEMBER_ME_EXPIRES = 4.months
  session :session_expires_after => REMEMBER_ME_EXPIRES
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '51b7778c2d93981d22553fb1b9a42684'

  def requested_page(default = 1)
    page = (params[:page] ? params[:page].to_i : default)
    page = default if page < 1
    page
  end

  def requested_per_page(default = 10, max = 100)
    per_page = (params[:per_page] ? params[:per_page].to_i : default)
    per_page = default if per_page < 1
    per_page = max if per_page > max
    per_page
  end

  def requested_order(default = 'id')
    order = params[:order]
    if order
      # convert "display_name+" to "display_name"
      # convert "display_name-" to "display_name DESC"
      order = order.sub(/\+$/, '').sub(/-$/, ' DESC')
    end
    # must be either "display_name ASC" or "display_name DESC"
    order = default unless order =~ /^[a-z_]+(?: ASC| DESC)?$/
    order
  end

  def requested_query(default = nil)
    params[:q] || default
  end

end
