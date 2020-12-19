-- Sphere Builder
local Sphere3Db=Core.class(Mesh3Db)

function Sphere3Db:init(radius, steps)
	local va,ia={},{}
--	local rs=(2*3.141592654)/steps
	local rs=(2*math.pi)/steps
	local i,ni=4,1
	--Vertices
	va[1]=0 va[2]=1 va[3]=0
	for iy=1,(steps//2)-1 do
		local y=math.cos(iy*rs) * radius
		local r=math.sin(iy*rs) * radius
		for ix=0,steps do
			local x=r*math.cos(ix*rs)
			local z=r*math.sin(ix*rs)
			va[i]=x i+=1
			va[i]=y i+=1
			va[i]=z i+=1
		end
	end
	va[i]=0	va[i+1]=-1 va[i+2]=0
	local lvi=i//3+1
	--Indices
	--a) top and bottom fans
	for i=1,steps do
		ia[ni]=1 ni+=1 ia[ni]=i+1 ni+=1 ia[ni]=i+2 ni+=1
		ia[ni]=lvi ni+=1 ia[ni]=lvi-i ni+=1 ia[ni]=lvi-i-1 ni+=1
	end
	--b) quads
	for iy=1,(steps//2)-2 do
		local b=1+(steps+1)*(iy-1)
		for ix=1,steps do
			ia[ni]=b+ix ni+=1 ia[ni]=b+ix+1 ni+=1 ia[ni]=b+ix+steps+1 ni+=1
			ia[ni]=b+ix+steps+1 ni+=1 ia[ni]=b+ix+1 ni+=1 ia[ni]=b+ix+steps+2 ni+=1
		end
	end
	self:setGenericArray(3,Shader.DFLOAT,3,lvi,va)
	self:setVertexArray(va)
	self:setIndexArray(ia)
	self._steps=steps
	self._va=va self._ia=ia
end

function Sphere3Db:mapTexture(texture)
	self:setTexture(texture)
	if texture then
		local tw,th=texture:getWidth(),texture:getHeight()
		local va={}
		local i=3
		--TexCoords
		va[1]=tw/2 va[2]=0
		for iy=1,(self._steps//2)-1 do
			local y=th*(1-iy*2/self._steps)
			for ix=0,self._steps do
				local x=tw*(ix/self._steps)
				va[i]=x i+=1
				va[i]=y i+=1
			end
		end
		va[i]=tw/2	va[i+1]=th
		self:setTextureCoordinateArray(va)
		self:updateMode(Mesh3Db.MODE_TEXTURE,0)
	else
		self:updateMode(0,Mesh3Db.MODE_TEXTURE)
	end
end

-- ******************************
Sphere3D = Core.class(Sprite)

function Sphere3D:init(xworld, xparams)
	-- params
	local params = xparams or {}
	params.steps = xparams.steps or 4
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.sizex = xparams.sizex or 0
	params.sizey = xparams.sizey or params.sizex
	params.sizez = xparams.sizez or 0
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0
	params.texpath = xparams.texpath or nil
	params.r3dtype = xparams.r3dtype or nil
	params.mass = xparams.mass or 1
	params.BIT = xparams.BIT or nil
	params.colBIT = xparams.colBIT or nil
	-- the mesh
	local mesh = Sphere3Db.new(params.sizex, params.steps) -- radius, steps
	mesh:mapTexture(Texture.new(params.texpath, true))
	mesh:updateMode(Mesh3Db.MODE_LIGHTING + Mesh3Db.MODE_SHADOW + Mesh3Db.MODE_TEXTURE)
	-- we put the mesh in a viewport so we can matrix it
	local view = Viewport.new()
	view:setContent(mesh)
	-- the body
	view.body = xworld:createBody(view:getMatrix())
	if params.r3dtype then view.body:setType(params.r3dtype) end
	-- the shape
	local shape = r3d.SphereShape.new(params.sizex) -- radius
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, 0, 0) -- center
	-- the fixture
	local fixture = view.body:createFixture(shape, m1, params.mass)
	-- materials
	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 0
	mat.frictionCoefficient = 1
	mat.rollingResistance = 0.5 -- 0 = no resistance, 1 = max resistance
	fixture:setMaterial(mat)
	-- collision filtering
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
	-- add it to world bodies list
	if params.r3dtype == r3d.Body.STATIC_BODY then xworld.staticbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.KINEMATIC_BODY then xworld.kinematicbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.DYNAMIC_BODY then xworld.dynamicbodies[view] = view.body
	else xworld.otherbodies[view] = view.body
	end
end
