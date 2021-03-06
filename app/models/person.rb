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

require 'digest/sha1'
class Person < ActiveRecord::Base
  has_many :event_coordinators, :foreign_key => 'coordinator_id', :dependent => :destroy
  has_many :events, :through => :event_coordinators, :uniq => true, :order => "start_date"

  has_many :participants, :dependent => :destroy
  has_many :activities, :through => :participants, :uniq => true, :include => :event, :order => "events.start_date, activities.start_date"

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :email
  validates_length_of       :email,    :maximum => 50
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i 
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 8..50, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  before_save :encrypt_password
  validates_presence_of     :display_name
  validates_length_of       :display_name,:maximum => 50
  validates_format_of       :display_name,:with => /\S/ 
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :password, :password_confirmation, :display_name

  acts_as_state_machine :initial => :passive
  state :passive
  state :pending
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :active, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => :pending, :to => :active 
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active
    transitions :from => :suspended, :to => :pending
    transitions :from => :suspended, :to => :passive
  end

  def to_s
    display_name
  end

  # characters used by random_password
  # include all ascii chars, except ones that look similar
  # (like zero and upper-case letter 0)
  #RANDOM_PASSWORD_CHARACTERS = (33..126).map { |i| i.chr }.reject { |i| ['0', 'O', '1', 'I', 'l', '`'].include? i }
  RANDOM_PASSWORD_CHARACTERS = (('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a).reject { |i| ['0', 'O', '1', 'I', 'l'].include? i }

  # Generates a new random password
  def self.random_password
    Array.new(10) { RANDOM_PASSWORD_CHARACTERS[rand(RANDOM_PASSWORD_CHARACTERS.size)]}.join
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_in_state :first, :active, :conditions => {:email => login} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  # Returns true if specified password matches user password
  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  # Sets the user's password to a new random password
  def random_password
    @password_confirmation = @password = self.class.random_password
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def do_delete
      PersonMailer.deliver_deletion_notification self
      self.deleted_at = Time.now.utc

      # purge all personal information
      self.display_name = 'Deleted Person'
      self.email = nil
      self.crypted_password = nil
      self.salt = nil

      # save without validation
      self.save false
    end

    def do_activate
      self.deleted_at = nil
    end
end
