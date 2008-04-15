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

# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_filter :login_required, :except => [ :new, :create, :authenticity_token ]
  
  # GET /session
  # GET /session.xml
  def show
    @person = current_person
    redirect_to(@person)
  end

  # GET /session/new
  # GET /session/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml do
        request_http_basic_authentication 'Web Password'
      end
    end
  end

  def create
    self.current_person = Person.authenticate(params[:login], params[:password])
    if logged_in?
      session[:auth_expires] = Time.now + REMEMBER_ME_EXPIRES if params[:remember_me]
      flash[:notice] = "Welcome back, #{current_person.display_name}!"
      
      js_name = javascript_helper.escape_javascript(current_person.display_name)
      cookies[:tangent_person] = {
        :value => "id:#{current_person.id},name:'#{js_name}'",
        :expires => Time.now + REMEMBER_ME_EXPIRES 
      }
      
      redirect_back_or_default('/')
    else
      flash[:error] = "Email or password does not match a registered person."
      render :action => 'new'
    end
  end

  def destroy
    cookies[:tangent_person] = { :value => "", :expires => Time.now - 1.year }
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  def authenticity_token
    render :text => form_authenticity_token
  end
  
  protected
  
  def javascript_helper
    JavaScriptHelper.instance
  end
        
  class JavaScriptHelper
    include Singleton
    include ActionView::Helpers::JavaScriptHelper
  end
end
