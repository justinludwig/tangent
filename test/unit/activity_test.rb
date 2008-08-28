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

class ActivityTest < ActiveSupport::TestCase
  fixtures :all

  def test_should_create_activity
    assert_difference 'Activity.count' do
      activity = create_activity
      assert !activity.new_record?, "#{activity.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_with_end_date_later_than_start_date
    assert_difference 'Activity.count' do
      activity = create_activity :start_date => Time.utc(2008, 'aug', 1), :end_date => Time.utc(2008, 'aug', 2)
      assert !activity.new_record?, "#{activity.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_with_tag_list
    assert_difference 'Activity.count' do
      activity = create_activity :tag_list => 'bread, food'
      assert !activity.new_record?, "#{activity.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference 'Activity.count' do
      u = create_activity :name => nil
      assert u.errors.on(:name)
    end
  end

  def test_should_require_valid_name
    assert_no_difference 'Activity.count' do
      u = create_activity :name => nil
      assert u.errors.on(:name)
      u = create_activity :name => ''
      assert u.errors.on(:name)
      u = create_activity :name => ' '
      assert u.errors.on(:name)
      long_name = ''; 51.times { long_name << 'a' }
      u = create_activity :name => long_name
      assert u.errors.on(:name)
    end
  end

  def test_should_require_start_date_earlier_than_end_date
    assert_no_difference 'Activity.count' do
      u = create_activity :start_date => Time.utc(2008, 'aug', 1), :end_date => Time.utc(2008, 'jul', 1)
      assert u.errors.on(:end_date)
    end
  end

  def test_update_tag_list
    bring_candles = activities :candlemas_bring_candles
    bring_candles.update_attributes :tag_list => 'candles, fire'
    assert_equal ['candles', 'fire'], bring_candles.tag_list
  end

  def test_unlimited
    assert activities(:candlemas_attendee).unlimited?
    assert !activities(:candlemas_bring_candles).unlimited?
  end

  def test_avaliable
    assert_equal Activity::INFINITY, activities(:candlemas_attendee).available
    assert activities(:candlemas_attendee).available?

    bring_candles = activities :candlemas_bring_candles
    assert_equal 3, bring_candles.available
    assert bring_candles.available?

    create_confirmed_participant :person => people(:alice)
    assert_equal 2, bring_candles.available
    assert bring_candles.available?

    create_confirmed_participant :person => people(:bob)
    assert_equal 1, bring_candles.available
    assert bring_candles.available?

    create_confirmed_participant :person => people(:cathy)
    assert_equal 0, bring_candles.available
    assert !bring_candles.available?
  end

  def test_available_unless_confirmed
    bake_bread = activities :lammas_bake_bread
    assert_equal 1, bake_bread.available
    assert bake_bread.available?

    participant = create_participant :activity => bake_bread, :person => people(:alice)
    assert_equal 1, bake_bread.available
    assert bake_bread.available?

    participant.confirm!
    assert_equal 0, bake_bread.available
    assert !bake_bread.available?

    participant.withdraw!
    assert_equal 1, bake_bread.available
    assert bake_bread.available?

    participant.invite!
    assert_equal 1, bake_bread.available
    assert bake_bread.available?

    participant.tentative!
    assert_equal 1, bake_bread.available
    assert bake_bread.available?

    participant.confirm!
    assert_equal 0, bake_bread.available
    assert !bake_bread.available?
  end


protected

  def create_activity(options = {})
    Activity.create({ :name => 'Eat Bread', :event => events(:lammas) }.merge(options))
  end

  def create_participant(options = {})
    Participant.create({ :activity => activities(:candlemas_bring_candles), :person => people(:bob) }.merge(options))
  end

  def create_confirmed_participant(options = {})
    p = create_participant options
    p.confirm!
    return p
  end
end
