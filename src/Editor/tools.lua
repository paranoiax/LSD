local data = Editor.data

function Editor.setTool(name)
	Editor.tool = name
	if data.cursors[name] ~= nil then
		Editor.setCursor(name)
		return
	end
end