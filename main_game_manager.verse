
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation/Tags }


main_game_manager := class(creative_device):

    @editable
    MediumAccolade : accolades_device = accolades_device{}

    @editable
    LargeAccolade : accolades_device = accolades_device{}

    @editable
    VeryLargeAccolade : accolades_device = accolades_device{}

    # the key for this map is the player(unique id)
    # we store the custom player in the map
    # multiple managers/devices/classes can have a custom_player map
    var CustomPlayers : [player]PlayerManager = map{}

    DeathEvent<public>:event() = event(){}
    


    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        InitSpawners()


    # Looking for all the spawners in the game
    # Listing for spawned events
    # We can have multiple classes / devices listen for spawners (each can have their own functionality) 
    InitSpawners():void=
        #Spawners := GetCreativeObjectsWithTag(spawner{})
        for(FoundTaggedObject : FindCreativeObjectsWithTag(spawner{})):
            if (Spawner := player_spawner_device[FoundTaggedObject]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    # We convert it to a player
    # Then we initialie the player
    OnPlayerSpawned(Agent:agent):void=
        if (Player := player[Agent]):
            InitPlayer(Player)


    InitPlayer(Player:player):void=

        TeamCollection := GetPlayspace().GetTeamCollection()
        if(Agent := agent[Player]):
            if (AgentsTeam := TeamCollection.GetTeam[Agent]):
                TeamsArray := TeamCollection.GetTeams()
                for (TeamNumber ->Team : TeamsArray):
                    if(AgentsTeam = Team):
                        PlayerTeam := TeamNumber                  
                        if:
                            FortCharacter := Agent.GetFortCharacter[]
                        then:

                            # In the case the player is already in the map, meaning it died or something
                            if (Existing := CustomPlayers[Player]){}
                            
                            # If the player spawning is new
                            else:
                                # Subscribe this player into OnPlayerEliminated
                                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
                                
                                # Making an instance of the player
                                CustomPlayer := PlayerManager{Player:=Player, PlayerTeam:=PlayerTeam, MediumAccolade:=MediumAccolade, LargeAccolade:=LargeAccolade, VeryLargeAccolade:=VeryLargeAccolade }
                                # Initializing the player?
                                CustomPlayer.Init()
                                # setting the custom player into the map of players
                                if (set CustomPlayers[Player] = CustomPlayer){}

    OnPlayerEliminated<public>(Result : elimination_result):void=
        Print("Maybe")
        Print("Signal")
        DeathEvent.Signal()
        if:
            # eliminating characterS
            killer := Result.EliminatingCharacter?
            Agent := killer.GetAgent[]
            Player := player[Agent]
            # grabbig the CustomPlayer for this agent
            CustomPlayer := CustomPlayers[Player]
            Print("Himself")
        then:
            Print("Signal")
            DeathEvent.Signal()
            # making sure that the player didn't kill themselves
            if (not(Result.EliminatingCharacter = Result.EliminatingCharacter?)):
                CustomPlayer.AwardElimination()


    
    # clean up when player leaves the game    
    OnPlayerLeftServer(PlayerLeaving : player):void=
        if (CustomPlayer := CustomPlayers[PlayerLeaving]):
            # clean up data from leaving player (props and things like that)
            CustomPlayer.Dispose()

            # remove the player from the map to clear memory
            var NewCustomPlayerMap:[player]PlayerManager = map{}
            for (key -> Value : CustomPlayers, key <> PlayerLeaving):
                set NewCustomPlayerMap = ConcatenateMaps(NewCustomPlayerMap, map{key=>Value})
            # replaces the old map for the updated one
            set CustomPlayers = NewCustomPlayerMap
            

    getCustomPlayers<public>()<transacts>:[player]PlayerManager =
        return CustomPlayers
