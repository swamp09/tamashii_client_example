require 'tamashii/client'

# configuration for client. Can be seperated into other file
Tamashii::Client.config do
  # whether to use TLS or not. Here we connect to 'wss', so the value is true
  use_ssl true
  # the hostname WITHOUT url scheme
  host "echo.websocket.org"
  # the port to connect with. 443 for HTTPS and WSS
  # Note the current version client does not infer the port from 'use_ssl'
  # So you must explictly specifiy the port to use
  port 443
  # the log file for internel connection log
  # default is STDOUT
  log_file 'tamashii.log'
end

client = Tamashii::Client::Base.new
@server_opened = false

# callback for server opened
# called when the WebSocket connection is readt
client.on(:open) do
  @server_opened = true
end

# callback for receving messages
# The data received is represented in a byte array
# You may need to 'pack' it back to Ruby string
client.on(:message) do |message|
  puts "Received: #{message.pack('C*')}"
end


# sending loop
# We send a request to server every second and terminates after 10 seconds
# In the begining, the server is not opened so the sending may fail.
count = 0
loop do
  sleep 1
  if @server_opened # can also use 'client.opened?'
    client.transmit "Hello World! #{count}"
  else
    puts "Unable to send #{count}: server not opened"
  end
  count += 1
  if count >= 10
    client.close
    break
  end
end
