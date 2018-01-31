--[[
 * Copyright (C) 2015 Ricky K. Thomson
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * u should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 --]]
 
world = {}
world.splash = {}
world.weather = {}
--world.camera?

test = love.graphics.newImage("data/images/test.png")
test2 = love.graphics.newImage("data/images/test2.png")
test:setWrap("repeat", "clamp")
test2:setWrap("repeat", "clampzero")
test_quad = love.graphics.newQuad( 0,0, love.graphics.getWidth(),test:getHeight(), test:getDimensions() )
test_quad2 = love.graphics.newQuad( 0,0, love.graphics.getWidth(),test2:getHeight(), test2:getDimensions() )
test_quad3 = love.graphics.newQuad( 0,0, love.graphics.getWidth(),test:getHeight(), test:getDimensions() )

function world:drawweather()
	if world.theme == "frost" then
		for i,particle in ipairs(world.weather) do
			love.graphics.setColor(particle.r,particle.g,particle.b,particle.o)
			love.graphics.circle("fill", particle.x,particle.y,particle.radius,particle.segments)
			
		end
	end
end
--loading/act display
function world:initsplash()
	world.splash = {}
	world.splash.bg = love.graphics.newImage("data/images/textures/1.png")
	world.splash.bg:setWrap("repeat", "repeat")
	world.splash.active = true
	world.splash.opacity = 255
	world.splash.timer = 3
	world.splash.fadespeed = 400
	world.splash.box_h = 100
	world.splash.box_y = -world.splash.box_h/2
	world.splash.text_y = -world.splash.box_h/2
	transitions:fadein()
end

function world:settheme(theme)
	--theme palettes for different level style

	--intialize default fallbacks
	love.filesystem.load( "themes/default.lua" )( )
	
	world.theme = theme or "default"

	-- load the theme file
	if love.filesystem.load( "themes/".. theme ..".lua" )( ) then 
		console:print("failed to set theme:  " .. theme)
	else
		
		love.graphics.setBackgroundColor(background_r,background_g,background_b,255)
		
		--only set background if it exists
		if type(background) == "userdata" then
			background:setWrap("repeat", "repeat")
			background_quad = love.graphics.newQuad( 0,0, love.graphics.getWidth(),love.graphics.getHeight(), background:getDimensions() )
		end
	
		console:print("set theme: " .. theme)
		
	end
	
end



function world:init(gamemode) 
	
	
	mode = gamemode
	--console = false
	editing = false
	paused = false
	
	--world loading/splash/act display
	if mode == "game" then
		world:initsplash()
	else
		world.splash.active = false
	end
	
	--move this setting into map files
	--once editor menu can adjust variables
	world.gravity = 420

	-- 
	-- y co-ordinate of deadzone
	-- anything falling past this point will land here
	-- (used to stop entities being lost, eg; falling forever)
	-- if it collides with gameworld, increase this value so it's below the map
	-- possibly draw this as unlimited width across the world using setViewPort and camera trickery?
	world.bedrock = 2000 
	
	world:reset()

	mapio:loadmap(world.map)
	
	world:resetcamera()

	--enable cheats, if any
	if cheats.catlife then player.lives = player.lives +  9 end
	if cheats.millionare then player.score = player.score +  "1000000" end
	
	player:respawn()

	console:print("initialized world")
end




function world:drawparallax()
	if editing then return end
	love.graphics.setColor(255,255,255,255)
	
	--paralax background sky
	if type(background) == "userdata" then
		love.graphics.draw(
			background, background_quad,0,0
		)
	end
	
	

	--back layer
	love.graphics.setColor(
		platform_top_r,
		platform_top_g,
		platform_top_b,
		255
	)
		
	test_quad:setViewport(
		(camera.x*2)/10*camera.scale,((camera.y*2)/40),love.graphics.getWidth(),love.graphics.getHeight()
	)
	love.graphics.draw(
		test,
		test_quad,				
		0,0
	)
	
	--middle layer
	love.graphics.setColor(
		platform_behind_r,
		platform_behind_g,
		platform_behind_b,
		255
	)

	test_quad2:setViewport(
		(camera.x*3)/10*camera.scale,((camera.y*3)/35),love.graphics.getWidth(),love.graphics.getHeight()
	)
	love.graphics.draw(
		test2,
		test_quad2,				
		0,0
	)
	
	--front layer
	love.graphics.setColor(
		platform_top_r-40,
		platform_top_g-40,
		platform_top_b-40,
		255
	)
		
	test_quad3:setViewport(
		(camera.x*4)/10*camera.scale,((camera.y*4)/30),love.graphics.getWidth(),love.graphics.getHeight()
	)
	love.graphics.draw(
		test,
		test_quad3,				
		0,0
	)
	--]]
