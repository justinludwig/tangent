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

class Activity < ActiveRecord::Base
  belongs_to :event

  has_many :participants, :dependent => :destroy
  has_many :people, :through => :participants, :uniq => true, :order => "display_name", :conditions => "people.state = 'active'"

  validates_presence_of :name
  validates_length_of :name, :maximum => 50
  validates_format_of :name, :with => /\S/ 
  validates_length_of :criteria, :maximum => 100, :allow_blank => true
  validates_length_of :tags, :maximum => 100, :allow_blank => true

  INFINITY = 1.0/0

  # override toString with activity name
  def to_s
    name
  end

  # true if activity has available openings
  def available?
    available > 0
  end

  # number of available openings (may be INFINITY)
  def available
    return INFINITY if unlimited?
    return openings - participants.count_in_state(:confirmed)
  end
  
  # true if activity has unlimited openings
  def unlimited?
    openings.blank? || openings < 1
  end
  
  def activity_or_event_start_date
    return start_date || event.start_date
  end
  
  def activity_or_event_end_date
    return end_date || event.end_date
  end

end
