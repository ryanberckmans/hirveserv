local function who( client )
  if not client.visible then
    client:msg("You may not use the #lwwho#d command while invisible.")
	  return
	end

	local output = "Online: #lwyou"

	for _, other in ipairs( chat.clients ) do
		if other ~= client and other.state == "chatting" and other.visible then
			output = output .. " " .. other.name
		end
	end

	client:msg( output )
end

chat.command( "who", nil, who, "Shows who is online" )
chat.listen( "connect", who )
