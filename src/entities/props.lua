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
 
props = {}

--maybe create "textures" class to load all of these? 
-- textures.props, textures.platforms etc. ???
-- as props.textures will be erased when props is reset
props_textures = {
	["flower"] = love.graphics.newImage("data/images/props/flower.png"),
	["flower2"] = love.graphics.newImage("data/images/props/flower2.png"),
	["grass"] = love.graphics.newImage("data/images/props/grass.png"),
	["rock"] = love.graphics.newImage("data/images/props/rock.png"),
	["tree"] = love.graphics.newImage("data/images/props/tree.png"),
	["post"] = love.graphics.newImage("data/images/props/post.png"),
	["arch"] = love.graphics.newImage("data/images/props/arch.png"),
	["arch1_r"] = love.graphics.newImage("data/images/props/arch1_r.png"),
	["arch2"] = love.graphics.newImage("data/images/props/arch2.png"),
	["arch3"] = love.graphics.newImage("data/images/props/arch3.png"),
	["arch3_end_l"] = love.graphics.newImage("data/images/props/arch3_end_l.png"),
	["arch3_end_r"] = love.graphics.newImage("data/images/props/arch3_end_r.png"),
	["arch3_pillar"] = love.graphics.newImage("data/images/props/arch3_pillar.png"),
	["porthole"] = love.graphics.newImage("data/images/props/porthole.png"),
	["pillar"] = love.graphics.newImage("data/images/props/pillar.png"),
	["mesh"] = love.graphics.newImage("data/images/props/mesh.png"),
	["girder"] = love.graphics.newImage("data/images/props/girder.png")
}



function props:add(x,y,dir,type)

	local gfx = props_textures[type]
	
	if dir == 0 or dir == 1 then
		width = gfx:getWidth()
		height = gfx:getHeight()
		end
	if dir == 2 or dir == 3 then
		width = gfx:getHeight()
		height = gfx:getWidth()
	end
	
	table.insert(world.entities.prop, {
		x = x or 0, 
		y = y or 0,
		w = width,
		h = height,
		dir = dir,
		flip = false,
		
		group = "prop",
		type = type,
		gfx = gfx,

		editor_canrotate = true,
		editor_canflip = true
	})
	print(type .. " added @  X:"..x.." Y: "..y)

end

function props:draw()
	local count = 0
	
	for i, prop in ipairs(world.entities.prop) do
		if world:inview(prop) then
			count = count +1
				
			if prop.type == "arch" or prop.type == "arch2" or prop.type == "arch3" 
			or prop.type == "arch3_end_l" or prop.type == "arch3_end_r" or prop.type == "arch3_pillar"
			then
				love.graphics.setColor(
					platform_r,
					platform_g,
					platform_b,
					255
				)	
			elseif prop.type == "porthole" or prop.type == "arch1_r" then
				love.graphics.setColor(
					platform_behind_r,
					platform_behind_g,
					platform_behind_b,
					255
				)
			else
				love.graphics.setColor(255,255,255,255)
			end
			
			
			if prop.flip then
			
				if prop.dir == 1 then
					love.graphics.draw(prop.gfx, prop.x, prop.y, 0,(prop.flip and -1 or 1),-1,prop.w,prop.h )
				elseif prop.dir == 2 then
					love.graphics.draw(prop.gfx, prop.x, prop.y, math.rad(90),1,(prop.flip and -1 or 1),0,0 )
				elseif prop.dir == 3 then
					love.graphics.draw(prop.gfx, prop.x, prop.y, math.rad(-90),-1,(prop.flip and -1 or 1),0,prop.w )
				else
					love.graphics.draw(prop.gfx, prop.x, prop.y, 0,(prop.flip and -1 or 1),1,prop.w,0)
				end
			else
				if prop.dir == 1 then
					love.graphics.draw(prop.gfx, prop.x, prop.y, 0,1,-1,0,prop.h )
				elseif prop.dir == 2 then
					love.graphics.draw(prop.gfx, prop.x, prop.y, math.rad(90),1,1,0,prop.w )
				elseif prop.dir == 3 then
					love.graphics.draw(prop.gfx, prop.x, prop.y, math.rad(-90),-1,1 )
				else
					love.graphics.draw(prop.gfx, prop.x, prop.y, 0,1,1)
				end
			end
		

			if editing or debug then
				props:drawdebug(prop, i)
			end

		end
	end

	world.props = count
end



function props:drawdebug(prop, i)
	love.graphics.setColor(255,0,155,100)
	love.graphics.rectangle(
		"line", 
		prop.x, 
		prop.y, 
		prop.w, 
		prop.h
	)
	
	editor:drawid(prop, i)
	editor:drawcoordinates(prop)
end
