local EntriesPerPage = 10

local categories = { }
local categoriesList = { }

local pages = { }

local function checkClash( name )
	assert( not categories[ name ] and not pages[ name ], "name clash: %s" % name )
end

local function loadPage( path )
	local page = assert( io.contents( path ) )
	local title, body = page:match( "^([^\n]+)\n+(.+)$" )

	return {
		title = title,
		body = body,
	}
end

local function addPage( path, name )
	if not name then
		return
	end

	checkClash( name )

	pages[ name ] = loadPage( path, name )
	pages[ name ].name = name
end

local function addMultiPage( path, name )
	local info = assert( io.contents( "%s/%s.txt" % { path, name } ) )
	local title, files = info:match( "^([^\n]+)%s+(.+)$" )

	local page = {
		name = name,
		title = title,
		pages = { },
	}

	for file in files:gmatch( "([^\n]+)" ) do
		table.insert( page.pages, loadPage( "%s/%s.txt" % { path, file } ) )
	end

	checkClash( name )

	pages[ name ] = page
end

local function addCategory( path, name )
	checkClash( name )

	local description = assert( io.contents( "%s/%s.txt" % { path, name } ) )

	local category = {
		name = name,
		description = description:trim(),
		pages = { },
	}

	for file in lfs.dir( path ) do
		if file ~= "." and file ~= ".." and file ~= name .. ".txt" then
			local fullPath = "%s/%s" % { path, file }
			local attr = lfs.attributes( fullPath )

			file = file:lower()

			if attr.mode == "directory" then
				addMultiPage( fullPath, file )
			else
				file = file:match( "^(.+)%.txt$" )

				addPage( fullPath, file )
			end

			table.insert( category.pages, pages[ file ] )
		end
	end

	table.sortByKey( category, "name" )

	categories[ name ] = category
	table.insert( categoriesList, category )
end

local function buildWiki()
	for file in lfs.dir( "wiki" ) do
		if file ~= "." and file ~= ".." then
			local fullPath = "wiki/" .. file
			local attr = lfs.attributes( fullPath )

			file = file:lower()

			if attr.mode == "directory" then
				if io.readable( fullPath .. "/pages.txt" ) then
					addMultiPage( fullPath, file )
				else
					addCategory( fullPath, file )
				end
			else
				local name = file:match( "^(.+)%.txt$" )

				addPage( fullPath, name )
			end
		end
	end

	table.sortByKey( categories, "name" )
end

chat.command( "rebuildwiki", "all", function( client )
	categories = { }
	categoriesList = { }
	pages = { }

	local ok, err = pcall( buildWiki )

	if not ok then
		client:msg( "Rebuild failed! %s", err )
	else
		client:msg( "Rebuilt." )
	end
end, "Rebuild the wiki" )

-- helper function which toggles the presense of an 'S' on the end of a string
local function addOrRemoveS(s)
  if s:len() < 2 then
    return s
  end
  if (s:sub(-1):upper():match("S")) then
    return s:sub(0,-2)
  else
    return s .. "s"
  end  
end

local function wikiNoArgs( client )
		local output = "#lwThe wiki is split into the following categories:"

		for _, category in ipairs( categoriesList ) do
			output = output .. "\n    #ly%s #d- %s" % {
				category.name,
				category.description,
			}
		end

		client:msg( "%s", output )
end

local function wikiWithString( client, name, doRecursiveSmartCorrectIfNil )
    local doRecursiveSmartCorrect = not doRecursiveSmartCorrectIfNil -- this parameter will always be nil for the top-level invocation of the function, and serves as a ghetto base-case for the smart-correct recursion
		name = name:lower()

		if categories[ name ] then
			local output = "#lwPages in #ly%s#lw:" % name

			for _, page in ipairs( categories[ name ].pages ) do
				output = output .. "\n    #ly%s #d- %s" % {
					page.name,
					page.title,
				}
			end

			client:msg( "%s", output )

			return
		end

		if pages[ name ] then
			if pages[ name ].pages then
				local output = "#ly%s#lw is split into #ly%d#lw pages:" % {
					name,
					#pages[ name ].pages,
				}

				for i, page in ipairs( pages[ name ].pages ) do
					output = output .. "\n    #ly%d #d- %s" % {
						i,
						page.title,
					}
				end

				client:msg( "%s", output )
			else
				client:msg( "#lwShowing #ly%s#lw:\n#d%s", name, pages[ name ].body )
			end

			return
		end

    if doRecursiveSmartCorrect then
		  wikiWithString(client, addOrRemoveS(name), true) -- repeat the entire lookup, this time passing "true" as the 3rd arg to disable smart-correct recursion (which'd be infinite recursion)
    else
		  client:msg( "No wiki entry for #ly%s#d.", name )
    end
end
local function wikiWithStringAndNumber( client, name, page, doRecursiveSmartCorrectIfNil )
    local doRecursiveSmartCorrect = not doRecursiveSmartCorrectIfNil -- this parameter will always be nil for the top-level invocation of the function, and serves as a ghetto base-case for the smart-correct recursion )
		name = name:lower()
		page = tonumber( page )

		if pages[ name ] then
			if pages[ name ].pages then
				if pages[ name ].pages[ page ] then
					client:msg( "#lwShowing #ly%s#lw: #d(page #lw%d#d of #lw%d#d)\n%s",
						name,
						page, #pages[ name ].pages,
						pages[ name ].pages[ page ].body
					)
				else
					client:msg( "#lwBad page number." )
				end
			else
				client:msg( "#lwShowing #ly%s#lw:\n#d%s", name, pages[ name ].body )
			end

			return
		end

    if doRecursiveSmartCorrect then
		  wikiWithStringAndNumber(client, addOrRemoveS(name), page, true) -- repeat the entire lookup, this time passing "true" as the 3rd arg to disable smart-correct recursion (which'd be infinite recursion)
    else
		  client:msg( "No wiki entry for #ly%s#d.", name )
    end
end

local wikicommand = {
	[ "^$" ] = wikiNoArgs,

	[ "^(%S+)$" ] = wikiWithString,

	[ "^(%S+)%s+(%d+)$" ] = wikiWithStringAndNumber,
}

local wikicommanderrormsg = "[<category> | <page> [page number]], try these:  \"wiki\"   \"wiki scripts\"   \"wiki tomb\"   \"wiki tomb 1\""
local wikihelpmsg = "Wiki, try these:  \"wiki\"   \"wiki scripts\"   \"wiki tomb\"   \"wiki tomb 1\""

chat.command( "wiki", nil, wikicommand, wikicommanderrormsg, wikihelpmsg )
chat.command( "w", nil, wikicommand, wikicommanderrormsg, "alias for wiki" )

buildWiki()
