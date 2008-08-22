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

  # sign-up as:
  # authenticated person
  # un-authenticated but registered person
  # un-authenticated and un-registered person
  def sign_up
    unless logged_in?
      email = params[:email]
      password = params[:password]

      # check if registered, active person
      @person = Person.find_in_state :first, :active, :conditions => {:email => email}
      @activity = Activity.find params[:activity_id]

      # if new person, register
      if @person.nil?
        return unless has_privilege :create_people

        # create new person with some defaults (use first part of email for display name)
        @person = Person.new params
        @person.display_name = /[^@]*/.match(email || '')[0] unless params[:display_name]
        @person.random_password unless password

        # save first, then state-transitions (register!) will work
        if @person.save
          @person.register!

        else
          # error saving: return to activity page with email filled-in
          flash[:error] = @person.errors.full_messages.join '; '
          return respond_to do |format|
            format.html { redirect_to "#{url_for @activity}?email=#{email}" }
            format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
          end
        end

      # if registered, make person specify correct password
      elsif !@person.authenticated? password
        @event = @activity.event
        flash[:error] = 'Wrong password.' unless password.blank?
        
        return respond_to do |format|
          format.html # sign_up.html.erb
          format.xml { request_http_basic_authentication AppConfig.name }
        end
      end

      # initialize authenticated session
      self.current_person = @person
      remember_person_data
    end

    # confirm self
    confirm
  end

  # confirm self
  def confirm
    @activity = Activity.find params[:activity_id]
    @participant = @activity.participants.find_by_person_id current_person.id

    # update existing participant
    if @participant
      return unless has_privilege :edit_participants_for_self

    # create new participant
    else
      return unless has_privilege :create_participants_for_self

      @participant = Participant.new :activity_id => @activity.id, :person_id => current_person.id
      unless @participant.save
        flash[:error] = @participant.errors.full_messages.join '; '
        return respond_to do |format|
          format.html { redirect_to @activity }
          format.xml  { render :xml => @participant.errors, :status => :unprocessable_entity }
        end
      end

      notice = 'Thanks for signing-up!'
    end

    # confirm participant
    if @participant.confirm! && @participant.confirmed?
      flash[:notice] = notice || 'Your participation is confirmed.'
    else
      flash[:error] = 'Sorry, no openings left. You have been added to the wait list.'
    end
        
    respond_to do |format|
      format.html { redirect_to @activity }
      format.xml  { render :xml => @participant, :status => :ok, :location => @participant }
    end
  end

  # withdraw self
  def withdraw
    return unless has_privilege :edit_participants_for_self
    
    @activity = Activity.find params[:activity_id]
    @participant = @activity.participants.find_by_person_id current_person.id
    
    @participant.withdraw! if @participant
    flash[:notice] = 'Your participation is withdrawn.'
        
    respond_to do |format|
      format.html { redirect_to @activity }
      format.xml  { render :xml => @participant, :status => :ok, :location => @participant }
    end
  end

end
