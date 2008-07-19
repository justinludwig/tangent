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

module ActivitiesHelper

  def has_privilege_for_activity?(activity, *privileges)
    (has_privilege? *privileges) || (activity.event.coordinators.include? current_person)
  end

  def has_privilege_for_activity(activity, *privileges)
    return (access_denied || false) unless has_privilege_for_activity? activity, *privileges
    return true
  end
  
  # format activity start_date as friendly but compact string
  # which pairs nicely with activity_endtime
  def activity_starttime(activity)
    headline_starttime activity.activity_or_event_start_date, activity.activity_or_event_end_date
  end

  # format activity end_date as friendly but compact string
  # which pairs nicely with activity_starttime
  def activity_endtime(activity)
    headline_endtime activity.activity_or_event_start_date, activity.activity_or_event_end_date
  end
  
  def list_criteria(activity)
    activity.criteria.split(/,/).map { |i|
      content_tag 'span', h(i)
    }.join(',') unless activity.criteria.blank?
  end
  
  # returns hCalendar partstat value for participant
  def partstat(participant)
    case participant.state
      when 'invited': 'needs-action'
      when 'confirmed': 'accepted'
      when 'withdrawn': 'declined'
      else participant.state
    end
  end
  
end