end

function world:draw()
	

	self:drawparallax()
	
	-- set camera for world
	camera:attach()


	
	--[[ draw bedrock here
		unimplemented
	--]]
	


	love.graphics.setColor(255,255,255,255)
	

	
	decals:draw()
	props:draw()
	platforms:draw()
	springs:draw()
	bumpers:draw()
	checkpoints:draw()
	crates:draw()
	portals:draw()
	pickups:draw()
	enemies:draw()
	materials:draw()
	traps:draw()
		
	player:draw()	

	
	world:drawweather()
	
	popups:draw()

	camera:detach()
	

	
	if mode == "editing" then
		editor:draw()
	end
	
	--draw the hud/scoreboard
	if mode =="game" then
		
		world:drawscoreboard()
		
		if world.splash.opacity > 0 then 
			world:drawsplash()
		end
	end
	
	if paused then
		love.graphics.setColor(0,0,0,155)
		love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
		love.graphics.setColor(255,255,255,155)
		love.graphics.setFont(fonts.huge)
		love.graphics.printf("PAUSED", 0,love.graphics.getHeight()/3,love.graphics.getWidth(),"center",0,1,1)
		love.graphics.setFont(fonts.default)
		love.graphics.line(love.graphics.getWidth()/2.5,love.graphics.getHeight()/3,love.graphics.getWidth()-love.graphics.getWidth()/2.5,love.graphics.getHeight()/3)
		love.graphics.line(love.graphics.getWidth()/2.5,love.graphics.getHeight()/3+30,love.graphics.getWidth()-love.graphics.getWidth()/2.5,love.graphics.getHeight()/3+30)
	end
end


	

function world:drawsplash()
if debug then return end
	-- textured background
		love.graphics.setColor(50,50,50,world.splash.opacity)		
		self.splash.quad = love.graphics.newQuad( 0,0, love.graphics.getWidth(),love.graphics.getHeight(), self.splash.bg:getDimensions() )
		love.graphics.draw(self.splash.bg, self.splash.quad, 0, 0)
	
		
		--box
		love.graphics.setColor(platform_r/2,platform_g/2,platform_b/2,world.splash.opacity)
		love.graphics.rectangle("fill", 0,world.splash.box_y+love.graphics.getHeight()/2,love.graphics.getWidth(), world.splash.box_h )
		love.graphics.setFont(fonts.huge)
		
		--text
		love.graphics.setColor(255,255,255,world.splash.opacity)
		love.graphics.print(world.maptitle, love.graphics.getWidth()/2, world.splash.text_y+love.graphics.getHeight()/2+world.splash.box_h/2)
		love.graphics.setFont(fonts.default)
			

end

