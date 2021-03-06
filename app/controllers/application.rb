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

  before_filter :audit_request
  
  # sliding_sessions
  REMEMBER_ME_EXPIRES = eval AppConfig.remember_me_expires
  session :session_expires_after => REMEMBER_ME_EXPIRES
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '51b7778c2d93981d22553fb1b9a42684'

  # store person data in cookie
  def remember_person_data
      js_name = javascript_helper.escape_javascript(current_person.display_name)
      cookies[:tangent_person] = {
        :value => "id:#{current_person.id},name:'#{js_name}'",
        :expires => Time.now + REMEMBER_ME_EXPIRES 
      }
      session[:auth_expires] = Time.now + REMEMBER_ME_EXPIRES if params[:remember_me]
  end

  # forget person data from cookie
  def forget_person_data
    cookies[:tangent_person] = { :value => "", :expires => Time.now - 1.year }
    reset_session
  end

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
    order = default unless order =~ /^[a-z_.,]+(?: ASC| DESC)?$/
    params[:order] = order
  end

  def requested_query(default = nil)
    params[:q] || default
  end

  # log msg to audit log
  def audit_log(msg)
    unless @audit_log
      logfile = File.open "#{RAILS_ROOT}/log/audit.log", 'a'
      logfile.sync = true
      @audit_log = AuditLogger.new logfile
    end
    @audit_log.info msg
  end

  # filter to log all non-idempotent actions
  def audit_request
    # filter password/password_confirmation request-parameters
    audit_log "#{request.remote_ip} #{logged_in? ? current_person.id : 0} #{action_name} #{controller_name} #{request.path} #{request.parameters.inspect.gsub /\"password(_confirmation)?\"=>"[^\"]*\"(, )?/, ''}" unless (request.get? || request.head?)
  end
  
  protected
  
    def javascript_helper
      JavaScriptHelper.instance
    end
          
    class JavaScriptHelper
      include Singleton
      include ActionView::Helpers::JavaScriptHelper
    end
  
    class AuditLogger < Logger
      # restore message formatting in rails env
      def format_message(severity, timestamp, progname, msg)
        "#{timestamp.to_s :db} #{msg}\n"
      end
    end

end
