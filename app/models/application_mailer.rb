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

class ApplicationMailer < ActionMailer::Base
  
  protected
    def set_defaults
      set_smtp_settings
      from %{"#{AppConfig.email_from_name}" <#{ActionMailer::Base.smtp_settings[:user_name]}>}
      sent_on Time.now
    end
    
    def set_smtp_settings
      rotate = ActionMailer::Base.smtp_settings[:rotate]
      return if rotate.nil? || rotate < 1
      rotate_start = ActionMailer::Base.smtp_settings[:rotate_start] || 1

      # rotate among #{rotate} number of addresses, starting with #{rotate_start}
      number = rand(rotate).floor + rotate_start
      # replace trailing number from username, if it exists (otherwise just add a trailer)
      ActionMailer::Base.smtp_settings[:user_name].sub! /\d*@/, "#{number}@"
    end

end
