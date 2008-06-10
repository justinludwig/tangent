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
    transitions :from => [:waiting, :invited, :tentative, :withdrawn], :to => :confirmed, :guard => Proc.new { |participant|
      activity = participant.activity
      openings = activity.openings
      openings.blank? || activity.participants.count_in_state(:confirmed) < openings
    }
  end

  event :withdraw do
    transitions :from => [:invited, :tentative, :confirmed], :to => :withdrawn
  end

  def to_s
    s = String.new person.display_name
    case state
      when 'confirmed', 'tentative', 'waiting'
        s << " #{state} for "
      when 'invited'
        s << " #{state} to "
      when 'withdrawn'
        s << " #{withdrawn} from "
    end
    s << activity.name
  end

end
