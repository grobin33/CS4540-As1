# Put your class definition here
require 'socket'

class WebServer

	# constructor with a default port of 1234
	# and sets the hostname to 'localhost'

	def initialize(port_number = 1234)
		
		@request_lines = []
		@response = ""

  		@server = TCPServer.new('localhost', port_number)

	end


	# method creaes a socket and calls collect_request, create_response
	# and write response
	def listen()

		loop do

			@socket = server.accept

			collect_request
			create_response
			write_response

			@socket.close

		end

	end


	def collect_request()


		# read the first ten lines of the http request
		10.times do
			@request_lines << @socket.gets
		end

	end

	
	# parses the request and extracts the user-agent
	# First, you'll need to find the line with the user agent in it. HINT: 
	# it's the third line in a standard 10-line http request. You can either 
	# go after it directly using array index notation (e.g. array[2]) or you 
	# can search for it using the select method on arrays. Then extract the 
	# first term from that line to get the user agent. There are lots of ways 
	# to do this, e.g. with a regex (in Ruby the match() function returns a 
	# MatchData object) but the simple approach just splits up the string on 
	# whitespace and grabs the second token. My user-agent line looks like this: 
	# User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:61.0) 
	# Gecko/20100101 Firefox/61.0 I'm going to call split on the line, which will 
	# break up the line by whitespace and return an array of strings, then I'll 
	# just grab the second one, e.g. user_agent_line.split[1]
	def create_response()

		@request_lines.each do |line|
			if line.match("User-Agent")
				@response = "200 OK\r\nYou are using " + line.split[1] + "\r\n"
			end
		end

	end

	# Now that you have the response string in a 'response' instance var, write 
	# it to the socket using either puts or print: some_socket.puts some_string_var 
	# or some_socket.print some_string_var That writes the string back out of the 
	# server and sends it off to the client.	
	def write_response()

  		@socket.print @response

	end

end
