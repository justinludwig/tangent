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

class EventsController < ApplicationController
  include EventsHelper

  # GET /events
  # GET /events.xml
  def index
    return unless has_privilege :list_events

    @events = Event.paginate :all, :page => requested_page, :order => requested_order, :per_page => requested_per_page

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    return unless has_privilege :view_events

    @event = Event.find(params[:id])
    @activities = @event.activities.paginate :all, :page => requested_page, :order => requested_order('name'), :per_page => requested_per_page

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    return unless has_privilege :create_events

    @event = Event.new
    @event.temp_coordinator_ids = [ current_person.id ]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    return unless has_privilege_for_event @event, :edit_events

    @activities = @event.activities.paginate :all, :page => requested_page, :order => requested_order('name'), :per_page => requested_per_page
  end

  # POST /events
  # POST /events.xml
  def create
    return unless has_privilege :create_events

    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        @event.activities.create :name => 'Attendee'

        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    return unless has_privilege_for_event @event, :edit_events

    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    return unless has_privilege_for_event @event, :delete_events

    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end
end
