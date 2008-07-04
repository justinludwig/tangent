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
    setup_email person
    subject "Welcome to #{AppConfig.name}"
    @body.merge! :why => " that your account was created"
  end
  
  def activation(person)
    setup_email person
    subject "Your #{AppConfig.name} account has been activated"
  end

  def personal_email(to, from, the_subject, the_body)
    setup_email to
    subject the_subject
    reply_to %{"#{from.display_name.gsub /"/, '\''}" <#{from.email}>}
    @body.merge! :from => from, :body => the_body, :why => " of a personal message from #{from.display_name} (you can view this person's profile at <#{person_url from, :only_path => false}>)"
  end
  
  protected
    def setup_email(person)
      set_defaults
      recipients %{"#{person.display_name.gsub /"/, '\''}" <#{person.email}>}
      body :person => person
    end
end
