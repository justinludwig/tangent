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

class PersonMailer < ApplicationMailer
  def signup_notification(person)
    set_defaults person
    subject "Welcome to #{AppConfig.name}"
    @body.merge! :why => " that your account was created"
  end
  
  def activation(person)
    set_defaults person
    subject "Your #{AppConfig.name} account has been activated"
  end

  def deletion_notification(person)
    set_defaults person
    subject "Goodbye from #{AppConfig.name}"
    @body.merge! :why => " that your account was deleted permanently"
  end

  def personal_email(to, from, the_subject, the_body)
    set_defaults to, from
    subject the_subject
    @body.merge! :body => the_body, :why => " of a personal message from #{from.display_name} (you can view this person's profile at <#{person_url from, :only_path => false}>)"
  end
  
end
