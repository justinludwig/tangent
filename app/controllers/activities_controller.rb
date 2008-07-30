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

class ActivitiesController < ApplicationController
  include EventsHelper

  # GET /activities
  # GET /activities.xml
  def index
    event_id = params[:event_id]
    if event_id.blank?
        return unless has_privilege :list_activities
        
        # special case start_date/end_date order to include both activities and events
        order = requested_order('start_date')
        order = "activities.#{order}, events.#{order}" if order =~ /_date/
        
        @activities = Activity.paginate :all, :include => :event, :page => requested_page, :order => order, :per_page => requested_per_page
        @can_edit = has_privilege? :edit_activities
        @can_delete = has_privilege? :delete_activities

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml => @activities }
        end
    else
        @event = Event.find(event_id)
        @activities = @event.activities.paginate :all, :page => requested_page, :order => requested_order('start_date'), :per_page => requested_per_page
        return unless has_privilege_for_event @event, :view_activities

        @can_edit = has_privilege_for_event? @event, :edit_activities
        @can_delete = has_privilege_for_event? @event, :delete_activities

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml => @activities }
        end
    end
  end

  # GET /activities/1
  # GET /activities/1.xml
  def show
    @activity = Activity.find(params[:id])
    @event = @activity.event
    return unless has_privilege_for_event @event, :view_activities

    begin
      @participant = @activity.participants.find_by_person_id current_person.id if logged_in?
    rescue ActiveRecord::RecordNotFound
    end
    @participants = @activity.participants.paginate :all, :page => requested_page, :order => requested_order, :per_page => requested_per_page

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity }
    end
  end

  # GET /activities/new
  # GET /activities/new.xml
  def new
    @event = Event.find(params[:event_id])
    @activity = Activity.new
    return unless has_privilege_for_event @event, :create_activities

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity }
    end
  end

  # GET /activities/1/edit
  def edit
    @activity = Activity.find(params[:id])
    @event = @activity.event
    return unless has_privilege_for_event @event, :edit_events
  end

  # POST /activities
  # POST /activities.xml
  def create
    @event = Event.find(params[:event_id])
    @activity = Activity.new(params[:activity])
    @activity.event = @event
    return unless has_privilege_for_event @event, :create_activities

    respond_to do |format|
      if @activity.save
        flash[:notice] = 'Activity was successfully created.'
        format.html { redirect_to edit_event_path(@event) }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /activities/1
  # PUT /activities/1.xml
  def update
    @activity = Activity.find(params[:id])
    @event = @activity.event
    return unless has_privilege_for_event @event, :edit_activities

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        flash[:notice] = 'Activity was successfully updated.'
        format.html { redirect_to(@activity) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.xml
  def destroy
    @activity = Activity.find(params[:id])
    @event = @activity.event
    return unless has_privilege_for_event @event, :delete_activities

    @activity.destroy

    respond_to do |format|
      format.html { redirect_to edit_event_path(@event) }
      format.xml  { head :ok }
    end
  end

end
