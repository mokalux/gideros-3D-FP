Plane3D = Core.class(Sprite)

function Plane3D:init(xworld, xparams)
	-- params
	local params = xparams or {}
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.sizex = xparams.sizex or 1
	params.sizey = xparams.sizey or 1
	params.sizez = xparams.sizez or params.sizex
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0
	params.texpath = xparams.texpath or nil
	params.texw = xparams.texw or 8 * 64
	params.texh = xparams.texh or 8 * 64
	params.r3dtype = xparams.r3dtype or nil
	params.mass = xparams.mass or 1
	params.BIT = xparams.BIT or nil
	params.colBIT = xparams.colBIT or nil
	-- the mesh
	local mesh = Mesh3Db.new()
	mesh:setVertexArray {
		-params.sizex, params.sizey, -params.sizez,
		params.sizex, params.sizey, -params.sizez,
		params.sizex, params.sizey, params.sizez,
		-params.sizex, params.sizey, params.sizez
	}
	-- texture coordinates
	mesh:setTextureCoordinateArray {
		0, 0,
		params.texw, 0,
		params.texw, params.texh,
		0, params.texh
	}
	-- normal array
	mesh:setGenericArray(3, Shader.DFLOAT, 3, 4, { 0,1,0, 0,1,0, 0,1,0, 0,1,0 } )
	mesh:setIndexArray { 1,2,3,	1,3,4 }
	if params.texpath then
		mesh:setTexture(Texture.new(params.texpath, true, { wrap = TextureBase.REPEAT } ))
	else
		mesh:setTexture(Texture.new(nil, params.sizex, params.sizez))
	end
	-- lighting, shadows, and texture. setTexture doesn't automatically do it
	mesh:updateMode(Mesh3Db.MODE_LIGHTING + Mesh3Db.MODE_SHADOW + Mesh3Db.MODE_TEXTURE)
	-- *** REACT PHYSICS 3D ***
	-- we put the mesh in a viewport so we can matrix it
	local view = Viewport.new()
	view:setContent(mesh)
	-- the body
	view.body = xworld:createBody(view:getMatrix())
	if params.r3dtype then view.body:setType(params.r3dtype) end
	-- the shape
	local shape = r3d.BoxShape.new(params.sizex, params.sizey, params.sizez)
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, 0, 0)
	-- the fixture
	local fixture = view.body:createFixture(shape, m1, xparams.mass) -- shape, transform, mass
	-- materials
--	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
--	mat.bounciness = 0.2
--	mat.frictionCoefficient = 0.02
--	mat.rollingResistance = 0.01 -- 0 = no resistance, 1 = max resistance
--	fixture:setMaterial(mat)
	-- collision bit
	if params.BIT then fixture:setCollisionCategoryBits(params.BIT) end
	if params.colBIT then fixture:setCollideWithMaskBits(params.colBIT) end
	-- transform (for Tiled)
	local matrix = view.body:getTransform()
	matrix:setPosition(2*params.posx + params.sizex, 2*params.posy + params.sizey, -2*params.posz - params.sizez)
	matrix:setRotationX(params.rotx)
	matrix:setRotationY(params.roty)
	matrix:setRotationZ(params.rotz)
	view.body:setTransform(matrix)
	view:setMatrix(matrix)
	-- add it to world body list
	if params.r3dtype == r3d.Body.STATIC_BODY then xworld.staticbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.KINEMATIC_BODY then xworld.kinematicbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.DYNAMIC_BODY then xworld.dynamicbodies[view] = view.body
	else xworld.otherbodies[view] = view.body
	end
end
