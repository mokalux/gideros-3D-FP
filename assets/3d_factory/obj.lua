Obj = Core.class(Sprite)

function Obj:init(xworld, xfolderpath, xobjname, xparams)
	-- params
	local params = xparams or {}
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0
	params.r3dtype = xparams.r3dtype or nil
	params.r3dshape = xparams.r3dshape or nil
	params.mass = xparams.mass or 1
	params.BIT = xparams.BIT or nil
	params.colBIT = xparams.colBIT or nil
	-- some vars
	local minx, miny, minz -- can be negative
	local maxx, maxy, maxz
	local width, height, length -- obj dimensions
	-- the .obj
	local obj = loadObj(xfolderpath, xobjname)
	minx, miny, minz = obj.min[1], obj.min[2], obj.min[3] -- can be negative numbers
	maxx, maxy, maxz = obj.max[1], obj.max[2], obj.max[3]
	width, height, length = maxx - minx, maxy - miny, maxz - minz
	print("obj", width, height, length)
	-- we put the mesh in a viewport so we can matrix it
	local view = Viewport.new()
	view:setContent(obj)
	-- the body
	view.body = xworld:createBody(view:getMatrix())
	if params.r3dtype then view.body:setType(params.r3dtype) end
	-- the shape
	local shape
	if params.r3dshape == "box" then
		shape = r3d.BoxShape.new(width / 2, height / 2, length / 2)
	elseif params.r3dshape == "sphere" then
		shape = r3d.SphereShape.new(height / 2)
	else
		print("YOU NEED TO PASS A SHAPE AS ARGUMENT TO THE TABLE (r3dshape = 'box', 'sphere')")
	end
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, 0, 0) -- shape position
	-- the fixture
	local fixture = view.body:createFixture(shape, m1, params.mass) -- shape, transform, mass
	-- materials
	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 1
	mat.frictionCoefficient = 1
	mat.rollingResistance = 0 -- 0 = no resistance, 1 = max resistance
	fixture:setMaterial(mat)
	-- collision bit
	if params.BIT then fixture1:setCollisionCategoryBits(params.BIT) end
	if params.colBIT then fixture1:setCollideWithMaskBits(params.colBIT) end
	-- transform (for Tiled)
	local matrix = view.body:getTransform()
	matrix:setPosition(2*params.posx + width/2, height, -2*params.posz - length/2)
	matrix:setRotationX(params.rotx)
	matrix:setRotationY(params.roty)
	matrix:setRotationZ(params.rotz)
	view.body:setTransform(matrix)
	view:setMatrix(matrix)
	-- add it to world bodies list
	if params.r3dtype == r3d.Body.STATIC_BODY then xworld.staticbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.KINEMATIC_BODY then xworld.kinematicbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.DYNAMIC_BODY then xworld.dynamicbodies[view] = view.body
	else xworld.otherbodies[view] = view.body
	end
end
