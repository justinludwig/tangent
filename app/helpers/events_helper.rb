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

module EventsHelper

  def has_privilege_for_event?(event, *privileges)
    (has_privilege? *privileges) || (event.coordinators.include? current_person)
  end

  def has_privilege_for_event(event, *privileges)
    return (access_denied || false) unless has_privilege_for_event? event, *privileges
    return true
  end

  # format activity starte/end date as friendly but compact string
  # which fits nicely with event start/end
  def activity_datetime(event, date)
    return "" unless event && date
    s = event.start_date || Time.local(0)
    e = event.end_date || s

    pattern = "%I#{e.min != 0 ? ':%M' : ''} %p"
    pattern = "/%Y #{pattern}" if s.year != e.year
    pattern = "%m/%d #{pattern}" if s.day != e.day && e > s + 1.day
    pattern = "%a #{pattern}" if s.day != e.day

    date.strftime pattern
  end

  # returns person's participation status if signed-up to the activity
  # otherwise returns 'Sign Up!'
  def my_status_display(activity)
    begin
      participant = activity.participants.find_by_person_id current_person.id if logged_in?
      return participant.state.capitalize if participant
    rescue ActiveRecord::RecordNotFound
    end
    'Sign Up!'
  end

end