function world:drawscoreboard()
	if debug then return end
	love.graphics.setFont(fonts.scoreboard)
	
	love.graphics.setColor(0,0,0,155)

	love.graphics.printf("SCORE", 21,21,300,"left",0,1,1)
	love.graphics.printf("TIME", 21,41,300,"left",0,1,1)
	love.graphics.printf("GEMS", 21,61,300,"left",0,1,1)
	love.graphics.printf(player.score, 21,21,150,"right",0,1,1)
	love.graphics.printf(world:formattime(world.time), 21,41,150,"right",0,1,1)
	love.graphics.printf(player.gems, 21,61,150,"right",0,1,1)	
	
	love.graphics.printf("x"..player.lives, 21,love.graphics.getHeight()-40+1,50,"right",0,1,1)
	
	
	love.graphics.setColor(255,255,255,200)
	love.graphics.printf("SCORE", 20,20,300,"left",0,1,1)
	love.graphics.printf("TIME", 20,40,300,"left",0,1,1)
	love.graphics.printf("GEMS", 20,60,300,"left",0,1,1)
	love.graphics.printf(player.score, 20,20,150,"right",0,1,1)
	love.graphics.printf(world:formattime(world.time), 20,40,150,"right",0,1,1)
	love.graphics.printf(player.gems, 20,60,150,"right",0,1,1)
	
	love.graphics.printf("x"..player.lives, 20,love.graphics.getHeight()-40,50,"right",0,1,1)
	love.graphics.setFont(fonts.default)
	
	love.graphics.draw(pickups.textures["life"],20,love.graphics.getHeight()-40,0,0.5,0.5)
end

function world:timer(dt)
	--update the world time
	world.time = world.time + 1 *dt	
end


function world:formattime(n)
	return  
		string.format("%02d",n / 60 % 60) .. ":" .. 
		string.format("%02d",n % 60)
end




function world:count(table)
	--count tables within a table
	local count = 0
	for n, object in pairs(table) do 
		if type(object) == "table" then
			count = count + 1 
		end
	end
	return count
end

function world:remove(objects)
	-- pass table here
	-- removes all entity types from world
	local n = 0
	for n, object in ripairs(objects) do 
		if type(object) == "table" then
			table.remove(objects, n)
		end
	end
end

function world:reset()
	world.time = 0
	world.collision = 0
	 world:remove(enemies) 
	 world:remove(pickups) 
	 world:remove(crates) 
	 world:remove(props) 
	 world:remove(platforms)
	 world:remove(checkpoints)
	 world:remove(portals) 
	 world:remove(springs) 
	 world:remove(decals) 
	 world:remove(bumpers) 
	 world:remove(materials) 
	 world:remove(traps) 
	 world:remove(popups) 
end

function world:totalents()
	--returns total entitys
	return world:count(pickups)+world:count(enemies)+world:count(platforms)+
			world:count(crates)+world:count(checkpoints)+world:count(portals)+world:count(props)+world:count(springs)+world:count(decals)+world:count(traps)
end

function world:totalentsdrawn()
	--returns total drawn entities
	return world.pickups+world.enemies+world.platforms+world.crates+
		world.checkpoints+world.portals+world.props+world.springs+world.decals+world.traps
end


function world:inview(entity) 
	local x,y = camera:toWorldCoords(entity.x,entity.y)
	
	if entity.swing == 1 then
		if (camera.x + love.graphics.getWidth()/2 > entity.xorigin-entity.radius) 
		and (camera.x - love.graphics.getWidth()/2 < entity.xorigin+entity.w+entity.radius)
		and (camera.y + love.graphics.getHeight()/2 > entity.yorigin-entity.radius)
		and (camera.y - love.graphics.getHeight()/2 < entity.yorigin+entity.h+entity.radius)
			then
			world.collision = world.collision +1
			return true
		end
	else
	
		--decides if the entity is visible to the camera
				
		if (camera.x + (love.graphics.getWidth()/2/camera.scale) > entity.x ) 
		and (camera.x - (love.graphics.getWidth()/2/camera.scale) < entity.x+entity.w)
		and (camera.y + (love.graphics.getHeight()/2/camera.scale) > entity.y)
		and (camera.y - (love.graphics.getHeight()/2/camera.scale) < entity.y+entity.h)
			then
			world.collision = world.collision +1
			return true
		end
	end
end

