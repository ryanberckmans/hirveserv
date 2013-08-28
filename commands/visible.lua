local function visible( client )
  client.visible = true
  client.privs["invisible"] = nil
  client:msg( "You become visible." )
  chat.msg( "#lw%s#d is in the house!", client.name )
  chat.event( "connect", client )
end

chat.command( "visible", "invisible", visible, "Become visible so you can chat" )
