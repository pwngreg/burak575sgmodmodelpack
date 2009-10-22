

ENT.Type 			= "anim"
ENT.Base 			= "base_wire_entity"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetOn( boolon )
	self.Entity:SetNetworkedBool( "On", boolon, true )
end
function ENT:IsOn( name )
	return self.Entity:GetNetworkedBool( "On" )
end

function ENT:SetMotorBlock( nt )
	self.Entity:SetNetworkedEntity("MotorBlock",nt)
end

function ENT:GetMotorBlock()
	return self.Entity:GetNetworkedEntity("MotorBlock")
end

function ENT:SetCylinderHeadPos( vc )
	self.Entity:SetNetworkedVector("CylinderHead",vc)
end

function ENT:GetCylinderHeadPos()
	return self.Entity:GetNetworkedVector("CylinderHead")
end

--[[function ENT:SetReverseFix( bl )
	self.Entity:SetNetworkedBool("Reversed",bl)
end

function ENT:GetReverseFix()
	return self.Entity:GetNetworkedBool("Reversed")
end --]]

function ENT:SetOffset( v )
	self.Entity:SetNetworkedVector( "Offset", v, true )
end
function ENT:GetOffset( name )
	return self.Entity:GetNetworkedVector( "Offset" )
end

function ENT:NetSetForce( force )
	self.Entity:SetNetworkedInt(4, math.floor(force*100))
end

function ENT:NetGetForce()
	return self.Entity:GetNetworkedInt(4)/100
end

function ENT:GetOverlayText()
	local txt = "Piston "
	txt = txt .. "\nMul: " .. self:NetGetForce()
	return txt
end

