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
require 'participant_mailer'

class ParticipantMailerTest < Test::Unit::TestCase
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

  def test_update_notification_for_owner
    owner = people :alice
    participant = participants :candlemas_attendee_bob
    person = participant.person
    activity = participant.activity
    event = activity.event

    mail = ParticipantMailer.create_update_notification_for_owner participant, owner
    assert_equal "Attendee for Candlemas: Participant Confirmed", mail.subject
    assert_match /Hi #{owner}/, mail.body
    assert_match /Event: #{event} <#{AppConfig.base_url}events\/#{event.id}>/, mail.body
    assert_match /Activity: #{activity} <#{AppConfig.base_url}activities\/#{activity.id}>/, mail.body
    assert_match /Participant: #{person} <#{AppConfig.base_url}people\/#{person.id}>/, mail.body
    assert_match /Status: confirmed/, mail.body
  end

  def test_update_notification_for_self
    participant = participants :candlemas_attendee_bob
    person = participant.person
    activity = participant.activity
    event = activity.event

    mail = ParticipantMailer.create_update_notification_for_self participant
    assert_equal "Attendee for Candlemas: You are Confirmed", mail.subject
    assert_match /Hi #{person}/, mail.body
    assert_match /Event: #{event} <#{AppConfig.base_url}events\/#{event.id}>/, mail.body
    assert_match /Activity: #{activity} <#{AppConfig.base_url}activities\/#{activity.id}>/, mail.body
    assert_match /Status: confirmed/, mail.body
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/participant_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
