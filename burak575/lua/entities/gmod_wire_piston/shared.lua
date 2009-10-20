

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
