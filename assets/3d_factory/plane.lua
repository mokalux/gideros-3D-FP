PLANE_3D = Core.class(Sprite)

function PLANE_3D:init(xworld, params)
	-- params
	local params = params or {}
	params.posx = params.posx or 0
	params.posy = params.posy or 0
	params.posz = params.posz or 0
	params.sizex = params.sizex or 1
	params.sizey = params.sizey or 1
	params.sizez = params.sizez or params.sizex
	params.rotx = params.rotx or 0
	params.roty = params.roty or 0
	params.rotz = params.rotz or 0
	params.texpath = params.texpath or nil
	params.texw = params.texw or 8 * 64
	params.texh = params.texh or 8 * 64
	-- plane mesh
	print(params.texpath)
	local mesh = D3.Mesh.new()
	mesh:setVertexArray {
		-params.sizex,params.sizey,-params.sizez,
		params.sizex,params.sizey,-params.sizez,
		params.sizex,params.sizey,params.sizez,
		-params.sizex,params.sizey,params.sizez
	}
	-- texture coordinates -- make it big (3200, 3200)
	mesh:setTextureCoordinateArray {
		0, 0,
		params.texw, 0,
		params.texw, params.texh,
		0, params.texh
	}
	-- normal array
	mesh:setGenericArray( 3, Shader.DFLOAT, 3, 4, { 0,1,0, 0,1,0, 0,1,0, 0,1,0 } )
	mesh:setIndexArray { 1,2,3,	1,3,4 }
	if params.texpath then
		mesh:setTexture( Texture.new( params.texpath, true, { wrap = TextureBase.REPEAT } ) )
	else
		mesh:setTexture( Texture.new( nil, params.sizex, params.sizez ) )
	end
	-- lighting, shadows, and texture. setTexture doesn't automatically do it
	mesh:updateMode( D3.Mesh.MODE_LIGHTING | D3.Mesh.MODE_SHADOW | D3.Mesh.MODE_TEXTURE )
	-- put it in a viewport so we can matrix it
	self.planeview = Viewport.new()
	self.planeview:setContent(mesh)
	-- transform
	local matrix = self.planeview:getMatrix()
	matrix:setPosition(params.posx, params.posy, params.posz)
	matrix:setRotationX(params.rotx)
	matrix:setRotationY(params.roty)
	matrix:setRotationZ(params.rotz)
	self.planeview:setMatrix(matrix)
	-- the body
	self.planeview.body = xworld:createBody(self.planeview:getMatrix())
	self.planeview.body:setType(r3d.Body.STATIC_BODY)
	self.planeview.shape = r3d.BoxShape.new(params.sizex, params.sizey, params.sizez)
	local fixture = self.planeview.body:createFixture(self.planeview.shape, nil, 0) -- shape, transform, weight
--	fixture:setCollisionCategoryBits(NONDESTRUCTIBLES)
--	fixture:setCollideWithMaskBits(PLAYER1+DESTRUCTIBLES)
	xworld.staticbodies[#xworld.staticbodies + 1] = self.planeview
end

function PLANE_3D:getMesh()
	return self.planeview
end

function PLANE_3D:getMeshBody()
	return self.planeview.body
end
