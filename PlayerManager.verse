using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Playspaces }


PlayerManager := class<unique>():
    
    Player : player
    PlayerTeam : int

    MediumAccolade : accolades_device
    LargeAccolade : accolades_device
    VeryLargeAccolade : accolades_device
    
    ##################################################
    ##################################################
    
    var CurrentElims<private> : int = 0

    var HasCrystal<private> : logic = false

    var Credits<private> : int = 500

    var DeathSubscription<private> : logic = false

    ##################################################
    ##################################################

    AwardCredits(amount:int):void=
        Print("Awarded: {amount} credits")
        set Credits += amount

    GetCredits():void=
        Print("Credit Amount: {Credits}")

    AwardCrystal():void=
        set HasCrystal = true
        Print("Awarded crystal to player")
    
    RemoveCrystal():void=
        set HasCrystal = false
        Print("Removed crystal from player")

    GetCrystalStatus()<transacts>:logic=
        return HasCrystal

    GetTeam()<transacts>:int=
        return PlayerTeam

    AwardElimination():void=
        set CurrentElims += 1

    GetEliminationCount()<transacts>:int=
        return CurrentElims

    getSubscription():logic=
        return DeathSubscription

    setSubscription():void=
        set DeathSubscription = true
    ##################################################
    ##################################################

    AwardMedium():void=
        if(Agent := agent[Player]):
            MediumAccolade.Award(Agent)

    AwardLarge():void=
        if(Agent := agent[Player]):
            LargeAccolade.Award(Agent)

    AwardVeryLarge():void=
        if(Agent := agent[Player]):
            VeryLargeAccolade.Award(Agent)


    MediumEventTriggered(Agent:agent):void=
        Print("The player was awarded a MEDIUM amount of XP!")

    LargeEventTriggered(Agent:agent):void=
        Print("The player was awarded a LARGE amount of XP!")

    VeryLargeEventTriggered(Agent:agent):void=
        Print("The player was awarded a VERY LARGE amount of XP!")
    
    ##################################################
    ##################################################

    # initializing the player
    Init():void= 
        if:
            # convert the player to an agent
            Agent := agent[Player]
            # convert the agent to a fornite character
            # check if the fortcharacter is active
            PlayerActive := Agent.GetFortCharacter[].IsActive[]
        then:

            MediumAccolade.TestAwardEvent.Subscribe(MediumEventTriggered)
            LargeAccolade.TestAwardEvent.Subscribe(LargeEventTriggered)
            VeryLargeAccolade.TestAwardEvent.Subscribe(VeryLargeEventTriggered)
            Print("Player Initialized")


    Dispose():void=
        # dispose if the player has custom stuff
        block:

