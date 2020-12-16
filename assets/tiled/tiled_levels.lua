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
	local myshape -- shapes from Tiled
	local mytable -- intermediate table for shapes params
	for i = 1, #layers do
		local layer = layers[i]
		-- *******
		-- WORLD
		-- *******
		if layer.name == "world" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				myshape, mytable = nil, nil
				-- TILED SHAPES
				-- *************
				if object.name == "base" then
					mytable = { texpath="gfx/textures/grass.png", texw=4*1024, texh=4*1024 }
				else
				end
				if mytable then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					self:buildShapes(layer.name, object, levelsetup)
				end
			end
		elseif layer.name == "objects" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				myshape, mytable = nil, nil
				-- TILED SHAPES
				-- *************
				if object.name == "tree" then
					local tree = cube_factory(self.world, {
						posx=object.x, posz=object.y,
						sizex=object.width, sizez=object.height,
						texpath="gfx/textures/Aurichalcite Deposit.jpg",
					})
				elseif object.name == "player1" then
					self.player1 = Player1.new(self.world, xcamera, {
						posx=object.x, posy=2, posz=object.y,
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

function Tiled_Levels:buildShapes(xlayer, xobject, xlevelsetup)
	local myshape = nil
	local tablebase = {}
	if xobject.shape == "ellipse" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			w=xobject.width, h=xobject.height, rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Ellipse.new(self.world, tablebase)
	elseif xobject.shape == "polygon" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			coords=xobject.polygon, rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Polygon.new(self.world, tablebase)
	elseif xobject.shape == "rectangle" then
		tablebase = {
			posx=xobject.x, posy=0, posz=xobject.y,
			sizex=xobject.width, sizey=0.01, sizez=xobject.height,
			roty=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = PLANE_3D.new(self.world, tablebase)
	else
		print("*** CANNOT PROCESS THIS SHAPE! ***", xobject.shape, xobject.name)
		return
	end
	myshape = nil
end
