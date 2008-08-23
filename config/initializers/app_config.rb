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

require 'ostruct'
require 'yaml'

# from http://kpumuk.info/ruby-on-rails/flexible-application-configuration-in-ruby-on-rails/
# load config settings into AppConfig class
config = OpenStruct.new YAML.load_file("#{RAILS_ROOT}/config/app_config.yml")
env_config = config.send RAILS_ENV if RAILS_ENV.blank?
config.common.update env_config unless env_config.blank?
::AppConfig = OpenStruct.new config.common

# initialize other classes with app_config settings
ActionMailer::Base.default_url_options[:host] = AppConfig.host
# todo: Rails::Configuration[:time_zone] = AppConfig.time_zone
