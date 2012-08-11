Client = { }

local handlers = require( "include.handlers" )
local command = require( "include.command" )

chat.clients = { }

function Client:new( socket )
	socket:settimeout( 0 )

	local client = {
		socket = socket,
		state = "connecting",
		dataHandler = coroutine.create( handlers.connect ),
		commandHandlers = { },
		privs = { },
		settings = { },
	}

	assert( coroutine.resume( client.dataHandler, client ) )

	setmetatable( client, { __index = Client } )

	table.insert( chat.clients, client )

	return client
end

function Client:kill()
	self.socket:shutdown()

	if self.state == "authed" then
		self:xmsg( "#lw%s#d left chat.", self.name )
	end

	for i, client in ipairs( chat.clients ) do
		if client == self then
			table.remove( chat.clients, i )

			break
		end
	end
end

function Client:raw( data )
	self.socket:send( data )
end

function Client:send()
	error( "Client:send not implemented for protocol `%s'" % self.protocol )
end

function Client:msg()
	error( "Client:msg not implemented for protocol `%s'" % self.protocol )
end

function Client:chat()
	error( "Client:chat not implemented for protocol `%s'" % self.protocol )
end

function Client:handleCommand()
	error( "Client:handleCommand not implemented for protocol `%s'" % self.protocol )
end

function Client:hasPriv( priv )
	if priv == "user" then
		return self.userID ~= nil
	end

	return not priv or self.privs.all or self.privs[ priv ]
end

function Client:xmsg( form, ... )
	local message = form:format( ... )

	for _, client in ipairs( chat.clients ) do
		if client ~= self and client.state == "authed" then
			client:msg( message )
		end
	end
end

function Client:chatAll( message )
	for _, client in ipairs( chat.clients ) do
		if client ~= self and client.state == "authed" then
			client:chat( message )
		end
	end
end

function Client:pm( message )
	command.doCommand( self, message )
end

function Client:nameChange( newName )
	if self.state == "authed" then
		self:xmsg( "#lw%s#d changed their name to #lw%s#d.", self.name, newName )
	end

	self.name = newName
end

function Client:setDataHandler( handler )
	self.dataHandler = coroutine.create( handler )

	assert( coroutine.resume( self.dataHandler, self ) )
end

function Client:pushHandler( handler, name )
	local coro = coroutine.create( handler )

	table.insert( self.commandHandlers, coro )

	assert( coroutine.resume( coro, self, name ) )
end

function Client:replaceHandler( handler, name )
	table.remove( self.commandHandlers )

	self:pushHandler( handler, name )
end

function Client:command( command, args )
	local coro = self.commandHandlers[ #self.commandHandlers ]

	assert( coroutine.resume( coro, command, args ) )

	-- can't test coro incase it calls Client:replaceHandler
	if coroutine.status( self.commandHandlers[ #self.commandHandlers ] ) == "dead" then
		table.remove( self.commandHandlers )
	end
end

function Client:data( data )
	assert( coroutine.resume( self.dataHandler, data ) )
end

function chat.msg( form, ... )
	local message = form:format( ... )

	for _, client in ipairs( chat.clients ) do
		if  client.state == "authed" then
			client:msg( message )
		end
	end
end