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

class PersonTest < ActiveSupport::TestCase
  fixtures :people

  def test_should_create_person
    assert_difference 'Person.count' do
      person = create_person
      assert !person.new_record?, "#{person.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_and_start_in_passive_state
    person = create_person
    assert person.passive?
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

  def test_should_require_password_to_match_confirmation
    assert_no_difference 'Person.count' do
      u = create_person(:password => 'password1')
      assert u.errors.on(:password)
      u = create_person(:password_confirmation => 'password1')
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_length
    assert_no_difference 'Person.count' do
      u = create_person(:password => 'secret', :password_confirmation => 'secret')
      assert u.errors.on(:password)
    end
  end

  def test_should_require_email
    assert_no_difference 'Person.count' do
      u = create_person(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_require_valid_email
    assert_no_difference 'Person.count' do
      %{ f foo foobar.com foo@ @bar.com foo@bar bar.com f%o@bar.com foo@b%r.com}.each do |i|
        u = create_person(:email => i)
        assert u.errors.on(:email)
      end
    end
  end

  def test_should_require_display_name
    assert_no_difference 'Person.count' do
      u = create_person(:display_name => nil)
      assert u.errors.on(:display_name)
      u = create_person(:display_name => '')
      assert u.errors.on(:display_name)
      u = create_person(:display_name => ' ')
      assert u.errors.on(:display_name)
    end
  end

  def test_should_reset_password
    people(:alice).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal people(:alice), Person.authenticate('alice@example.com', 'new password')
  end

  def test_should_not_rehash_password
    people(:alice).update_attributes(:email => 'alice2@example.com')
    assert_equal people(:alice), Person.authenticate('alice2@example.com', 'password')
  end

  def test_should_authenticate_person
    assert_equal people(:alice), Person.authenticate(people(:alice).email, 'password')
  end

  def test_should_not_authenticate_person_with_bad_password
    alice = people :alice
    assert_not_equal alice, Person.authenticate(alice.email, nil)
    assert_not_equal alice, Person.authenticate(alice.email, '')
    assert_not_equal alice, Person.authenticate(alice.email, ' ')
    assert_not_equal alice, Person.authenticate(alice.email, 'bad password')
  end

  def test_should_generate_random_password
    alice = people :alice
    oldPassword = alice.password

    alice.random_password
    assert_not_nil alice.password
    assert_not_equal '', alice.password
    assert_not_equal oldPassword, alice.password
    assert_equal alice.password, alice.password_confirmation
  end

  def test_should_register_passive_person
    person = create_person
    assert person.passive?
    person.register!
    assert person.active?
  end

  def test_should_suspend_person
    people(:alice).suspend!
    assert people(:alice).suspended?
  end

  def test_suspended_person_should_not_authenticate
    people(:alice).suspend!
    assert_not_equal people(:alice), Person.authenticate('alice@example.com', 'password')
  end

  def test_should_unsuspend_person_to_active_state
    people(:alice).suspend!
    assert people(:alice).suspended?
    people(:alice).unsuspend!
    assert people(:alice).active?
  end

=begin
  def test_should_unsuspend_person_with_nil_activation_code_and_activated_at_to_passive_state
    people(:alice).suspend!
    Person.update_all :activation_code => nil, :activated_at => nil
    assert people(:alice).suspended?
    people(:alice).reload.unsuspend!
    assert people(:alice).passive?
  end

  def test_should_unsuspend_person_with_activation_code_and_nil_activated_at_to_pending_state
    people(:alice).suspend!
    Person.update_all :activation_code => 'foo-bar', :activated_at => nil
    assert people(:alice).suspended?
    people(:alice).reload.unsuspend!
    assert people(:alice).pending?
  end
=end

  def test_should_delete_person
    alice = people :alice
    assert_nil alice.deleted_at
    alice.delete!
    assert_not_nil alice.deleted_at
    assert alice.deleted?

    # assert all personal info purged
    assert_not_equal alice.display_name, 'Alice'
    assert_nil alice.email
    assert_nil alice.crypted_password
    assert_nil alice.salt
  end

protected
  def create_person(options = {})
    Person.create({ :email => 'zed@example.com', :password => 'password', :password_confirmation => 'password', :display_name => 'Zed' }.merge(options))
  end
end
