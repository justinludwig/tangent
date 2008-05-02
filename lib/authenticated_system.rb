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

module AuthenticatedSystem
  protected
    # Returns true or false if the person is logged in.
    # Preloads @current_person with the person model if they're logged in.
    def logged_in?
      current_person
    end

    # Accesses the current person from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_person
      @current_person ||= (login_from_session || login_from_basic_auth) unless @current_person == false
    end

    # Store the given person id in the session.
    def current_person=(new_person)
      session[:person_id] = new_person ? new_person.id : nil
      if (new_person)
        session[:auth_expires] = Time.now + 1.hour unless session[:auth_expires] && session[:auth_expires] > Time.now + 4.hours
      else
        session[:auth_expires] = nil
      end
      @current_person = new_person || false
    end

    # Check if the person is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the person
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_person.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the person is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          render :file => "#{RAILS_ROOT}/public/401.html", :status => 401 and return if logged_in?
          store_location
          redirect_to new_session_path
        end
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect = session[:return_to] || default
      redirect_to(redirect == "/" ? my_stuff_path : redirect)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_person and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_person, :logged_in?
    end

    # Called from #current_person.  First attempt to login by the person id stored in the session.
    def login_from_session
      self.current_person = Person.find_by_id(session[:person_id]) if session[:person_id] && session[:auth_expires] && session[:auth_expires].to_time > Time.now
    end

    # Called from #current_person.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_person = Person.authenticate(username, password)
      end
    end
end
