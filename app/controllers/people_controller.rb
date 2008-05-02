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
    return access_denied unless has_privilege? :view_people || (@person == current_person && has_privilege?(:view_self))

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
    return access_denied unless has_privilege? :edit_people || (@person == current_person && has_privilege?(:edit_self))

    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.xml
=begin
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        flash[:notice] = 'Person was successfully created.'
        format.html { redirect_to(@person) }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end
=end
  def create
    return unless has_privilege :create_people

    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        # save first, then state-transitions (register!) will work
        @person.register!

        # automatically "login" if self-reg
        if (!self.current_person)
          self.current_person = @person unless self.current_person
          flash[:notice] = "Thanks for signing up!"
        else
          flash[:notice] = 'Person was successfully created.'
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
=begin
  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @person = Person.new(params[:person])
    @person.register! if @person.valid?
    if @person.errors.empty?
      self.current_person = @person
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end
=end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    return access_denied unless has_privilege? :edit_people || (@person == current_person && has_privilege?(:edit_self))

    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        flash[:notice] = 'Person was successfully updated.'
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
    return access_denied unless has_privilege? :delete_people || (@person == current_person && has_privilege?(:delete_self))

    @person = Person.find(params[:id])
    @person.delete!

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end

  # GET /people/1/email
  # GET /people/1/email.xml
  def email
    return unless has_privilege :email_people

    # todo create email.html.erb
    @person = Person.find(params[:id])
  end
  
  # POST /people/1/send_email
  # POST /people/1/send_email.xml
  def send_email
    return unless has_privilege :email_people

    @person = Person.find(params[:id])
=begin
    respond_to do |format|
      # todo
      if PersonMailer.deliver_personal_email(person, current_person, subject, body)
        flash[:notice] = 'Your email was sent.'
        format.html { redirect_to(@person) }
        format.xml  { head :ok }
      else
        format.html { render :action => "email" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
=end
  end

end
