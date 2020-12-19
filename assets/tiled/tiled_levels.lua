Tiled_Levels = Core.class(Sprite)

function Tiled_Levels:init(xworld, xcamera, xtiledlevelpath)
	self.world = xworld
	-- load the tiled level
	local tiledlevel = loadfile(xtiledlevelpath)()
	-- the tiled map size
	local tilewidth, tileheight = tiledlevel.tilewidth, tiledlevel.tileheight
	local mapwidth, mapheight = tiledlevel.width * tilewidth, tiledlevel.height * tileheight
	print("tile size "..tilewidth..", "..tileheight, "all in pixels.")
	print("map size "..mapwidth..", "..mapheight, "app size "..myappwidth..", "..myappheight, "all in pixels.")
	-- parse the tiled level
	local layers = tiledlevel.layers
	for i = 1, #layers do
		local layer = layers[i]
		-- GROUNDS
		-- *******
		if layer.name == "grounds" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil, nil -- mytable = intermediate table for shapes params
				-- *************
				if object.name == "groundA" then
					mytable = { texpath="textures/Grassy Way.jpg", sizey=0.1, texw=4*1024, texh=4*1024, r3dtype=r3d.Body.STATIC_BODY, }
				elseif object.name == "groundB" then
					mytable = { texpath="textures/Grassy Way.jpg", sizey=0.1, texw=4*1024, texh=4*1024, r3dtype=r3d.Body.STATIC_BODY, }
				elseif object.name == "groundC" then
					mytable = { texpath="textures/Grassy Way.jpg", sizey=0.1, texw=4*1024, texh=4*1024, r3dtype=r3d.Body.STATIC_BODY, }
				elseif object.name == "groundD" then
					mytable = { texpath="textures/Grassy Way.jpg", sizey=0.1, texw=4*1024, texh=4*1024, r3dtype=r3d.Body.STATIC_BODY, }
				else
					mytable = { texpath="textures/Grassy Way.jpg", texw=4*1024, texh=4*1024, r3dtype=r3d.Body.STATIC_BODY, }
				end
				if mytable then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					self:buildShapes(layer.name, object, levelsetup, "ground")
				end
			end
		-- PLAYABLES
		-- *********
		elseif layer.name == "playables" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil, nil -- mytable = intermediate table for shapes params
				-- *************
				if object.name == "player1" then
					self.player1 = Player1.new(self.world, xcamera, {
						posx=object.x, posz=object.y, mass=8,
					})
				end
			end
		-- WALLS
		-- *********
		elseif layer.name == "walls" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil, nil -- mytable = intermediate table for shapes params
				-- *************
				if object.name == "wallA" then
					local sx, sy
					if object.width > object.height then sx, sy = 48, 6 -- 96. 16
					else sx, sy = 6, 48
					end
					Box3D.new(self.world, {
						posx=object.x, posz=object.y,
						sizex=object.width, sizey=4, sizez=object.height,
						texpath="textures/Alternating Mudbrick.jpg", texscalex=sx, texscaley=sy,
						r3dtype=r3d.Body.STATIC_BODY,
					})
				elseif object.name == "wallB" then
					local sx, sy
					if object.width > object.height then sx, sy = 8, 1 -- 96. 16
					else sx, sy = 1, 8
					end
					Box3D.new(self.world, {
						posx=object.x, posz=object.y,
						sizex=object.width, sizey=5, sizez=object.height,
						texpath="textures/Weathered Stone Wall1024.jpg", texscalex=sx, texscaley=sy,
						r3dtype=r3d.Body.STATIC_BODY,
					})
				end
			end
		-- SHAPES
		-- *********
		elseif layer.name == "shapes" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil, nil -- mytable = intermediate table for shapes params
				-- *************
				if object.shape == "ellipse" then
					if object.name == "d" then -- DYNAMIC_BODY
						mytable = {
							steps=24,
							texpath="textures/Aurichalcite Deposit.jpg", texw=1*1024, texh=1*1024,
							mass=0.1, r3dtype=r3d.Body.DYNAMIC_BODY,
						}
					else -- STATIC_BODY
						if object.name == "x" then -- world atmosphere
							mytable = {
								steps=64, posy=-object.width/2.5,
								texpath="textures/Cloudy Sky2048.jpg", texw=64*1024, texh=64*1024,
							}
						else
							mytable = {
								steps=32,
								texpath="textures/Purple Crystal512.jpg", texw=2*1024, texh=2*1024,
								r3dtype=r3d.Body.STATIC_BODY,
							}
						end
					end
				-- *************
				elseif object.shape == "polygon" then
--					mytable = { texpath="textures/Grassy Way.jpg", texw=4*1024, texh=4*1024, r3dtype=r3d.Body.STATIC_BODY, }
				-- *************
				elseif object.shape == "rectangle" then
					mytable = { texpath="textures/Grassy Way.jpg", sizey=8, texw=4*1024, texh=4*1024, r3dtype=r3d.Body.STATIC_BODY, }
				end
				if mytable then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					self:buildShapes(layer.name, object, levelsetup)
				end
			end
		-- OBJS
		-- *********
		elseif layer.name == "objs" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil, nil -- mytable = intermediate table for shapes params
				-- *************
				if object.name == "a8" then
					--function Obj:init(xworld, xfolderpath, xobjname, xparams)
					Obj.new(self.world, "models/obj/brazuca", "ball1.obj", {
						posx=object.x, posz=object.y, mass=8,
						r3dtype=r3d.Body.DYNAMIC_BODY,
						r3dshape="sphere",
					})
				end
			end
		-- FBXS
		-- *********
		elseif layer.name == "fbxs" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil, nil -- mytable = intermediate table for shapes params
				-- *************
				if object.name == "fbx01" then
					Fbx.new(self.world, {
						meshpath="models/fbx_json/monster01/DefeatedM.json",
						texpath="models/fbx_json/monster01/bear_diffuse.png", slot=1,
						posx=object.x, posz=object.y, roty=object.rotation,
						r3dtype=r3d.Body.DYNAMIC_BODY,
						mass=8,
					})
				elseif object.name == "fbx02" then
					Fbx.new(self.world, {
						meshpath="models/fbx_json/female/characterLargeFemale.json", meshscale=0.5,
						texpath="models/fbx_json/female/fantasyFemaleB.png", slot=3,
						posx=object.x, posz=object.y, roty=object.rotation,
						r3dtype=r3d.Body.DYNAMIC_BODY,
						mass=8,
					})
				end
			end
		-- WHAT?!
		-- *************
		else
			print("WHAT?!", layer.name)
		end
	end
end

function Tiled_Levels:buildShapes(xlayer, xobject, xlevelsetup, xextras)
	local myshape = nil
	local tablebase = {}
	-- ********************************
	if xobject.shape == "ellipse" then
		tablebase = {
			posx=xobject.x, posz=xobject.y,
			sizex=xobject.width, sizez=xobject.height, rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Sphere3D.new(self.world, tablebase)
	-- ********************************
	elseif xobject.shape == "polygon" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			coords=xobject.polygon, rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
--		myshape = Tiled_Shape_Polygon.new(self.world, tablebase)
	-- ********************************
	elseif xobject.shape == "rectangle" then
		tablebase = {
			posx=xobject.x, posz=xobject.y,
			sizex=xobject.width, sizez=xobject.height,
			roty=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		if xextras == "ground" then
			myshape = Plane3D.new(self.world, tablebase)
		else
			myshape = Box3D.new(self.world, tablebase)
		end
	else
		print("*** CANNOT PROCESS THIS SHAPE! ***", xobject.shape, xobject.name)
	end
	myshape = nil
end
