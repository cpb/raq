Before("@amqp") do |scenario|
  start_amqp
end

at_exit do
  include DependentServiceHelper
  stop_amqp
end
