$ASYNC_MAILER_THREADS = []

module AsyncMailer
  %w(smtp sendmail).each do |type|
    define_method("perform_delivery_async_#{type}") do |mail|
      $ASYNC_MAILER_THREADS << Thread.start do
        send "perform_delivery_#{type}", mail
      end
      $ASYNC_MAILER_THREADS.delete self
    end
  end
end

def finish_started_deliveries
  $ASYNC_MAILER_THREADS.each do |t|
    t.join if t.alive? && t != Thread.current
  end
  $ASYNC_MAILER_THREADS.clear
end

at_exit do
  finish_started_deliveries
end

old_handler = trap('TERM') do
  finish_started_deliveries
  if old_handler
    old_handler.call
  else
    exit
  end
end
