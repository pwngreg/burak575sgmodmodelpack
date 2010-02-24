AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

ENT.WireDebugName = "Piston"

include('shared.lua')

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:DrawShadow( false )
	
	local max = self.Entity:OBBMaxs()
	local min = self.Entity:OBBMins()
	
	self.ThrustOffset 	= Vector( 0, 0, max.z )
	self.ThrustOffsetR 	= Vector( 0, 0, min.z )
	self.ForceAngle		= self.ThrustOffset:GetNormalized() * -1
	
	self:SetForce( 2000 )
	
	self:SetOffset( self.ThrustOffset )
	self.Entity:StartMotionController()
	
	self.Inputs = Wire_CreateInputs( self.Entity, { "Force" } )
	self.PlaySound = true
	
	self.Trigger = 0
end

function ENT:TriggerInput(iname, value)
	if iname == "Force" then
		if (math.abs(value) > 0.01) then
			self:Switch(true, value)
		else
			self:Switch(false, 0)
		end	
	end
end

--[[function ENT:Think()
	local phys = self.Entity:GetPhysicsObject()
	if self.F > 0.1 or self.F < -0.1   then
	
		if !self.Reversed then
			--print("Reversed thrust")
			phys:ApplyForceCenter( (self.Entity:GetUp() ) * self.Force * self.F )
		else
			--print("normal thrust")
			phys:ApplyForceCenter( (self.Entity:GetUp() ) * self.Force * self.F * -1 )
		end
		
		self:SetOn(true)
		if self.PlaySound then
			self.Entity:StopSound( self.Sound )
			self.Entity:EmitSound( self.Sound )
			self.PlaySound = false
		end
	else
		self.Entity:StopSound( self.Sound )
		self:SetOn(false)
		self.PlaySound = true
	end
	self.Entity:NextThink(CurTime() + 0.1)
	return true
end --]]

function ENT:SetForce( force, mul )
	if (force) then
		self.force = force
		self:NetSetForce( force )
	end
	mul = mul or 1
	
	local phys = self.Entity:GetPhysicsObject() -- hmm	
	if (!phys:IsValid()) then
		Msg("Warning: [gmod_piston] Physics object isn't valid!\n")
		return
	end

	// Get the data in worldspace
	local ThrusterWorldPos = phys:LocalToWorld( self.ThrustOffset )
	local ThrusterWorldForce = phys:LocalToWorldVector( self.ThrustOffset * -1 )

	// Calculate the velocity
	if !self.Reversed then
		--print("Reversed thrust")
		mul = mul * -1
	end
	ThrusterWorldForce = ThrusterWorldForce * self.force * mul * 50
	self.ForceLinear, self.ForceAngle = phys:CalculateVelocityOffset( ThrusterWorldForce, ThrusterWorldPos );
	self.ForceLinear = phys:WorldToLocalVector( self.ForceLinear )
	
	
	if self.Reversed then
		self:SetOffset( self.ThrustOffset )
	else
		self:SetOffset( self.ThrustOffsetR )
	end
end

function ENT:PhysicsSimulate( phys, deltatime )
	if (!self:IsOn()) then return SIM_NOTHING end
	
	--[[if (self.Entity:WaterLevel() > 0) then
		if (not self.UWater) then
			self:SetEffect("none")
			return SIM_NOTHING
		end
		
		if (self.UWEffect == "same") then
			self:SetEffect(self.OWEffect)
		else
			self:SetEffect(self.UWEffect)
		end
	else
		if (not self.OWater) then
			self:SetEffect("none")
			return SIM_NOTHING
		end
		
		self:SetEffect(self.OWEffect)
	end --]]
	
	local ForceAngle, ForceLinear = self.ForceAngle, self.ForceLinear
	
	return ForceAngle, ForceLinear, SIM_LOCAL_ACCELERATION
end

function ENT:Switch( on, mul )
	if (!self.Entity:IsValid()) then return false end
	
	local changed = (self:IsOn() ~= on)
	self:SetOn( on )
	
	
	if (on) then
		if (changed) then
			self.Entity:StopSound( self.Sound )
			self.Entity:EmitSound( self.Sound )
		end
		
		self:SetForce( nil, mul )
	else
		self.Entity:StopSound( self.Sound )
	end
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	return true
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	
	if ( self.Sound != "" ) then
		self.Entity:StopSound(self.Sound)
	end
end


--[[function ENT:ShowOutput()
	self:SetOverlayText(
		"Piston\nForce= "..tostring(math.Round(self.F * self.Force))
	)
end--]]

function ENT:Setup(force, length, snd,fx)
	self:SetForce(force)
	self:SetLength ( math.max(length, 1) )
	self.F = 0
	self.Sound = snd
	self.FX = fx
	self:TriggerInput("Force", 0)
end

-- Force
--[[function ENT:SetForce( f )
	self.Force = f
end
function ENT:GetForce()
	return self.Force
end--]]

-- Cylinder Length // if this has changed we gona change its length
function ENT:SetLength( f )
	if self.Length ~= f then
		self.Length = f
		if ( self.const ) then
			print("Cylinder length changing...")
			-- These codes are fix for that rope doesn't have "change length" after created
			local ct = table.Copy( self.const:GetTable() )
			ct["Length"] = self.Length
			--print("Removing piston constraint...")
			local rslt = constraint.RemoveConstraints( self.Entity, "WirePistonConst" )
			if ( rslt ) then
				--print("Constraint successfuly removed, creating new one...")
				MakeWirePistonConstFromTable( ct )
				self.Entity:GetPhysicsObject():EnableCollisions( false )
			else
				print("Piston constraint remove failed...")
			end
		end
	end
end

function ENT:GetLength()
	return self.Length
end

-- Sound Effect
function ENT:GetSound()
	return self.Sound
end

function ENT:SetSound( str )
	self.Sound = str
end

-- Combustion Effect
function ENT:GetFX()
	return self.FX
end

function ENT:SetFX( fs )
	self.FX = fs
end

-- Reversed Point
function ENT:GetReversed()
	return self.Reversed
end

function ENT:SetReversed( fs )
	self.Reversed = fs
end

