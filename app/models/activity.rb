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
  has_many :people, :through => :participants, :uniq => true, :order => "display_name", :conditions => "state = 'active'"

  validates_presence_of :name
  validates_length_of :name, :maximum => 50
  validates_format_of :name, :with => /\S/ 
  validates_length_of :criteria, :maximum => 100
  validates_length_of :tags, :maximum => 100

  # override toString with activity name
  def to_s
    name
  end

end