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

class ActivitiesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:activities)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_activity
    assert_difference('Activity.count') do
      post :create, :activity => { }
    end

    assert_redirected_to activity_path(assigns(:activity))
  end

  def test_should_show_activity
    get :show, :id => activities(:candlemas_attendee).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => activities(:candlemas_attendee).id
    assert_response :success
  end

  def test_should_update_activity
    put :update, :id => activities(:candlemas_attendee).id, :activity => { }
    assert_redirected_to activity_path(assigns(:activity))
  end

  def test_should_destroy_activity
    assert_difference('Activity.count', -1) do
      delete :destroy, :id => activities(:candlemas_attendee).id
    end

    assert_redirected_to activities_path
  end
end
