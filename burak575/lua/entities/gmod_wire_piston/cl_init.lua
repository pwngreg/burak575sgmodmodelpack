
include('shared.lua')

ENT.RenderGroup 		= RENDERGROUP_BOTH

local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )

function ENT:Draw()
	self.BaseClass.Draw(self)
	--Wire_DrawTracerBeam( self, 1, self:GetForceBeam() )
	if ( self.ShouldDraw == 0 ) then return end

	if ( !self:IsOn() ) then return end
	
	if ValidEntity(self.MotorBlock) then
		local vLength = self.vLength / 100
		
		local vOffset = self.Entity:LocalToWorld( self:GetOffset() )

		local vNormal = (vOffset - self.Entity:GetPos()):GetNormalized()
	
		local scroll = CurTime() * -10
	
		render.SetMaterial( matFire )
	
		render.StartBeam( 3 )
			render.AddBeam( vOffset, 4, scroll, Color( 0, 0, 255, 128) )
			render.AddBeam( vOffset + vNormal * (40 * vLength), 8, scroll + 1, Color( 255, 255, 255, 128) )
			render.AddBeam( vOffset + vNormal * (100 * vLength), 6, scroll + 3, Color( 255, 255, 255, 0) )
		render.EndBeam()
	
		scroll = scroll * 0.5
	
		render.UpdateRefractTexture()
		render.SetMaterial( matHeatWave )
		render.StartBeam( 3 )
			render.AddBeam( vOffset, 4, scroll, Color( 0, 0, 255, 128) )
			render.AddBeam( vOffset + vNormal * (21 * vLength), 6, scroll + 2, Color( 255, 255, 255, 255) )
			render.AddBeam( vOffset + vNormal * (86 * vLength), 8, scroll + 5, Color( 0, 0, 0, 0) )
		render.EndBeam()
	
	
		scroll = scroll * 1.3
		render.SetMaterial( matFire )
		render.StartBeam( 3 )
			render.AddBeam( vOffset, 4, scroll, Color( 0, 0, 255, 128) )
			render.AddBeam( vOffset + vNormal * (40 * vLength), 6, scroll + 1, Color( 255, 255, 255, 128) )
			render.AddBeam( vOffset + vNormal * (100 * vLength), 6, scroll + 3, Color( 255, 255, 255, 0) )
		render.EndBeam()
	end	
end


function ENT:Think()
	self.BaseClass.Think(self)
	
	self.ShouldDraw = GetConVarNumber( "cl_drawthrusterseffects" )
	
	if !self.ShouldDraw then return end
	
	
	if self.MotorBlock == nil or !ValidEntity(self.MotorBlock) then
		self.MotorBlock = self:GetMotorBlock()
		self.CylHead = self:GetCylinderHeadPos()
	end
	
	if ValidEntity(self.MotorBlock) then
		local wPos = self.MotorBlock:LocalToWorld( self.CylHead )
		self.vLength = self.Entity:GetPos():Distance( wPos )
	end
	
end
