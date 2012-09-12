Editor.data.topbar = { -- only for the menu
	texts = {"Exit", "Options", "Clear", "Play"},
	positions = {}
}

Editor.data.toolbar = {
	components = {
		{ -- returns camera on the player
			"Lie camera on character",
			"home.png",
			"home"
		},
		{
			"Select",
			"cursor.png",
			"select"
		},
		{
			"Pan",
			"pan.png",
			"pan"
		},
		"[seperator]",
		{
			"View frame",
			"view-frame.png",
			"view_frame"
		},
		{
			"View full",
			"view-real.png",
			"view_real"
		},
		"[seperator]",
		{
			"Rectangle Wall",
			"wall_rectangle.png",
			"wall-rect"
		},
		--[[{ -- excluded because I can't detect if a group of vertices forms a convex shape
			"Polygonic wall",
			"wall_polygon.png",
			"wall-poly"
		},--]]
		{
			"Circlic wall",
			"wall_circle.png",
			"wall-circle"
		},
		"[seperator]",
		{
			"Move",
			"move.png",
			"move",
		},
		{
			"Message",
			"message.png",
			"msg"
		},
		{
			"Rotate",
			"rotate.png",
			"rotate"
		},
		{
			"Scale",
			"scale.png",
			"scale"
		},
	}
}