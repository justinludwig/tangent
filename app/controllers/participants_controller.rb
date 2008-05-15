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

class ParticipantsController < ApplicationController
  include ParticipantsHelper

  # GET /participants
  # GET /participants.xml
  def index
    return unless has_privilege :list_participants
    @participants = Participant.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @participants }
    end
  end

  # GET /participants/1
  # GET /participants/1.xml
  def show
    @participant = Participant.find(params[:id])
    return unless has_privilege_for_participant @participant, :view_participants, :view_participants_self

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @participant }
    end
  end

  # GET /participants/new
  # GET /participants/new.xml
  def new
    @participant = Participant.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @participant }
    end
  end

  # GET /participants/1/edit
  def edit
    @participant = Participant.find(params[:id])
  end

  # POST /participants
  # POST /participants.xml
  def create
    return unless has_privilege :create_participants
    @participant = Participant.new(params[:participant])

    respond_to do |format|
      if @participant.save
        flash[:notice] = 'Participant was successfully created.'
        format.html { redirect_to(@participant) }
        format.xml  { render :xml => @participant, :status => :created, :location => @participant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @participant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participants/1
  # PUT /participants/1.xml
  def update
    return unless has_privilege :edit_participants
    @participant = Participant.find(params[:id])

    respond_to do |format|
      if @participant.update_attributes(params[:participant])
        flash[:notice] = 'Participant was successfully updated.'
        format.html { redirect_to(@participant) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @participant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /participants/1
  # DELETE /participants/1.xml
  def destroy
    return unless has_privilege :delete_participants
    @participant = Participant.find(params[:id])
    @participant.destroy

    respond_to do |format|
      format.html { redirect_to(participants_url) }
      format.xml  { head :ok }
    end
  end

  # confirm self
  def confirm
    @activity = Activity.find(params[:activity_id])
    begin
      @participant = @activity.participants.find_by_person_id current_person.id if logged_in?
    rescue ActiveRecord::RecordNotFound
    end

    # create new participant to confirm
    if @participant.blank?
      return unless has_privilege :create_participants_for_self
      @participant = Participant.new :activity_id => @activity.id, :person_id => current_person.id

      respond_to do |format|
        if @participant.save
          if @participant.confirm!
            flash[:notice] = 'Thanks for signing-up!'
          else
            flash[:error] = 'Sorry, no openings left. You have been added to the wait list.'
          end
            
          format.html { redirect_to @activity }
          format.xml  { render :xml => @participant, :status => :created, :location => @participant }
  
        else
          format.html { render :action => 'show', :controller => 'activities' }
          format.xml  { render :xml => @participant.errors, :status => :unprocessable_entity }
        end
      end

    # confirm existing participant
    else
      return unless has_privilege :edit_participants_for_self

      respond_to do |format|
        if @participant.confirm!
          flash[:notice] = 'Your participation is confirmed.'
        else
          flash[:error] = 'Sorry, no openings left. You have been added to the wait list.'
          @participant.wait!
        end
          
        format.html { redirect_to @activity }
        format.xml  { render :xml => @participant, :status => :ok, :location => @participant }

      end
    end
  end

end
