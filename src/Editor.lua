Editor = {}

function Editor.load()
	GAMESTATE = "mapedit"
	-- load the map
end

function Editor.setMap(notify)
	-- notify means it will first ask for confirmation if a map exists and not saved
	-- this function sets the running map (in the editor)
end

function Editor.saveMap()
	-- saves the map
end

function Editor.unload() -- unloads all hooks and returns to menu

end