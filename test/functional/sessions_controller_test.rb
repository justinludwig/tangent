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

require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

class SessionsControllerTest < ActionController::TestCase
  fixtures :people

  def test_should_login_and_redirect
    post :create, :login => people(:alice).email, :password => 'password'
    assert session[:person_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => people(:alice).email, :password => 'bad password'
    assert_nil session[:person_id]
    assert_response :success
  end

  def test_should_logout
    login_as :alice
    get :destroy
    assert_nil session[:person_id]
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :login => people(:alice).email, :password => 'password', :remember_me => 'true'
    assert session[:auth_expires] > Time.now + 1.hour
  end

  def test_should_not_remember_me
    post :create, :login => people(:alice).email, :password => 'password'
    assert session[:auth_expires] < Time.now + 1.hour
  end
  
  def test_should_delete_token_on_logout
    login_as :alice
    get :destroy
    assert_nil session[:auth_expires]
  end

  def test_should_login_with_cookie
    login_as :alice
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    login_as :alice
    @request.session[:auth_expires] = Time.now - 1.day
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @request.session[:person_id] = 666
    @request.session[:auth_expires] = Time.now + 1.day
    get :new
    assert !@controller.send(:logged_in?)
  end

end
