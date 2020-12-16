PLANE_3D = Core.class(Sprite)

function PLANE_3D:init(xworld, xparams)
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
	-- plane mesh
	local mesh = D3.Mesh.new()
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
	mesh:updateMode(D3.Mesh.MODE_LIGHTING + D3.Mesh.MODE_SHADOW + D3.Mesh.MODE_TEXTURE)
	-- *** REACT PHYSICS 3D ***
	-- we put the mesh in a viewport so we can matrix it
	local planeview = Viewport.new()
	planeview:setContent(mesh)
	-- the body
	planeview.body = xworld:createBody(planeview:getMatrix())
	planeview.body:setType(r3d.Body.STATIC_BODY)
	local shape = r3d.BoxShape.new(params.sizex, params.sizey, params.sizez)
	local fixture = planeview.body:createFixture(shape, nil, 0) -- shape, transform, weight
--	fixture:setCollisionCategoryBits(NONDESTRUCTIBLES)
--	fixture:setCollideWithMaskBits(PLAYER1+DESTRUCTIBLES)
	-- transform
	local matrix = planeview.body:getTransform()
	matrix:setPosition(2*params.posx + params.sizex, params.posy, -2*params.posz - params.sizez)
	matrix:setRotationX(params.rotx)
	matrix:setRotationY(params.roty)
	matrix:setRotationZ(params.rotz)
	planeview.body:setTransform(matrix)
	planeview:setMatrix(matrix)
	-- add it to world static body list
	xworld.staticbodies[#xworld.staticbodies + 1] = planeview
end
