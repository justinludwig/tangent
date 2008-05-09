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

module PrivilegedSystem
  protected

    # returns true if current user has specified privilege
    def has_privilege?(*privilege)
      return privilege.all? do |p|
        return true if ANONYMOUS_USER_PRIVILEGES.include?(p)
        return true if logged_in? && AUTHENTICATED_USER_PRIVILEGES.include?(p)
        return true if super_user? && SUPER_USER_PRIVILEGES.include?(p)
      end
    end

    # returns true if current user has specified privilege
    # returns false and displays access_denied page otherwise
    def has_privilege(*privilege)
      return true if has_privilege? *privilege
      access_denied
      return false
    end

    def privilege_action_name
      return PRIVILEGE_ACTION_NAMES[action_name] || action_name
    end

    def privilege_controller_name
      return controller_name
    end

  private
    SUPER_USER_IDS = [ 1, ]
    SUPER_USER_PRIVILEGES = [
      # people
      :edit_people,
      :delete_people,
      :list_people,
      # events
      :edit_events,
      :delete_events,
      :list_events,
      # activities
      :edit_activities,
      :delete_activities,
      # participants
      :create_participants,
      :edit_participants,
      :delete_participants,
      :list_participants,
    ]
    AUTHENTICATED_USER_PRIVILEGES = [
      # people
      :view_people,
      :view_self,
      :edit_self,
      :delete_self,
      # events
      :create_events,
      :list_events_coordinated_for_self,
      # activities
      :create_activities,
      # participants
      :create_participants_for_self,
      :view_participants,
      :view_participants_for_self,
      :edit_participants_for_self,
      :delete_participants_for_self,
      :list_participants_for_self,
    ]
    ANONYMOUS_USER_PRIVILEGES = [
      # people
      :create_people,
      # events
      :view_events,
      # activities
      :view_activities,
    ]
    PRIVILEGE_ACTION_NAMES = {
      'index' => 'list',
      'show' => 'view',
      'new' => 'create',
      'update' => 'edit',
      'destroy' => 'delete',
    }

    def super_user?
      logged_in? && SUPER_USER_IDS.include?(current_person.id)
    end
end
