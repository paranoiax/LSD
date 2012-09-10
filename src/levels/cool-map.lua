-- This map works, but none of the features (except boundaries, player position, normal walls and normal sensors) will work. This is just to show the format.
return {
	boundaries = 3400,
	player = {45,100},
	
	walls = {
		{20,160,60,40},
		{720,260,120,40},
		{860,100,120,100},
		{1080,280,120,40},
		{1300,280,120,40},
		{1520,280,120,40},
		{1520,500,120,40},
	},
	
	sensors = {
		{0,0,680,80},
		{0,220,680,80},
		{1020,60,20,320},
		{1240,60,20,320},
		{1040,360,200,20},
		{1260,360,200,20},
		{1460,60,20,540},
		{1680,60,20,540},
		{1480,580,200,20},
	},
	
	lasers = {
		{
			0, 0, 90, -- x, y, angle
			default = true, -- starts on or off?
			interval = 1000, -- optional: the time between every laser on/off change. cannot be used with button.
			button = "id", -- this links to the button, optional. cannot be used with interval
		}	
	},
	
	movingWalls = {
		{
			60, 40, -- w, h
			nodes = { -- nodes are the x,y positions to move through... this can be as many as you want
				{20,160},
				{720, 260}
			},
			delay = 1000 -- delay to start moving, this is so you can exactly time stuff (in milliseconds)
		}
	},
	
	buttons = {
		{0, 0, 20, 20, id="id"} -- x, y, w, h      optional: id="identification", this is what links buttons to other items
	},
	
	fans = {
		{
			0, 0, 20, 20, 25, -- x, y, w, h, angle
			strength = 5, -- strength of the fan
		}
	},
	
	powerup = {
		{
			0, 0, -- x, y
			type = "speed", -- can be SlowTime, Invincibility, Fly, Speed
			time = 1000, --time in ms the powerup lasts for
		}
	},
	
	message = { --shows a message in the background (behind all elements in the game, except background)
		{
			0, 0, 20, 20, -- x, y, w, h
			msg = [[
				Hello World
				My name is LSD
				I am not the drug, but the super cool game.
				Enjoy!
			]],
		}
	}
}