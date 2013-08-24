local function who( client )
	local output = "Online: #lwyou"

  if not client.visible then
		 output = output .. "(invisible)"
  end

	for _, other in ipairs( chat.clients ) do
		if other ~= client and other.state == "chatting" and other.visible then
			output = output .. " " .. other.name
		end
	end

	client:msg( output )
end

chat.command( "who", nil, who, "Shows who is online" )
chat.listen( "connect", who )
