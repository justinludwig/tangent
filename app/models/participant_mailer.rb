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

class ParticipantMailer < ApplicationMailer

  def update_notification_for_owner(participant, owner)
    set_defaults owner

    subject "#{participant.activity} for #{participant.activity.event}: Participant #{participant.state.capitalize}"
    @body.merge! :participant => participant, :why => " of a change to the participation in an activity you coordinate"
  end
  
  def update_notification_for_self(participant)
    set_defaults participant.person

    subject "#{participant.activity} for #{participant.activity.event}: You are #{participant.state.capitalize}"
    @body.merge! :participant => participant, :why => " of your participation in this #{AppConfig.name} activity"
  end
  
end