function world:weatherUpdate(dt)
	if world.theme == "frost" then

		while #world.weather < 400 do
	
			local x,y
			local rand = math.random(1,4)
			--top
			if rand == 1 then 
				x = math.random(camera.x-love.graphics.getWidth()/2/camera.scale,camera.x+love.graphics.getWidth()/2/camera.scale)
				y = camera.y-love.graphics.getHeight()/2*camera.scale
			--right
			elseif rand == 2 then
				x = camera.x+love.graphics.getWidth()/2*camera.scale
				y = math.random(camera.y-love.graphics.getHeight()/2/camera.scale,camera.y+love.graphics.getHeight()/2/camera.scale)
			--bottom
			elseif rand == 3 then
				x = math.random(camera.x-love.graphics.getWidth()/2/camera.scale,camera.x+love.graphics.getWidth()/2/camera.scale)
				y = camera.y+love.graphics.getHeight()/2*camera.scale
			--left
			elseif rand == 4 then
				x = camera.x-love.graphics.getWidth()/2*camera.scale
				y = math.random(camera.y-love.graphics.getHeight()/2/camera.scale,camera.y+love.graphics.getHeight()/2/camera.scale)
			end
	
			local colour = math.random(200,255)
	
			table.insert(world.weather,{
				x = x,
				y = y,
				radius = math.random(2,3),
				segments = 10,
				r = colour,
				g = colour,
				b = colour,
				o = math.random(100,255),
				yvel = math.random(10,120),
				xvel = math.random(-50,50)
			})
		end
	

		for i,snow in ipairs(world.weather) do
	


			snow.y = snow.y + snow.yvel * dt
			snow.x = snow.x + snow.xvel * dt
		
			snow.y = snow.y + player.yvel/10 * dt
			snow.x = snow.x - player.xvel/10 * dt
		
			if snow.y > camera.y+love.graphics.getHeight()/2*camera.scale or snow.y < camera.y-love.graphics.getHeight()/2*camera.scale or snow.x > camera.x+love.graphics.getWidth()/2*camera.scale or snow.x < camera.x-love.graphics.getWidth()/2*camera.scale then
				snow.o = snow.o - 100 *dt
			end
		
		--[[
		for _,p in ipairs(platforms) do
			if collision:check(p.x,p.y,p.w,p.h,snow.x,snow.y,1,1) then
				if p.clip == 0 then
					snow.o = snow.o - 250 *dt
				end
			end
		end
		--]]
			if snow.o < 0 then table.remove(world.weather,i) end
		end
	else
		world.weather = {}	
	end
end

function world:update(dt)
	
	if not paused then 
		camera:update(dt)
		world:weatherUpdate(dt)
		collision:checkWorld(dt)
		physics:world(dt)
		popups:update(dt)
		player:update(dt)
		decals:update(dt)
		portals:update(dt)
		bumpers:update(dt)
		world.collision = 0

		if type(background) == "userdata" then
			background_scroll = background_scroll + background_scrollspeed * dt
			if background_scroll > background:getWidth()then
				background_scroll = background_scroll - background:getWidth()
			end
			background_quad:setViewport(camera.x/50-background_scroll,-camera.y/100,love.graphics.getWidth(),love.graphics.getHeight() )
		else
			background_scroll = 0
		end


		if mode == "game"  then
			--trigger world splash/act display
			if world.splash.opacity > 0 then 
				world.splash.timer = math.max(0, world.splash.timer - dt)
		
				if world.splash.timer <= 0 then
					world.splash.timer = 0
					world.splash.active = false
					world.splash.opacity = world.splash.opacity -world.splash.fadespeed *dt
					world.splash.text_y = world.splash.text_y + world.splash.fadespeed *dt
					world.splash.box_y = world.splash.box_y + world.splash.fadespeed *dt
				end
				return 
			end
		
		end
		world:timer(dt)
	
	end
end

function world:resetcamera()
	camera = Camera(camera.x,camera.y,love.graphics.getWidth(),love.graphics.getHeight(),love.graphics.getWidth() / default_width)
	camera:setFollowStyle('LOCKON')
	camera:setFollowLerp(0.2)
end


function world:sendtoback(t,i)
	local item = t[i]
	table.remove(t,i)
	table.insert(t,1,item)

	console:print( t[i].name .. " (" .. i .. ") sent to back" )
end

function world:sendtofront(t,i)
	local item = t[i]
	table.remove(t,i)
	table.insert(t,#t,item)

	console:print( t[i].name .. " (" .. i .. ") sent to front" )
end
