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

class EventTest < ActiveSupport::TestCase
  fixtures :all

  def test_should_create_event
    assert_difference 'Event.count' do
      event = create_event
      assert !event.new_record?, "#{event.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_with_end_date_later_than_start_date
    assert_difference 'Event.count' do
      event = create_event :end_date => Time.utc(2008, 'oct', 31)
      assert !event.new_record?, "#{event.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_with_coordinator
    assert_difference 'Event.count' do
      event = create_event :temp_coordinator_ids => people(:alice).id.to_s
      assert !event.new_record?, "#{event.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_with_multiple_coordinators
    assert_difference 'Event.count' do
      event = create_event :temp_coordinator_ids => [people(:alice).id, people(:bob).id].join(', ')
      assert !event.new_record?, "#{event.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_with_tag_list
    assert_difference 'Event.count' do
      event = create_event :tag_list => 'holiday, party'
      assert !event.new_record?, "#{event.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference 'Event.count' do
      u = create_event :name => nil
      assert u.errors.on(:name)
    end
  end

  def test_should_require_valid_name
    assert_no_difference 'Event.count' do
      u = create_event :name => nil
      assert u.errors.on(:name)
      u = create_event :name => ''
      assert u.errors.on(:name)
      u = create_event :name => ' '
      assert u.errors.on(:name)
      long_name = ''; 51.times { long_name << 'a' }
      u = create_event :name => long_name
      assert u.errors.on(:name)
    end
  end

  def test_should_require_start_date
    assert_no_difference 'Event.count' do
      u = create_event(:start_date => nil)
      assert u.errors.on(:start_date)
    end
  end

  def test_should_require_start_date_earlier_than_end_date
    assert_no_difference 'Event.count' do
      u = create_event :end_date => Time.utc(2008, 'sep', 30)
      assert u.errors.on(:end_date)
    end
  end

  def test_should_require_valid_coordinators
    assert_no_difference 'Event.count' do
      u = create_event :temp_coordinator_ids => nil
      assert u.errors.on(:temp_coordinator_ids)
      u = create_event :temp_coordinator_ids => ''
      assert u.errors.on(:temp_coordinator_ids)
      u = create_event :temp_coordinator_ids => '100'
      assert u.errors.on(:temp_coordinator_ids)
      u = create_event :temp_coordinator_ids => '100, 200'
      assert u.errors.on(:temp_coordinator_ids)
      u = create_event :temp_coordinator_ids => [people(:alice).id, 100].join(', ')
      assert u.errors.on(:temp_coordinator_ids)
    end
  end

  def test_update_tag_list
    candlemas = events :candlemas
    candlemas.update_attributes :tag_list => 'holiday, party'
    assert_equal ['holiday', 'party'], candlemas.tag_list
  end


protected

  def create_event(options = {})
    Event.create({ :name => 'Octoberfest', :start_date => Time.utc(2008, 'oct', 1) }.merge(options))
  end

end
