# Author: Gabriel Robinson
# GitHub UserName: grobin33
# Class: CS4540
#
# How many hours did it take to finish this assignment: 4.5
#
# My WebServer class allows several different 'modes'.
# If the  initialize method is called without arguments
# it sets the default port to 1234, and the host to localhost.
# If passed a port number, a socket will be created at that 
# port. If passed two arguments, a port number and true
# the WebServer will become scalable, to some extent.
# It will allow multiple clients from multiple browsers to 
# connect and receive responses.

require 'socket'

class WebServer

	# constructor with a default port of 1234
	# and sets the hostname to 'localhost'
	#
	# A custom port number can be specified with the first
	# argument and if true is specified as the second argument
	# the application will allow the binding of multiple 
	# sockets 
	def initialize(port_number = 1234, scalable = false)
		
  		@server = TCPServer.new('localhost', port_number)
		@scalable = scalable
		@request_lines = []
		@response = ""


	end


	# method creates an infinite loop, in which a socket is created.
	# The method then calls collect_request. If the scalable flag is 
	# set to true, then the main thread will fork each time the server
	# accepts a new client. An event loop will be started, upon which
	# collect_request, calls create_response, which in turn calls write
	# response.
	#
	# If the scalable flag was not set then the listen method will call
	# create response, and write response after collect request
	#
	# Upon returning the sockets are closed.
	def listen()

		loop do

			if(!@scalable)

				@socket = @server.accept
				
				collect_request
				create_response
				write_response

				@socket.close

			else 

				Thread.fork(@server.accept) do |socket|
				
					collect_request(socket)
					socket.close

				end

			end

		end


	end


	# Method that reads in the first 10 lines of an http request.
	def collect_request(socket = @socket)
	
		# Helper method to read in data from the socket
		def read_in_request(sock)
		
			request = []
			
			10.times do

                        	line = sock.gets

                        	if(line)
                        		request << line
                        	end

                	end

			return request;

		end

		# if scalable flag is set two true we continue the event loop
		# otherwise we initialize @request_lines
		if(@scalable) then
			
			
			create_response(socket, read_in_request(socket))

		else
			
			@request_lines = read_in_request(socket)

		end

	end

	
	# This method parses the request and extracts the user-agent, using regex
	# if the scalable flag is set to true. Otherwise, it simply splits the 
	# string upon finding the line containing the user agent.
	#
	# In either case it spices up the response with a little HTML
	def create_response(socket = @socket, request_lines = @request_lines)

		# Helper method to help define the response that will be sent 
		# back to the browser.
		def format_response(user_agent_feedback) 

				return "HTTP/1.1 200 OK\r\n" +
               					"Content-Type: text/html\r\n" +
               					"Content-Length: #{user_agent_feedback.bytesize}\r\n" +
               					"Connection: close\r\n\r\n" + 
						user_agent_feedback

		end
			
		# Find the User-Agent line in the HTTP request
		request_lines.each do |line|

			if line.match("User-Agent")
					
				browser = ""

				# If the scalable flag is set to true we will try and discover which browser is being used
				if(@scalable) then

					if line.match(/Edge/)

						browser = "Edge"

					elsif line.match(/Firefox/) && !line.match(/Seamonkey/)

						browser = "Firefox"

					elsif line.match(/Safari/) && !line.match(/Chrome/)

						browser = "Safari"

					elsif line.match(/MSIE/) || line == 'Moilla/5.0 ' +
						'(Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko'

						browser = "Internet Explorer"

					elsif line.match(/Chrome/) && !line.match(/Chromium/)

						browser = "Chrome"

					end

					user_agent_feedback = "<h1>You are using " + browser + "</h1>\r\n"
				
					response = format_response(user_agent_feedback)

					write_response(socket, response)


				else 

					# If the scalable flag is not set to true we simply split the 
					# line according to white space and use the second token
					user_agent_feedback = "You are using " + line.split[1] + "</h1>"

					@response = format_response(user_agent_feedback)

				end

				# Once the user agent is discovered we can break out of the loop
				break

			end

		end

	end

	# Now that you have the response string in a 'response' instance var, write 
	# it to the socket using either puts or print: some_socket.puts some_string_var 
	# or some_socket.print some_string_var That writes the string back out of the 
	# server and sends it off to the client.	
	def write_response(socket = @socket, response = @response)

  		socket.print response

	end

end


