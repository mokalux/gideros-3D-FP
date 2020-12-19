Mesh3Db=Core.class(Mesh,function() return true end)

Mesh3Db.MODE_TEXTURE=1
Mesh3Db.MODE_LIGHTING=2 --ie normals
Mesh3Db.MODE_BUMP=4
Mesh3Db.MODE_SHADOW=8
Mesh3Db.MODE_ANIMATED=16
Mesh3Db.MODE_INSTANCED=32

function Mesh3Db:init()
	self.mode=0
end

function Mesh3Db:updateMode(set,clear)
	local nm=(self.mode|(set or 0))&~(clear or 0)
	if nm~=self.mode then
		self.mode=nm
		if (nm&Mesh3Db.MODE_LIGHTING)>0 then
			local tc=""
			if (nm&Mesh3Db.MODE_TEXTURE)>0 then tc=tc.."t" end
			if (nm&Mesh3Db.MODE_SHADOW)>0 then tc=tc.."s" end
			if (nm&Mesh3Db.MODE_BUMP)>0 then tc=tc.."n" end
			if (nm&Mesh3Db.MODE_ANIMATED)>0 then tc=tc.."a" end
			if (nm&Mesh3Db.MODE_INSTANCED)>0 then tc=tc.."i" end
			Lighting.setSpriteMode(self,tc)
		end
	end
end

function Mesh3Db:setInstanceCount(n)
	self._im1,self._im2,self._im3,self._im4 = self._im1 or {}, self._im2 or {}, self._im3 or {}, self._im4 or {}
	self._icount=n
	if n==0 then self:updateMode(0,Mesh3Db.MODE_INSTANCED)
	else self:updateMode(Mesh3Db.MODE_INSTANCED,0)
	end
	Mesh.setInstanceCount(self,n)
end

function Mesh3Db:setInstanceMatrix(i,m)
	local mm={m:getMatrix()}
	local is=i*4-3
	self._im1[is],self._im1[is+1],self._im1[is+2],self._im1[is+3]=mm[1],mm[2],mm[3],mm[4]
	self._im2[is],self._im2[is+1],self._im2[is+2],self._im2[is+3]=mm[5],mm[6],mm[7],mm[8]
	self._im3[is],self._im3[is+1],self._im3[is+2],self._im3[is+3]=mm[9],mm[10],mm[11],mm[12]
	self._im4[is],self._im4[is+1],self._im4[is+2],self._im4[is+3]=mm[13],mm[14],mm[15],mm[16]
end

function Mesh3Db:updateInstances()
	local icc=self._icount*4
	for i=1,icc do
		self._im1[i]=self._im1[i] or 0
		self._im2[i]=self._im2[i] or 0
		self._im3[i]=self._im3[i] or 0
		self._im4[i]=self._im4[i] or 0
	end
	self:setGenericArray(6,Shader.DFLOAT,4,self._icount,self._im1)
	self:setGenericArray(7,Shader.DFLOAT,4,self._icount,self._im2)
	self:setGenericArray(8,Shader.DFLOAT,4,self._icount,self._im3)
	self:setGenericArray(9,Shader.DFLOAT,4,self._icount,self._im4)
end

function Mesh3Db:setLocalMatrix(m)
	self:setShaderConstant("InstanceMatrix",Shader.CMATRIX,1,m:getMatrix())
end
