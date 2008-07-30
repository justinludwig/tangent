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

class InitialModels < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :email,                     :string, :limit => 50
      t.column :display_name,              :string, :limit => 50
      t.column :crypted_password,          :string, :limit => 50
      t.column :salt,                      :string, :limit => 50
      t.column :state, :string, :limit => 20, :null => :no, :default => 'passive'
      t.column :deleted_at,                :datetime
      t.timestamps
    end

    create_table :events do |t|
      t.column :name, :string, :limit => 50
      t.column :details, :text
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :tags, :string, :limit => 100
      t.timestamps
    end

    create_table :event_coordinators do |t|
      t.references :event
      t.references :coordinator
    end

    create_table :activities do |t|
      t.references :event
      t.string :name, :limit => 50
      t.text :details
      t.string :criteria, :limit => 100
      t.integer :openings
      t.datetime :start_date
      t.datetime :end_date
      t.string :tags, :limit => 100
      t.timestamps
    end

    create_table :participants do |t|
      t.references :activity
      t.references :person
      t.string :state, :limit => 20, :null => :no, :default => 'waiting'
      t.timestamps
    end
  end

  def self.down
    drop_table :people
    drop_table :events
    drop_table :event_coordinators
    drop_table :activities
    drop_table :participants
  end
end
