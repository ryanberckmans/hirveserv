-- forceauth allows a user to authenticate and gain access to additional commands
-- while the server is in non-authentication mode (i.e. chat.config.auth == false)

if not chat.config.auth then
  chat.command( "forceauth", nil, function( client )
    if client.userID then
      client:msg( "You're already logged in, #lwforceauth#d does nothing." )
    else
      client:msg( "Forcibly asking for your password..." )
      client:replaceHandler( authHandler )
    end
  end, "forcibly login to gain additional commands" )
end
