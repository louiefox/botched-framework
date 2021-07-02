ENT.Base = "base_ai" 
ENT.Type = "ai"
 
ENT.PrintName		= "Botched NPC"
ENT.Category		= "Botched Framework"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= false

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "MenuType" )
    self:NetworkVar( "Int", 0, "NPCKey" )
end