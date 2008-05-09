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

# This controller handles my stuff.  
class MyStuffController < ApplicationController
  before_filter :login_required
  
  # GET /my
  # GET /my.xml
  def index
    return unless has_privilege :list_events_coordinated_for_self, :list_participants_for_self

    @events = current_person.events.paginate :all, :page => requested_page, :order => requested_order('start_date'), :per_page => requested_per_page, :conditions => "start_date > '#{Time.now.utc.to_s :db}'"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end
  
  # GET /my/events
  # GET /my/events.xml
  def events(before = nil, after = nil)
    return unless has_privilege :list_events_coordinated_for_self

    @page_title ||= 'My Events'

    before = params[:before].to_time if before.blank? && !params[:before].blank?
    after = params[:after].to_time if after.blank? && !params[:after].blank?

    cond = ''
    cond << "start_date < '#{before.to_s :db}'" unless before.blank?
    cond << ' and ' unless before.blank? || after.blank?
    cond << "start_date > '#{after.to_s :db}'" unless after.blank?
    cond = nil if cond.blank?

    @events = current_person.events.paginate :all, :page => requested_page, :order => requested_order('start_date'), :per_page => requested_per_page, :conditions => cond

    respond_to do |format|
      format.html { render :template => 'events/index' }
      format.xml  { render :xml => @events }
    end
  end

  # GET /my/events/past
  # GET /my/events/past.xml
  def events_past
    params[:order] = 'start_date DESC' unless params[:order]
    @page_title = "My Past Events"
    events Time.now.utc
  end

  # GET /my/events/upcoming
  # GET /my/events/upcoming.xml
  def events_upcoming
    @page_title = "My Upcoming Events"
    events nil, Time.now.utc
  end

end
