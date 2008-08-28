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

class ParticipantObserver < ActiveRecord::Observer
  def after_save(participant)
    # skip if the first save
    return if participant.created_at == participant.updated_at

    # don't send notifications if this event is already over
    end_date = participant.activity.activity_or_event_end_date || participant.activity.activity_or_event_start_date
    return if end_date < Time.now.utc

    # notify participant herself
    ParticipantMailer.deliver_update_notification_for_self participant

    # notify event coordinators
    participant.activity.event.coordinators.each do |owner|
      ParticipantMailer.deliver_update_notification_for_owner participant, owner
    end
  end
end
