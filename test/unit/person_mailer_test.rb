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

require File.dirname(__FILE__) + '/../test_helper'
require 'person_mailer'

class PersonMailerTest < Test::Unit::TestCase
  fixtures :people
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_signup_notification
    alice = people :alice
    mail = PersonMailer.create_signup_notification alice
    assert_match /Hi #{alice}/, mail.body
    assert_match /Email: #{alice.email}/, mail.body
    assert_match /Password: #{alice.password}/, mail.body
  end

  def test_deletion_notification
    alice = people :alice
    mail = PersonMailer.create_deletion_notification alice
    assert_match /Hi #{alice}/, mail.body
  end

  def test_personal_email
    alice = people :alice
    bob = people :bob
    mail = PersonMailer.create_personal_email alice, bob, "hi", "you"
    assert_match /#{bob} <#{bob.email}> sez/, mail.body
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/person_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
