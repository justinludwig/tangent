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

class PersonTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :people

  def test_should_create_person
    assert_difference 'Person.count' do
      person = create_person
      assert !person.new_record?, "#{person.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_and_start_in_pending_state
    person = create_person
    assert person.pending?
  end


  def test_should_require_password
    assert_no_difference 'Person.count' do
      u = create_person(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'Person.count' do
      u = create_person(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'Person.count' do
      u = create_person(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    people(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal people(:quentin), Person.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    people(:quentin).update_attributes(:login => 'quentin2')
    assert_equal people(:quentin), Person.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_person
    assert_equal people(:quentin), Person.authenticate('quentin', 'test')
  end

  def test_should_register_passive_person
    person = create_person(:password => nil, :password_confirmation => nil)
    assert person.passive?
    person.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    person.register!
    assert person.pending?
  end

  def test_should_suspend_person
    people(:quentin).suspend!
    assert people(:quentin).suspended?
  end

  def test_suspended_person_should_not_authenticate
    people(:quentin).suspend!
    assert_not_equal people(:quentin), Person.authenticate('quentin', 'test')
  end

  def test_should_unsuspend_person_to_active_state
    people(:quentin).suspend!
    assert people(:quentin).suspended?
    people(:quentin).unsuspend!
    assert people(:quentin).active?
  end

  def test_should_unsuspend_person_with_nil_activation_code_and_activated_at_to_passive_state
    people(:quentin).suspend!
    Person.update_all :activation_code => nil, :activated_at => nil
    assert people(:quentin).suspended?
    people(:quentin).reload.unsuspend!
    assert people(:quentin).passive?
  end

  def test_should_unsuspend_person_with_activation_code_and_nil_activated_at_to_pending_state
    people(:quentin).suspend!
    Person.update_all :activation_code => 'foo-bar', :activated_at => nil
    assert people(:quentin).suspended?
    people(:quentin).reload.unsuspend!
    assert people(:quentin).pending?
  end

  def test_should_delete_person
    assert_nil people(:quentin).deleted_at
    people(:quentin).delete!
    assert_not_nil people(:quentin).deleted_at
    assert people(:quentin).deleted?
  end

protected
  def create_person(options = {})
    Person.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end
