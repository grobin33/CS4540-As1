# Put your class definition here
require 'socket'

class WebServer

	# constructor with a default port of 1234
	# and sets the hostname to 'localhost'

	def web_server(port_number = 1234)

  	@server = TCPServer.new('localhost', port_number)

	end


	def listen()
		loop do

			@socket = server.accept

			colect_request

			create_response

			write_response

		end
	end

	
	def collect_request()

		@request = []
		10.times do
			@request << @socket.gets
		end

	end

	
	def create_response()
	end

	
	def write_response()
	end

end
