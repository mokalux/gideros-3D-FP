Player1 = Core.class(Sprite)

function Player1:init(xworld, xview)
	self.world = xworld
	self.view = xview
	local xfilemesh = "Models/New folder (5)/bot_y_mesh.json"
	local xfileidle = "Models/New folder (5)/bot_y_idle.json"
	local xfilewalk = "Models/New folder (5)/bot_y_walk.json"
	-- load our model in gdx/g3dj format
	self.animatedmodel = buildGdx(xfilemesh, {
--		["skin"] = { textureFile="Skins/fantasyFemaleB.png", },
	})
	-- scale it down (it is too big)
	local playerscale = 0.02
	self.scalex, self.scaley, self.scalez = playerscale, playerscale, playerscale -- can be local!
	self.animatedmodel:setScale(self.scalex, self.scaley, self.scalez)
	-- load two animations from g3dj files
	self.animIdle = buildGdx(xfileidle, {})
	self.animWalk = buildGdx(xfilewalk, {})
	-- sets default animation to idle
	-- note that in our files, first animation in array is the T-pose, the second is the real anim, ...
	D3Anim.setAnimation(self.animatedmodel, self.animIdle.animations[1], "main", true, 0.5)
	self:addChild(self.animatedmodel)
	-- *** REACT PHYSICS 3D ***
	-- we build a viewport out of our model so we can transform its position, rotation, scale, ...
	local v = Viewport.new()
	v:setContent(self.animatedmodel)
	v:setPosition(0, 2, 0)
	v:setRotation(0)
	v:setRotationX(0)
	v:setRotationY(0)
	-- the body
	self.body = self.world:createBody(v:getMatrix())
	self.shape = r3d.BoxShape.new(
		self.animatedmodel:getWidth() / 4,
		self.animatedmodel:getHeight() / 2,
--		self.animatedmodel:getLength() / 2)
--		self.animatedmodel:getDepth() / 2)
		0.8) -- I CAN'T GET THE DEPTH!
	-- position the shape
	local m1 = Matrix.new()
	m1:setPosition(0, self.animatedmodel:getHeight() / 2, 0.4)
	self.body:createFixture(self.shape, m1, 8) -- shape, position, mass
	self.body:setLinearDamping(0.999) -- play with it!
	self.body:setAngularDamping(0.999) -- play with it!
	-- event listener
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- GAME LOOP
function Player1:onEnterFrame(e)
	local force = 1 * self.body:getMass()
	local matrix = self.body:getTransform()
	local ax, ay, az = matrix:transformPoint(0, 0, 0)
	local bx, by, bz = matrix:transformPoint(0, 0, 1) -- 1 because by default the player is facing the camera
	local dx, dy, dz = bx - ax, by - ay, bz - az
	if self.isup and not self.isdown then self.body:applyForce(^>dx*force, 0, ^>dz*force)
	elseif self.isdown and not self.isup then self.body:applyForce(-^>dx*force, 0, -^>dz*force)
	end
	if self.isleft and not self.isright then self.body:applyTorque(0, -force*8, 0)
	elseif self.isright and not self.isleft then self.body:applyTorque(0, force*8, 0)
	end
	-- position the player model along its r3d body
	self:setMatrix(matrix)
	-- the camera FPS style
	local camx, camy, camz = matrix:getPosition()
	camx += -dx * 8 -- 16
	camy += 4 -- 4
	camz += -dz * 8 -- 16
	self.view:lookAt(
		camx, camy + 0, camz - 0,
		self:getX() + 0, self:getY() + 2, self:getZ() + 0,
		0, 1, 0
	)
	-- lighting
--	Lighting.setLightTarget(self.body:getTransform():getPosition(), 30, 45) -- 30, 45 I DON'T REALLY GET IT!
	Lighting.setLightTarget(-2, 0, 16, 30, 45) -- 30, 45 I DON'T REALLY GET IT!
end

-- EVENT LISTENERS
function Player1:onKeyDown(e)
	-- controls
	if e.keyCode == KeyCode.UP then self.isup = true end
	if e.keyCode == KeyCode.DOWN then self.isdown = true end
	if e.keyCode == KeyCode.LEFT then self.isleft = true end
	if e.keyCode == KeyCode.RIGHT then self.isright = true end
	-- animations
	if self.isup or self.isdown then
		D3Anim.setAnimation(self.animatedmodel, self.animWalk.animations[1], "main", true, 0.5)
	end
end

function Player1:onKeyUp(e)
	-- controls
	if e.keyCode == KeyCode.UP then self.isup = false end
	if e.keyCode == KeyCode.DOWN then self.isdown = false end
	if e.keyCode == KeyCode.LEFT then self.isleft = false end
	if e.keyCode == KeyCode.RIGHT then self.isright = false end
	-- animations
	if not self.isup and not self.isdown and not self.isleft and not self.isright then
		D3Anim.setAnimation(self.animatedmodel, self.animIdle.animations[1], "main", true, 0.5)
	end
end
