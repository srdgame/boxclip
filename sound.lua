sound = {}

local soundpath = "sounds/"

-- place sound filepaths here
sound.jump = love.audio.newSource(soundpath .. "jump.wav")
sound.gem = love.audio.newSource(soundpath .. "gem.wav")
sound.hit = love.audio.newSource(soundpath .. "hit.wav")
sound.beep = love.audio.newSource(soundpath .. "beep.wav")
sound.die = love.audio.newSource(soundpath .. "die.wav")
sound.crate = love.audio.newSource(soundpath .. "crate.wav")
sound.lifeup = love.audio.newSource(soundpath .. "lifeup.wav")


function sound:play(sound)
	--improve this (temporary fix)
	if sound:isPlaying() then
		sound:stop()
	end
	love.audio.play( sound )
end
