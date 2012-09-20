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

local tabs = loveframes.Create("tabs", frame)
tabs:SetPos(5, 30)
do
	local w, h = frame:GetSize()
	tabs:SetSize(w-5, h-5)
end

local tabItems = {
	{"General"},
	{"Audio"},
	{"Graphics",
		{
			
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
	end
	return panel
end
for i,v in ipairs(tabItems) do
	local panel = loveframes.Create"list"
	panel:SetAutoScroll(true)
	panel:SetDisplayType("vetical")
	
	local text1 = loveframes.Create("text")
	panel:AddItem(text1)
	text1:SetText(v[1])
	text1:SetPos(5, 5)
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