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

require "smtp_tls"

config = YAML.load_file("#{RAILS_ROOT}/config/mailer.yml")
env_config = config[RAILS_ENV]
# merge specific environment settings over common settings
config['common'].update(env_config) unless env_config.nil?
# convert strings to symbols
ActionMailer::Base.smtp_settings = config['common'].inject({}) { |h,e| h[e[0].to_sym] = e[1]; h }
