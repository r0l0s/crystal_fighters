
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using {UtilityModule}


crystal_manager := class(creative_device):
    
    # Crystal visual representation
    @editable
    CrystalRep : creative_prop = creative_prop{}

    @editable
    Button:button_device = button_device{}

    @editable
    VolumeA : volume_device = volume_device{}

    @editable
    VolumeB : volume_device = volume_device{}

    @editable
    Crystal_Attach : visual_effect_powerup_device = visual_effect_powerup_device{} 

    @editable
    Crystal_Detach : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    MainManager : main_game_manager = main_game_manager{}


    
    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(OnButtonInteractedWith)
        VolumeA.AgentEntersEvent.Subscribe(OnPlayerEntered_VolumeA)
        VolumeB.AgentEntersEvent.Subscribe(OnPlayerEntered_VolumeB)
        Sleep(0.2)
        HandlePlayers()
    
    GetPlayers()<transacts>:[player]PlayerManager=
        return MainManager.getCustomPlayers()


    HandlePlayers():void=
        playerMap := MainManager.getCustomPlayers()
        for(key -> Value: playerMap):
            if:
                Agent := agent[key]
                FortCharacter := Agent.GetFortCharacter[]
            then:
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
                Value.setSubscription()
                Print("Player Subscribed (Death)")


    OnPlayerEliminated(Result : elimination_result):void=
        Print("Player Eliminated")

        if:
            # eliminating character
            DeadPlayer := Result.EliminatedCharacter
            Agent := DeadPlayer.GetAgent[]
            Player := player[Agent]
            PlayerMap := MainManager.getCustomPlayers()
            CustomPlayer := PlayerMap[Player]

        then:
            Print("Checking Crystal Status")
            if(CustomPlayer.GetCrystalStatus()?):

                
                
                # Removes the crystal from the player
                CustomPlayer.RemoveCrystal()
                Crystal_Detach.Pickup(Player)
                Print("Crsytal Removed")
                ShowCrystal()
                Button.Enable()



    HideCrystal():void=
        if (CrystalRep.IsValid[]):
            CrystalRep.Hide()


    ShowCrystal():void=
        if (CrystalRep.IsValid[]):
            CrystalRep.Show()

    OnButtonInteractedWith(Agent:agent):void=
        if:
            Player := player[Agent]
            PlayerMap := GetPlayers()
            CustomPlayer := PlayerMap[Player]
            
        then:
            CrystalStatus := CustomPlayer.GetCrystalStatus()
        
            if(CrystalStatus = false):
                CustomPlayer.AwardCrystal()
                Crystal_Attach.Pickup(Player)
                HideCrystal()
                Button.Disable()
                CustomPlayer.GetCredits()
            
            else:
                Print("Already has crystal")


    # When the player enters the volume
    OnPlayerEntered_VolumeA(Agent:agent):void=
        if:
            Player := player[Agent]
            PlayerMap := GetPlayers()
            CustomPlayer := PlayerMap[Player]
            
        then:
            if(CustomPlayer.GetTeam() = 0):
                if(CustomPlayer.GetCrystalStatus() = true):

                    CustomPlayer.AwardVeryLarge()
                    CustomPlayer.AwardCredits(350)
                    CustomPlayer.RemoveCrystal()
                    Crystal_Detach.Pickup(Player)
                    ShowCrystal()
                    Button.Enable()
                else:
                    Print("No Crystal")
            else:
                Print("Not your team")


    # When the player enters the volume
    OnPlayerEntered_VolumeB(Agent:agent):void=
        if:
            Player := player[Agent]
            PlayerMap := GetPlayers()
            CustomPlayer := PlayerMap[Player]
            
        then:
            if(CustomPlayer.GetTeam() = 1):
                if(CustomPlayer.GetCrystalStatus() = true):

                    CustomPlayer.AwardVeryLarge()
                    CustomPlayer.AwardCredits(750)
                    CustomPlayer.RemoveCrystal()
                    Crystal_Detach.Pickup(Player)
                    ShowCrystal()
                    Button.Enable()
                else:
                    Print("No Crystal")
            else:
                Print("Not your team")
            