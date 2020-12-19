LevelX = Core.class(Sprite)

function LevelX:init()
	-- bg
	application:setBackgroundColor(0x0e49b5)
	-- r3d world
	self.world = r3d.World.new(0, -9.8, 0) -- gravity
	-- some lists to store coming objects (static bodies, ...)
	self.world.staticbodies = {}
	self.world.kinematicbodies = {}
	self.world.dynamicbodies = {}
	self.world.otherbodies = {}
	--Set up a fullscreen 3D viewport
	self.camera = D3.View.new(myappwidth, myappheight, 50, 4, 1.5*1024) -- 45 4 2*1024
	self:addChild(self.camera)
	-- the scene
	self.scene = self.camera:getScene()
	-- build the levels out of Tiled
	self.tiled_level = Tiled_Levels.new(self.world, self.camera, "tiled/level01.lua")
	-- add objects, player1, ... to the scene
	self.scene:addChild(self.tiled_level.player1)
	for k, v in pairs(self.world.staticbodies) do self.scene:addChild(k) end
	for k, v in pairs(self.world.kinematicbodies) do self.scene:addChild(k) end
	for k, v in pairs(self.world.dynamicbodies) do self.scene:addChild(k) end
	for k, v in pairs(self.world.otherbodies) do self.scene:addChild(k) end
	-- debug draw
--	local debugDraw = r3d.DebugDraw.new(self.world)
--	self.scene:addChild(debugDraw)
	-- lighting
	local matrix = self.tiled_level.player1.body:getTransform()
	local px, py, pz = matrix:transformPoint(0, 0, 0) -- hgy29
	Lighting.setLight(px-2, py+8, pz+8, 0.3) -- hgy29
	Lighting.setLightTarget(px, py, pz, 20, 45) -- hgy29
	-- player listeners
	self:addEventListener(Event.KEY_DOWN, self.tiled_level.player1.onKeyDown, self.tiled_level.player1)
	self:addEventListener(Event.KEY_UP, self.tiled_level.player1.onKeyUp, self.tiled_level.player1)
	-- scene listeners
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- GAME LOOP
function LevelX:onEnterFrame(e)
	-- r3d physics simulation
	self.world:step(e.deltaTime)
	--Animation engine tick
	D3Anim.tick()
	-- same with other dynamic objs
	local matrix2
	for k, v in pairs(self.world.dynamicbodies) do
		matrix2 = v:getTransform()
		k:setMatrix(matrix2)
	end
	-- for the camera follow
	local matrix = self.tiled_level.player1.body:getTransform()
	local ax, ay, az = matrix:transformPoint(0, 0, 0)
	local bx, by, bz = matrix:transformPoint(0, 0, 1) -- 1 because by default the player is facing the camera
	local dx, dy, dz = bx - ax, by - ay, bz - az
	-- the camera FPS style
	local camx, camy, camz = matrix:getPosition()
	camx += -dx * 8 -- 8 16
	camy += 3 -- 4
	camz += -dz * 8 -- 8 16
	self.camera:lookAt(
		camx + 0, camy + 0, camz - 0,
		self.tiled_level.player1:getX() + 0, self.tiled_level.player1:getY() + 2, self.tiled_level.player1:getZ() + 0, -- + 2
		0, 1, 0
	)
--[[
	-- lighting
	local px, py, pz = matrix:transformPoint(0, 0, 0) -- hgy29
	Lighting.setLight(px-2, py+8, pz+8, 0.3) -- hgy29
	Lighting.setLightTarget(px, py, pz, 20, 45) -- hgy29
]]
	--Compute shadows
	Lighting.computeShadows(self.scene)
end

-- SCENE EVENT LISTENERS
function LevelX:onTransitionInBegin()
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

function LevelX:onTransitionInEnd()
	self:myKeysPressed()
end

function LevelX:onTransitionOutBegin()
	self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

function LevelX:onTransitionOutEnd()
end

-- KEYS HANDLER
function LevelX:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		-- for mobiles and desktops
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then
			scenemanager:changeScene("levelX", 2, transitions[2], easings[1])
		end
	end)
end
