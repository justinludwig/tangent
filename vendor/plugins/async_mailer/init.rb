require 'async_mailer'

class ActionMailer::Base
  include AsyncMailer
end