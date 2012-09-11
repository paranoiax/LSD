Editor = {}
Editor.data = {}
local data = Editor.data

function Editor.load()
	require("Editor.drawing")()
	
	GAMESTATE = "EDITOR"
	Editor.mode = "main"
	love.mouse.setVisible(true)
	-- load the editor
	-- by default load level1.lua
	Editor.setMap("level1")
	
	
end

function Editor.setMap(filepath, notify)
	-- notify means it will first ask for confirmation if a map exists and not saved
	-- this function sets the running map (in the editor)
	
	-- ask whether to save
	
	if filepath == "" then return end -- dont throw an error
	Editor.map = love.filesystem.load("levels/"..filepath..".lua")()
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