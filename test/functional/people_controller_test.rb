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
require 'people_controller'

class PeopleControllerTest < ActionController::TestCase
  fixtures :people

  def test_should_allow_signup
    assert_difference 'Person.count' do
      create_person
      assert_response :redirect
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'Person.count' do
      create_person(:password => nil)
      assert assigns(:person).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'Person.count' do
      create_person(:password_confirmation => nil)
      assert assigns(:person).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'Person.count' do
      create_person(:email => nil)
      assert assigns(:person).errors.on(:email)
      assert_response :success
    end
  end
  
=begin
  def test_should_activate_user
    assert_nil Person.authenticate('alice', 'password')
    get :activate, :activation_code => people(:alice).activation_code
    assert_redirected_to '/'
    assert_not_nil flash[:notice]
    assert_equal people(:alice), Person.authenticate('alice', 'password')
  end
  
  def test_should_not_activate_user_without_key
    get :activate
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # well played, sir
  end
=end

  protected
    def create_person(options = {})
      post :create, :person => { :email => 'zed@example.com', :password => 'password', :password_confirmation => 'password', :display_name => 'Zed' }.merge(options)
    end
end
