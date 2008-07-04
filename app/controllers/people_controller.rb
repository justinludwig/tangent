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

class PeopleController < ApplicationController
  include PeopleHelper
  
  # GET /people
  # GET /people.xml
  def index
    return unless has_privilege :list_people

    @people = Person.paginate :all, :page => requested_page, :order => requested_order, :per_page => requested_per_page

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])
    return unless has_privilege_for_person @person, :view_people, :view_self

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    return unless has_privilege :create_people

    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    return unless has_privilege_for_person @person, :edit_people, :edit_self
  end

  # POST /people
  # POST /people.xml
  def create
    return unless has_privilege :create_people

    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        # save first, then state-transitions (register!) will work
        @person.register!

        # automatically "login" if self-reg
        unless (self.current_person)
          self.current_person = @person
          # store user data in cookie
          remember_person_data
          
          flash[:notice] = "Thanks for signing up!"
        else
          flash[:notice] = 'Person has been successfully created.'
        end

        format.html { redirect_back_or_default(@person) }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        @register = true unless self.current_person
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Person.find(params[:id])
    return unless has_privilege_for_person @person, :edit_people, :edit_self

    respond_to do |format|
      if @person.update_attributes(params[:person])
        flash[:notice] = 'Person has been successfully updated.'
        format.html { redirect_to(@person) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person = Person.find(params[:id])
    return unless has_privilege_for_person @person, :delete_people, :delete_self
    delete_self = @person == current_person

    @person.delete!
    forget_person_data if delete_self
    flash[:notice] = (delete_self ? 'Your account' : 'Person') + ' has been deleted.'

    respond_to do |format|
      format.html { redirect_to(delete_self ? new_person_path : people_path) }
      format.xml  { head :ok }
    end
  end

  # GET /people/1/email
  # GET /people/1/email.xml
  def email
    return unless has_privilege :email_people

    @person = Person.find(params[:id])
  end
  
  # POST /people/1/send_email
  # POST /people/1/send_email.xml
  def send_email
    @person = Person.find(params[:id])
    return unless (has_privilege :email_people) && (@person.state == 'active')

    subject, body = params[:subject], params[:body]
    error = 'Please specify a body' if body.blank?
    error = 'Please specify a subject' if subject.blank?

    respond_to do |format|
      if !error && PersonMailer.deliver_personal_email(@person, current_person, subject, body)
        flash[:notice] = 'Your email has been sent.'
        format.html { redirect_to(@person) }
        format.xml  { head :ok }
      else
        flash[:error] = error
        format.html { render :action => "email" }
        format.xml  { render :xml => error, :status => :unprocessable_entity }
      end
    end
  end

end
