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

class ParticipantTest < ActiveSupport::TestCase
  fixtures :all

  def test_create_participant
    assert_difference 'Participant.count' do
      participant = create_participant
      assert !participant.new_record?, "#{participant.errors.full_messages.to_sentence}"
    end
  end

  def test_invite
    participant = create_participant
    participant.invite!
    assert participant.invited?
  end

  def test_tentative
    participant = create_participant
    participant.tentative!
    assert participant.tentative?
  end

  def test_confirm
    participant = create_participant
    participant.confirm!
    assert participant.confirmed?
  end

  def test_withdraw
    participant = create_participant
    participant.withdraw!
    assert participant.withdrawn?
  end

  def test_cant_confirm
    participant = create_participant :activity => activities(:lammas_bake_bread), :person => people(:alice)
    participant.confirm!
    assert participant.confirmed?

    participant = create_participant :activity => activities(:lammas_bake_bread), :person => people(:bob)
    participant.confirm!
    assert !participant.confirmed?
    assert participant.waiting?
  end

protected

  def create_participant(options = {})
    Participant.create({ :activity => activities(:candlemas_bring_candles), :person => people(:bob) }.merge(options))
  end

end
