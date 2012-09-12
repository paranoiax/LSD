Editor = {}
Editor.data = {}
local data = Editor.data

function Editor.load()
	require("Editor.data")
	require("Editor.drawing")()
	
	GAMESTATE = "EDITOR"
	Editor.mode = "main"
	Editor.debug = true
	love.mouse.setVisible(true)
	-- load the editor
	-- by default load level1.lua
	Editor.setMap("original/level1")
	
	
end

function Editor.setMap(filepath, notify)
	-- notify means it will first ask for confirmation if a map exists and not saved
	-- this function sets the running map (in the editor)
	
	-- ask whether to save
	if notify then
		-- notify the setter to save if it was saved
	end
	
	if filepath == "" then return end -- dont throw an error

	Editor.map = filepath==true and loadstring(data.newmap)() or love.filesystem.load("levels/"..filepath..".lua")()
	data.map = {}
	
	camera.x = Editor.map.player[1] - screenWidth / 2
	camera.y = Editor.map.player[2] - screenHeight / 2
	
	for a,tab in pairs({["Grey"]="sensors", ["Red"]="walls"}) do
		data.map[tab] = {}
		if Editor.map[tab] then
			for i,v in ipairs(Editor.map[tab]) do
				local x, y, w, h = unpack(v)
				local x2, y2, w2, h2 = x - w / 2, y - w / 2, w, h
				data.map[tab][i] = {
					quad = love.graphics.newQuad(0, 0, w2, h2, _G[a.."TilesW"], _G[a.."TilesW"]),
					x = x2,
					y = y2,
					tile = a
				}
			end
		end
	end
	
	--print(Editor.parse(Editor.map)) -- IT LOOKS LIKE CRAP :)
end

function Editor.saveMap()
	-- saves the map
end

function Editor.unload() -- unloads all hooks and returns to menu
	Editor.setMap("", true)
	GAMESTATE = "MENU"
	love.filesystem.load("main.lua")()
	love.load()
end

function Editor.keypressed(key)
	if key == "escape" then
		Editor.unload()
	elseif key == "f2" then
		Editor.saveMap()
	elseif key == "f1" then
		Editor.showTileSelector()
	end
end

function Editor.parse(t, _no)
	print(type(t))
	assert(type(t) == "table", "not a table!")
	local s = "{"
	for k, v in pairs(t) do
		local tk, tv = type(k), type(v)
		if tk == "boolean" then
			k = k and "[true]" or "[false]"
		elseif tk == "string" then
			if string.find(k, "[%c%p%s]") then
				k = '["'..k..'"]'
			end
		elseif tk == "number" then
			k = "["..k.."]"
		elseif tk == "table" then
			k = "["..Editor.parse(k).."]"
		end
		if tv == "boolean" then
			v = v and "true" or "false"
		elseif tv == "string" then
			v = string.format("%q", v)
		elseif tv == "table" then
			v = Editor.parse(v, true)
		end
		s = s..k.."="..v..","
	end
	local ret = _no and "" or "return "
	return s.."}"
end