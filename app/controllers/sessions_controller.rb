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
  before_filter :login_required, :except => [ :new, :create ]
  
  # GET /people
  # GET /people.xml
  def show
    @person = current_person
    redirect_to(@person)
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    respond_to do |format|
      format.html # show.html.erb
      format.xml do
        request_http_basic_authentication 'Web Password'
      end
    end
  end

  def create
    self.current_person = Person.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_person.remember_me
        cookies[:auth_token] = { :value => self.current_person.remember_token , :expires => self.current_person.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def destroy
    self.current_person.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
