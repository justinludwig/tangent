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

namespace :app do

  desc "Runs all custom tangent install tasks."
  task :install => :configure do
  end

  desc "Configures tangent."
  task :configure => [:configure_application, :configure_mailer] do
  end
  
  desc "Configures tangent application settings."
  task :configure_application do
    config = {
      'common' => {}
    }
    # try to load options from existing app_config.yml
    begin
      config.merge! File.open("#{RAILS_ROOT}/config/app_config.yml") { |f| YAML.load f }
    rescue
    end

    # setup defaults (convert config strings to symbols)
    options = {
      :name => 'Tangent',
      :host => 'tangent.swwomm.com',
      :email_from_name => 'Tangent',
      :contact_email => 'contact@swwomm.com',
      :remember_me_expires => '4.months',
    }.merge! config['common'].inject({}) { |h,e| h[e[0].to_sym] = e[1]; h }

    # collect input
    puts 'configure app settings (press enter for default)'
    prompt_for_option 'display name', options, :name
    prompt_for_option 'host name', options, :host
    options[:base_url] = "http://#{options[:host]}/"
    prompt_for_option 'email-from display-name', options, :email_from_name
    prompt_for_option 'contact email address', options, :contact_email
    prompt_for_option 'remember-me duration', options, :remember_me_expires

    # write app_config.yml (save symbols as strings)
    config['common'] = options.inject({}) { |h,e| h[e[0].to_s] = e[1]; h }
    File.open("#{RAILS_ROOT}/config/app_config.yml", "w") { |f| YAML.dump config, f }
  end
  
  desc "Configures tangent mailer."
  task :configure_mailer do
    config = {
      'common' => {}
    }
    # try to load options from existing app_config.yml
    begin
      config.merge! File.open("#{RAILS_ROOT}/config/mailer.yml") { |f| YAML.load f }
    rescue
    end

    # setup defaults (convert config strings to symbols)
    options = {
      :address => 'smtp.gmail.com',
      :port => 587,
      :authentication => :plain,
      :user_name => 'mailer@swwomm.com',
      :rotate => 1,
      :rotate_start => 1,
    }.merge! config['common'].inject({}) { |h,e| h[e[0].to_sym] = e[1]; h }

    # collect input
    puts 'configure mailer (press enter for default)'
    prompt_for_option 'smtp server address', options, :address
    prompt_for_option 'smtp server port', options, :port
    prompt_for_option 'smtp server auth type', options, :authentication, Proc.new { |i| i.to_sym }
    prompt_for_option 'email account address', options, :user_name
    prompt_for_option 'email account password', options, :password
    prompt_for_option 'rotate among x email accounts', options, :rotate, Proc.new { |i| i.to_i }
    prompt_for_option 'start rotation at x:', options, :rotate_start, Proc.new { |i| i.to_i }

    # write mailer.yml (save symbols as strings)
    config['common'] = options.inject({}) { |h,e| h[e[0].to_s] = e[1]; h }
    File.open("#{RAILS_ROOT}/config/mailer.yml", "w") { |f| YAML.dump config, f }
  end

  # prompts with the specified message
  # returns the input value (or optional the default)
  # optionally converted with the specified proc
  def prompt(msg, default = nil, conversion = nil)
    input = ''
    while input.blank? do
      print "#{msg} (#{default}): "
      input = STDIN.gets.chomp
      input = default if input.blank?
    end
    conversion ? conversion.call(input) : input
  end

  # prompts with the specified message for the specified option
  # and updates the option value
  # optionally converted with the specified proc
  def prompt_for_option(msg, options, name, conversion = nil)
    options[name] = prompt msg, options[name], conversion
  end

end
