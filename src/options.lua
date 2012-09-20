function generateWhitespace(n)
	local w = ' '
	for i=2, n do
		w = w .. " "
	end
	return w
end

local sw, sh = love.graphics.getMode()
local frame = loveframes.Create("frame")
frame:SetSize(sw/2, sh/2)
frame:Center()
--frame:SetY(sh-450)
frame:SetName("Options" .. generateWhitespace(150) .. "Press ESC to return to menu")
frame:SetVisible(false)
frame:ShowCloseButton(false)

options = {
	graphics = {},
	audio = {},
	cheats = {}
}
options.audio.music = true
options.audio.sfx = true
options.graphics.particleEffects = true
options.graphics.shakeScreen = true
options.graphics.slowmotion = true
options.graphics.motionblur = true
options.cheats.timeOut = false
options.cheats.SensorsAreFtw = false
options.cheats.colorfulExplosion = false

local strfrm = string.format
function string.format(...)
	local args = {...}
	local t = {}
	for i,v in ipairs(args) do
		t[i] = tostring(v)
	end
	return strfrm(unpack(t))
end

local tabs = loveframes.Create("tabs", frame)
tabs:SetPos(5, 30)
do
	local w, h = frame:GetSize()
	tabs:SetSize(w-10, h-35)
end

local tabItems = {
	{"General"},
	{"Audio"},
	{"Graphics",
		{
			{
				"Particle Effects",
				"checkbox",
				"particleEffects",
				"Toggles the particle effects that appear when you or a wall explode"
			},
			{
				"Shake Screen",
				"checkbox",
				"shakeScreen",
				"Toggles the screen shaking effect that occurs when you leave a wall"
			},
			{
				"Slow Motion",
				"checkbox",
				"slowmotion",
				"Toggles the slowmotion effect"
			},
			{
				"Motion Blur",
				"checkbox",
				"motionblur",
				"Toggles the motion blur effect, may not be available on all systems"
			}
		}
	},
	{"Cheats",
		{
		
		}
	}
}

local subItems 

local tabPanels = {}

function updatePanel(panel, i)
	if i == 3 then
		local y = 0
		for i,v in ipairs(tabItems[i][2]) do
			local item = loveframes.Create(v[2])
			panel:AddItem(item)
			if v[2] == "checkbox" then
				item:SetText(v[1])
				item:SetWidth(10)
				item.OnChanged = function(object)
					options.graphics[v[3]] = object:GetChecked()
				end
			end
			
			if v[4] then
				local tooltip = loveframes.Create("tooltip")
				tooltip:SetObject(item)
				tooltip:SetText(tostring(v[4]))
			end
			y = 20
		end
	end
	return panel
end

for i,v in ipairs(tabItems) do
	local panel = loveframes.Create"list"
	panel:SetAutoScroll(true)
	panel:SetDisplayType("vertical")
	panel:SetPadding(5)
	
	local text1 = loveframes.Create("text")
	panel:AddItem(text1)
	text1:SetText(v[1])
	text1:SetPos(0, 0)
	updatePanel(panel, i)
	
	tabs:AddTab(v[1], panel)
end

function showOptions()
	frame:SetVisible(true)
	GAMESTATE = "OPTIONS"
end

function closeOptions()
	frame:SetVisible(false)
end