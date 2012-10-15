function generateWhitespace(n)
	local w = ' '
	for i=2, n do
		w = w .. " "
	end
	return w
end

options = {
	graphics = {},
	audio = {},
	cheats = {},
	controls = {}
}
options.audio.music = true
options.audio.sfx = true
options.controls.inverted = false
options.graphics.particleEffects = true
options.graphics.shakeScreen = true
options.graphics.slowmotion = true
options.graphics.motionblur = true
options.graphics.vignette = true -- seriously cuts the framerate
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