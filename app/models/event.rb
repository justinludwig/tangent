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

class Event < ActiveRecord::Base
  acts_as_taggable
  
  has_many :event_coordinators, :dependent => :destroy
  has_many :coordinators, :through => :event_coordinators, :uniq => true, :order => "display_name", :conditions => "state = 'active'"
  has_many :activities, :order => "name", :dependent => :destroy
  has_many :participants, :through => :activities, :include => [:activity, :person], :order => "people.display_name"

  validates_presence_of :name
  validates_length_of :name, :maximum => 50
  validates_format_of :name, :with => /\S/ 
  validates_presence_of :start_date

  # override toString with event name
  def to_s
    name
  end

  # list unique people who are participants
  # todo: do filtering in db
  def people
    participants.inject([]) do |memo, participant|
      person = participant.person
      memo << person if (person.active? && !memo.include?(person))
      memo
    end
  end

  # use temp ids until event has been created
  def temp_coordinator_ids
    @temp_coordinator_ids || coordinator_ids
  end

  # store new ids until event has been updated
  # and allow ids to be either an array or a csv string
  def temp_coordinator_ids=(ids)
    ids ||= []
    # convert string to array of integers
    ids = ids.split /\s*,\s*/ if ids.is_a? String
    ids = ids.map { |i| i.to_i }
    
    # validate at least one coordinator
    @temp_coordinator_errors = []
    @temp_coordinator_errors.push 'can\'t be blank' if ids.empty?
    
    # validate all coordinators exist
    ids.each do |cid|
      begin
        person = Person.find cid
        @temp_coordinator_errors.push 'invalid id' unless person.active?
      rescue ActiveRecord::RecordNotFound
        @temp_coordinator_errors.push 'invalid id'
      end
    end

    @temp_coordinator_ids = ids
  end

protected
  
  # override to check coordinator id errors
  def validate
    errors.add 'end_date', 'is earlier than Start Date' if end_date && end_date < start_date

    @temp_coordinator_errors.each { |err| errors.add 'temp_coordinator_ids', err } if @temp_coordinator_errors
    @temp_coordinator_errors = nil
  end

  # only after this model has been saved can we create new coordinators
  def after_save
    return if @temp_coordinator_ids == nil

    # create new event_coordinators
    @temp_coordinator_ids.each do |cid|
      event_coordinators.create :coordinator_id => cid unless coordinator_ids.include? cid
    end

    # delete existing event_coordinators not specified in temp_coordinators
    event_coordinators.each do |c|
      event_coordinators.delete c unless @temp_coordinator_ids.include? c.coordinator_id
    end

    @temp_coordinator_ids = nil
  end
end
