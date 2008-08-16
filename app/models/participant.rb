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

class Participant < ActiveRecord::Base
  belongs_to :activity
  belongs_to :person
 
  acts_as_state_machine :initial => :waiting
  state :waiting
  state :invited
  state :tentative
  state :confirmed
  state :withdrawn

  event :wait do
    transitions :from => [:invited, :tentative, :confirmed, :withdrawn], :to => :waiting
  end

  event :invite do
    transitions :from => [:waiting, :withdrawn], :to => :invited
  end

  event :tentative do
    transitions :from => [:waiting, :invited, :confirmed, :withdrawn], :to => :tentative
  end

  event :confirm do
    transitions :from => [:waiting, :invited, :tentative, :withdrawn], :to => :confirmed, :guard => Proc.new { |participant| participant.activity.available? }
  end

  event :withdraw do
    transitions :from => [:invited, :tentative, :confirmed], :to => :withdrawn
  end

  def to_s
    "#{person} #{state} #{state_preposition} #{activity}"
  end

  def state_preposition
    case state
      when 'confirmed', 'tentative', 'waiting'
        'for'
      when 'invited'
        'to'
      when 'withdrawn'
        'from'
    end
  end

  # as in "bob #{state_as_past_action} #{state_prepositon} this activity"
  def state_as_past_action(person = 3)
    case state
      when 'confirmed'
        "#{state}"
      when 'tentative'
        "confirmed tentatively"
      when 'invited'
        "#{person == 2 ? 'were' : 'was'} #{state}"
      when 'waiting'
        "#{person == 2 ? 'were' : 'was'} wait-listed"
      when 'withdrawn'
        "withdrew"
    end
  end

  # as in "bob was #{state_as_past_action} #{state_prepositon} this activity"
  def state_as_past_condition
    case state
      when 'confirmed', 'invited', 'withdrawn'
        "#{state}"
      when 'tentative'
        "confirmed tentatively"
      when 'waiting'
        "wait-listed"
    end
  end

end
