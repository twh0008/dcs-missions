do
US_HQ = GROUP:FindByName( "US-HQ")

US_CC = COMMANDCENTER:New( US_HQ, "TOC" )

ScoringGround = SCORING:New( "A2G Dispatching" )

NATO_M1 = MISSION
  :New( US_CC, "A2G", "High", "There's a strong enemy presence at Krasnodar and the surrounding area. Details are provided in the tasking.", coalition.side.BLUE )
  :AddScoring( ScoringGround )
  
SPAWN_NATO_AWACS = SPAWN:New("NATO AWACS"):InitLimit(1,999):InitCleanUp(20)
SPAWN_NATO_AWACS:InitRepeatOnLanding()

SPAWN_NATO_TANKER = SPAWN:New("NATO TANKER"):InitLimit(1,999):InitCleanUp(20)
SPAWN_NATO_TANKER:InitRepeatOnLanding()

SPAWN_OPFOR_AWACS = SPAWN:New("RED AWACS"):InitLimit(1,999):InitCleanUp(20)
SPAWN_OPFOR_AWACS:InitRepeatOnLanding()

SPAWN_NATO_TANKER:SpawnScheduled(60,0)
SPAWN_NATO_AWACS:SpawnScheduled(60,0)  
SPAWN_OPFOR_AWACS:SpawnScheduled(60,0)

-- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
-- Here we build the network with all the groups that have a name starting with DF CCCP AWACS and DF CCCP EWR.
DetectionSetGroup = SET_GROUP:New()
DetectionSetGroup:FilterPrefixes( { "RED AWACS", "RED EWR", "EWR RED" } )
DetectionSetGroup:FilterStart()

-- Setup the detection and group targets to a 30km range!
Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )

-- Setup the A2A dispatcher, and initialize it.
A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )
-- A2ADispatcher:SetTacticalDisplay( true )

-- Set 50km as the radius to engage any target by airborne friendlies.
A2ADispatcher:SetEngageRadius( 100000 )
A2ADispatcher:SetGciRadius( 100000 )



-- Setup the border.
-- Initialize the dispatcher, setting up a border zone. This is a polygon, 
-- which takes the waypoints of a late activated group with the name CCCP Border as the boundaries of the border area.
-- Any enemy crossing this border will be engaged.

BorderZone = ZONE_POLYGON:New( "Border", GROUP:FindByName( "Border" ) )
A2ADispatcher:SetBorderZone( BorderZone )

 -- Setup the squadrons.
A2ADispatcher:SetSquadron( "Maykop", AIRBASE.Caucasus.Maykop_Khanskaya, { "SQ SU-27" })
A2ADispatcher:SetSquadron( "Sochi", AIRBASE.Caucasus.Sochi_Adler, { "SQ SU-27" })
A2ADispatcher:SetSquadron( "Gudauta", AIRBASE.Caucasus.Gudauta, { "SQ SU-27" })
A2ADispatcher:SetSquadron( "Gelendzhik", AIRBASE.Caucasus.Gelendzhik, { "SQ SU-27" })

A2ADispatcher:SetSquadronOverhead( "Maykop", 1)
A2ADispatcher:SetSquadronOverhead( "Sochi", 1 )
A2ADispatcher:SetSquadronOverhead( "Gudauta", 1 )
A2ADispatcher:SetSquadronOverhead( "Gelendzhik", 1 )

A2ADispatcher:SetSquadronGrouping( "Maykop", 2 )
A2ADispatcher:SetSquadronGrouping( "Sochi", 1 )
A2ADispatcher:SetSquadronGrouping( "Gudauta", 1)
A2ADispatcher:SetSquadronGrouping( "Gelendzhik", 2)


A2ADispatcher:SetSquadronTakeoffInAir("Maykop", 5000)
A2ADispatcher:SetSquadronTakeoffInAir("Sochi", 5000)
A2ADispatcher:SetSquadronTakeoffInAir("Gudauta", 5000)
A2ADispatcher:SetSquadronTakeoffInAir("Gelendzhik", 5000)

A2ADispatcher:SetSquadronLandingNearAirbase( "Maykop" )
A2ADispatcher:SetSquadronLandingNearAirbase( "Sochi")
A2ADispatcher:SetSquadronLandingNearAirbase( "Gudauta")
A2ADispatcher:SetSquadronLandingNearAirbase( "Gelendzhik")


A2ADispatcher:SetSquadronGci( "Maykop", 900, 1200 )
A2ADispatcher:SetSquadronGci( "Sochi", 900, 2100 )
A2ADispatcher:SetSquadronGci( "Gudauta", 900, 1200 )
A2ADispatcher:SetSquadronGci( "Gelendzhik", 900, 1200 )

FACSet = SET_GROUP:New():FilterPrefixes("FAC"):FilterCoalitions("blue"):FilterStart()

FACAreas = DETECTION_AREAS:New( FACSet, 3000 )

NATO_GROUND_ATTACK = SET_GROUP:New():FilterCoalitions( "blue" ):FilterStart()

TaskDispatcherGround = TASK_A2G_DISPATCHER:New( NATO_M1, NATO_GROUND_ATTACK, FACAreas )
TaskDispatcherGround:SetRefreshTimeInterval( 30 )

ZoneTable = { ZONE:New( "A2G ZONE" ) }

TemplateTable = { 
    "Spawn Ground Template #001",
    "Spawn Ground Template #002",
    "Spawn Ground Template #003",
    "Spawn Ground Template #004",
    "Spawn Ground Template #005" }

SpawnGroups = SPAWN:New( "Spawn" )
SpawnGroups:InitLimit( 10, 2 )
SpawnGroups:InitRandomizeTemplate( TemplateTable )
SpawnGroups:InitRandomizeZones( ZoneTable )




function SpawnNewObject()
  SpawnGroups:Spawn()
end


CG = GROUP:FindByName( "CG" )
CG:PatrolZones( { ZONE:New( "CGZONE" ) }, 120, "Diamond" )

function TaskDispatcherGround:OnAfterAssign( From, Event, To, Task, TaskUnit, PlayerName )
  Task:SetScoreOnProgress( "Player " .. PlayerName .. " destroyed a target", 20, TaskUnit )
  Task:SetScoreOnSuccess( "The task has been successfully completed!", 200, TaskUnit )
  Task:SetScoreOnFail( "The task has failed completion!", -100, TaskUnit )
end

--do
--
--SpawnRU = SPAWN:New( 'RU Heli'):InitLimit( 2, 120 ):SpawnScheduled( 10, 0 )
--
--SpawnUS = SPAWN:New( 'US Heli'):InitLimit( 2, 120 ):SpawnScheduled( 10, 0 )
--
--end

 MenuSpawn = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn Random Group for FAC Dispatch", nil, SpawnNewObject )

 end








