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

module PeopleHelper

  def has_privilege_for_person?(person, privilege, self_privilege)
    (has_privilege? privilege) || ((person == current_person) && (has_privilege? self_privilege))
  end

  def has_privilege_for_person(person, privilege, self_privilege)
    return (access_denied || false) unless has_privilege_for_person? person, privilege, self_privilege
    return true
  end

end
