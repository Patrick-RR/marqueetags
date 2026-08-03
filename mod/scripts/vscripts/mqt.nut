untyped
global function mqt_Init
global function mqt_signalNewSettings
global function mqt_signalUpdatePresets
global function mqt_signalNewCommunity

#if HAS_TOOLS
LogoData LD = {
    logo = [
        "                         .-._                                                      ",
        "                          \\  '-._                                                 ",
        "                     ______/___  '.                                                ",
        "                    `'--.___  _\\  /                                               ",
        "                       /___.-'  \\ \\ _:._                                         ",
        "                       .'__ _.'\\ '-/,`-~`                                         ",
        "                           \\  ___.> /=,                                           ",
        "                           / _.-'/_ )                                              ",
        "                           /`   ( /(/                                              ",
        "                                 \\\\ `                                            ",
        "                                  '=='                                             ",
        "___  ___  ___  ______ _____ _   _ _____ _____ _____ ___  _____  _____              ",
        "|  \\/  | / _ \\ | ___ \\  _  | | | |  ___|  ___|_   _/ _ \\|  __ \\/  ___|        ",
        "| .  . |/ /_\\ \\| |_/ / | | | | | | |__ | |__   | |/ /_\\ \\ |  \\/\\ `--.        ",
        "| |\\/| ||  _  ||    /| | | | | | |  __||  __|  | ||  _  | | __  `--. \\           ",
        "| |  | || | | || |\\ \\\\ \\/' / |_| | |___| |___  | || | | | |_\\ \\/\\__/ /      ",
        "\\_|  |_/\\_| |_/\\_| \\_|\\_/\\_\\\\___/\\____/\\____/  \\_/\\_| |_/\\____/\\____/"
    ]
    color_start = < 212, 220, 255 > // #D4DCFF Periwinkle
    color_end   = < 125, 131, 255 > // #7D83FF Soft Periwinkle
}
#endif

const string MQT_PRESET_FILEPATH = "mqtv4_presets.json"

// Scrolls in Weapon mode whenever you're sat in the lobby (no weapon to check).
// Change this to whatever you want - it isn't limited to 4 characters, the
// taglength setting controls how much of it shows at once.
const string MQT_LOBBY_TAG = "super chiter"

table allPresets = {}
table<string, void functionref( string preset = "" )> modeTable = {}

void function debugPrint( string message ){
    printt( "[MQTV4] " + message )
}

void function mqt_signalNewSettings(){
    Signal( clGlobal.signalDummy, "mqt_signal_newSettings" )
}

void function mqt_signalUpdatePresets(){
    Signal( clGlobal.signalDummy, "mqt_signal_updatePresets" )
}

void function mqt_signalNewCommunity(){
    Signal( clGlobal.signalDummy, "mqt_signal_newCommunity" )
}

void function mqt_signalNewWeapon( entity weapon ){
    Signal( clGlobal.signalDummy, "mqt_signal_newWeapon" )
}

void function modeTable_Init(){
    modeTable[ "static" ] <- mode_static
    modeTable[ "marquee" ] <- mode_marquee
    modeTable[ "full" ] <- mode_full
    modeTable[ "copy" ] <- mode_copy
    modeTable[ "clock" ] <- mode_clock
    modeTable[ "ping" ] <- mode_ping
    modeTable[ "stat" ] <- mode_stat
    modeTable[ "weapon" ] <- mode_weapon
    modeTable[ "position" ] <- null
}

table function getAllPresets(){
    // Create .json file if its missing
    if( !NSDoesFileExist( MQT_PRESET_FILEPATH ) ){
        NSSaveJSONFile( MQT_PRESET_FILEPATH, {} )
        return {}
    }

    table state = {
        data = {},
        finished = false
    }

    void functionref( string ) onSuccess = void function( string content ) : ( state ){
        if( content != "" )
            state.data = DecodeJSON( content )   
        state.finished = true
    }

    NSLoadFile( MQT_PRESET_FILEPATH, onSuccess, void function(){ debugPrint( "fuck fuck FUCKKKKKKKKKKKKK" ) } )

    while( !state.finished )
        wait 0
    
    debugPrint( "Loaded preset table" )

    return expect table( state.data )
}

void function setTag( string tag ){
    RunUIScript( "mqt_setTag", tag )
}

void function mqt_Init(){
    // Check dependency
    #if HAS_TOOLS
        dtool_printLogo( LD )
        
        RegisterSignal( "mqt_signal_newSettings" )
        RegisterSignal( "mqt_signal_updatePresets" )
        RegisterSignal( "mqt_signal_newCommunity" )
        RegisterSignal( "mqt_signal_newWeapon" )

        modeTable_Init()

        AddCallback_OnSelectedWeaponChanged( mqt_signalNewWeapon )
        
        thread keepUpdatingPresets()

        thread function():(){
            allPresets = getAllPresets()
            debugPrint( "Initialized! :3" )
            main()
        }()
    #else
        debugPrint( "Missing dependency: 'drachenfruchl.tools'" )
        debugPrint( "Failed to initialize! 3:" )
    #endif
}

void function keepUpdatingPresets(){
    for(;;){
        WaitSignal( clGlobal.signalDummy, "mqt_signal_updatePresets" )
        debugPrint( "Updating presets" )

        allPresets = getAllPresets()

        wait 0
    }
}

void function main(){
    while( GetLocalClientPlayer() == null )
        wait 0
    

    // Wait until the tag settings were updated through a button
    // This is different to mqtv3 which constantly checked for new settings by using multiple temp convars
    // The aim here is to make it less perfomance heavy and avoid accidental changes by waiting for manual approval through the user
    for(;;){
        if( !GetConVarBool( "cv_mqtv4_communityEditsAllowed" ) ){
            debugPrint( "Edits NOT allowed in community - go fuck yourself" )
            WaitSignal( clGlobal.signalDummy, "mqt_signal_newCommunity" )
            continue
        }

        debugPrint( "Edits allowed in community :333333333333" )

        string mode = GetConVarString( "cv_mqtv4_activeMode" )
        string preset = GetConVarString( "cv_mqtv4_activePreset" )
        
        debugPrint( format( "Setting new tag - Mode: '%s', Preset: %s", mode, ( preset == "" ? "None" : "'" + preset + "'" ) ) )

        // null functions because i havent implemented them yet
        if( modeTable[ mode ] != null )
            thread modeTable[ mode ]( preset )

        WaitSignal( clGlobal.signalDummy, "mqt_signal_newSettings", "mqt_signal_newCommunity" )
        WaitFrame()

        debugPrint( "New settings or new community" )
    }

    wait 0
}

void function mode_static( string preset = "" ){
    WaitFrame()
    
    string input

    // If no preset was selected use the current settings
    // Otherwise use the input from the preset
    if( preset == "" )
        input = GetConVarString( "cv_mqtv4_static_input" )
    else
        input = expect string( allPresets[ "static" ][ preset ].input ) 

    setTag( input )
}

void function mode_marquee( string preset = "" ){
    EndSignal( clGlobal.signalDummy, "mqt_signal_newSettings", "mqt_signal_newCommunity" )
    WaitFrame()

    string input
    float delay 
    int taglength
    bool reverse

    // If no preset was selected use the current settings
    // Otherwise use the values from the preset
    if( preset == "" ){
        input = GetConVarString( "cv_mqtv4_marquee_input" )
        delay = GetConVarFloat( "cv_mqtv4_marquee_delay" )
        taglength = GetConVarInt( "cv_mqtv4_marquee_taglength" )
        reverse = GetConVarBool( "cv_mqtv4_marquee_shouldReverse" )
    } else {
        table preset = expect table( allPresets[ "marquee" ][ preset ] )

        input = expect string( preset.input )
        delay = expect float( preset.delay )
        taglength = expect int( preset.taglength )
        reverse = expect bool( preset.reverse )
    }

    debugPrint( "MAKE MARQUEE START" )
    array<string> tags = makeMarquee( input, taglength )
    debugPrint( "MAKE MARQUEE END" )
    if( reverse )
        tags.reverse()

    for(;;){
		for( int i = 0; i < tags.len(); i++ ){
			wait delay/2
			setTag( tags[i] )
			wait delay/2
		}
	}
}

// TODO: auto bitslicelength
array<string> function makeMarquee( string input, int taglength ){
    while( input.len() < taglength )
        input += " "

    string         extendedMessage = input + " "
    int            extendedLen     = extendedMessage.len()
    string         tag
    int            effectiveEnd
    string         part1
    string         part2
    int            charsFromStart
    array<string>  result

    for( int i = 0; i < extendedLen; i++ ){
        effectiveEnd = i + taglength
        if( effectiveEnd <= extendedLen ){
            tag = extendedMessage.slice( i, effectiveEnd )
        } else {
            part1 = extendedMessage.slice( i, extendedLen )
            charsFromStart = effectiveEnd - extendedLen
            part2 = extendedMessage.slice( 0, charsFromStart )
            tag = part1 + part2
        }
        while( tag.find( " " ) != null )
            tag = StringReplace( tag, " ", "-" )
        result.append( tag )
        debugPrint( tag )
    }

    return result
}

void function mode_full( string preset = "" ){
    EndSignal( clGlobal.signalDummy, "mqt_signal_newSettings", "mqt_signal_newCommunity" )
    WaitFrame()

    string input
    float delay
    int taglength
    bool auto

    // If no preset was selected use the current settings
    // Otherwise use the values from the preset
    if( preset == "" ){
        input = GetConVarString( "cv_mqtv4_marquee_input" )
        delay = GetConVarFloat( "cv_mqtv4_marquee_delay" )
        taglength = GetConVarInt( "cv_mqtv4_marquee_taglength" )
        auto = GetConVarBool( "cv_mqtv4_marquee_shouldReverse" )
    } else {
        table preset = expect table( allPresets[ "full" ][ preset ] )

        input = expect string( preset.input )
        delay = expect float( preset.delay )
        taglength = expect int( preset.taglength )
        auto = expect bool( preset.auto )
    }

    debugPrint( "MAKE FULL START" )
    array<string> tags = makeFull( input, taglength, auto )
    debugPrint( "MAKE FULL END" )
    for(;;){
		for( int i = 0; i < tags.len(); i++ ){
			wait delay/2
			setTag( tags[i] )
			wait delay/2
		}
	}
}

// TODO: auto bitslicelength
array<string> function makeFull( string input, int taglength, bool auto = false ){
    array<string> inParts = split( input, " " )
    array<string> outParts = []

    if( auto || taglength < 2 )
        taglength = 4

    foreach( inPart in inParts ){
        string outPart = ""
        for( int i = 0; i < inPart.len(); i += taglength ){
            outPart = inPart.slice( i, ( ( i + taglength > inPart.len() ) ? inPart.len() : i + taglength ) )

            if( auto ){
                if( outPart.len() == 1 )
                    outPart += "-"
            } else {
                while( outPart.len() < taglength )
                    outPart += "-"
            }

            outParts.append( outPart )
            debugPrint( outPart )
        }
    }

    return outParts
}

void function mode_copy( string preset = "" ){
    EndSignal( clGlobal.signalDummy, "mqt_signal_newSettings", "mqt_signal_newCommunity" )
    WaitFrame()

    string playerName

    // If no preset was selected use the current settings
    // Otherwise use the input from the preset
    if( preset == "" )
        playerName = GetConVarString( "cv_mqtv4_copy_playerName" )
    else
        playerName = expect string( allPresets[ "copy" ][ preset ].input ) 

    entity player
    string tag
    string oldTag

    for(;;){
        player = dtool_getPlayerMatch_entity( playerName )
        while( player == null || !IsValid( player ) ){
            wait 1
            player = dtool_getPlayerMatch_entity( playerName )
        }

        for(;;){
            tag = dtool_getClanTagByEntity( player )
            while( tag == oldTag ){
                wait 0.1
                tag = dtool_getClanTagByEntity( player )
            }

            if( tag == "" ) 
                break

            setTag( tag )
            oldTag = tag

            wait 0
        }

        wait 0
    }
}

void function mode_clock( string preset = "" ){
    EndSignal( clGlobal.signalDummy, "mqt_signal_newSettings", "mqt_signal_newCommunity" )
    WaitFrame()

    int timezone

    if( preset == "" )
        timezone = GetConVarInt( "cv_mqtv4_clock_timezone" )
    else 
        timezone = expect int( allPresets[ "clock" ][ preset ].timezone ) 

    timezone -= 12

    table currentTime
    string tag
    string oldTag

    for(;;){
        currentTime = dtool_getCurrentTime( timezone )
        tag = format( "%02d%02d", currentTime.hour, currentTime.minute ) 

        while( tag == oldTag ){
            wait 1

            currentTime = dtool_getCurrentTime( timezone )
            tag = format( "%02d%02d", currentTime.hour, currentTime.minute ) 
        }

        setTag( tag )
        oldTag = tag

        wait 0
    } 
}

void function mode_ping( string preset = "" ){
    EndSignal( clGlobal.signalDummy, "mqt_signal_newSettings", "mqt_signal_newCommunity" )
    WaitFrame()

    float refreshrate
    bool useSuffix

    if( preset == "" ){
        refreshrate = GetConVarFloat( "cv_mqtv4_ping_refreshrate" )
        useSuffix = GetConVarBool( "cv_mqtv4_ping_useSuffix" )
    } else {
        table preset = expect table( allPresets[ "ping" ][ preset ] )

        refreshrate = expect float( preset.refreshrate ) 
        useSuffix = expect bool( preset.useSuffix ) 
    }

    string tag
    int ping

    for(;;){
        ping = MyPing()
        tag = format( "%3i", ping )
        
        if( useSuffix && ping < 100 )
            tag += "ms"

        setTag( tag )
        
        wait refreshrate
    }  
}

void function mode_stat( string preset = "" ){
    EndSignal( clGlobal.signalDummy, "mqt_signal_newSettings", "mqt_signal_newCommunity" )
    WaitFrame()

    string playername
    float refreshrate
    string statToTrack

    if( preset == "" ){
        playername = GetConVarString( "cv_mqtv4_stat_playerName" )
        refreshrate = GetConVarFloat( "cv_mqtv4_stat_refreshrate" )
        statToTrack = GetConVarString( "cv_mqtv4_stat_toTrack" )
    } else {
        table preset = expect table( allPresets[ "stat" ][ preset ] )

        playername = expect string( preset.input ) 
        refreshrate = expect float( preset.refreshrate )  
        statToTrack = expect string( preset.toTrack ) 
    }

    while( statToTrack.find( " " ) != null ) 
        statToTrack = StringReplace( statToTrack, " ", "_" ) 

    int PGS 

    try{
        PGS = GetIntFromString( "PGS_" + statToTrack.toupper() )
    } catch( exception ){
        debugPrint( "stat '" + PGS + "' doesnt exist" )
        return
    } 

    int stats
    string tag
    entity player 

    for(;;){
        if( playername == "" ){
            player = GetLocalClientPlayer()
        } else {
            player = dtool_getPlayerMatch_entity( playername )
            while( player == null || !IsValid( player ) ){
                player = dtool_getPlayerMatch_entity( playername )
                wait 0.1
            }     
        }

        stats = player.GetPlayerGameStat( PGS )

        tag = format( "%04i", int( clamp( stats, 0, 9999 ) ) )
        setTag( tag )

        wait refreshrate
    } 
}

// Resolves the local player's currently held weapon to a clean, human-readable name.
// Tries the weapon's localized "printname" first, falls back to a cleaned-up
// internal weapon name (e.g. "mp_weapon_rspn101" -> "RSPN101") if that fails.
string function getCurrentWeaponName(){
    entity player = GetLocalClientPlayer()
    if( player == null || !IsValid( player ) )
        return ""

    entity weapon = player.GetActiveWeapon()
    if( weapon == null || !IsValid( weapon ) )
        return ""

    string weaponRef = weapon.GetWeaponClassName()

    try{
        string token = expect string( GetWeaponInfoFileKeyField_Global( weaponRef, "printname" ) )
        string localized = Localize( token )

        // Unresolved tokens get handed back as-is (still starting with '#') - treat that as a miss
        if( localized != "" && localized.slice( 0, 1 ) != "#" )
            return localized.toupper()
    } catch( exception ){
        debugPrint( "No printname for weapon '" + weaponRef + "', falling back to raw name" )
    }

    string fallback = weaponRef
    fallback = StringReplace( fallback, "mp_titanweapon_", "" )
    fallback = StringReplace( fallback, "mp_weapon_", "" )
    fallback = StringReplace( fallback, "_", " " )
    return fallback.toupper()
}

// Resolves a weapon entity to its short, lowercase display name (e.g. "alternator").
string function getWeaponDisplayName( entity weapon ){
    try{
        return Localize( expect string( weapon.GetWeaponInfoFileKeyField( "shortprintname" ) ) ).tolower()
    } catch( exception ){
        debugPrint( "No shortprintname for weapon, falling back to raw name" )
        return getCurrentWeaponName().tolower()
    }
}

// Builds the marquee tag sequence for a given weapon entity.
array<string> function makeWeaponTags( entity weapon, int taglength, bool reverse ){
    string weaponName = getWeaponDisplayName( weapon )

    debugPrint( "MAKE WEAPON MARQUEE START: " + weaponName )
    array<string> tags = makeMarquee( weaponName, taglength )
    debugPrint( "MAKE WEAPON MARQUEE END" )

    if( reverse )
        tags.reverse()

    return tags
}

void function mode_weapon( string preset = "" ){
    EndSignal( clGlobal.signalDummy, "mqt_signal_newSettings", "mqt_signal_newCommunity" )
    WaitFrame()

    float delay
    int taglength
    bool reverse

    // If no preset was selected use the current settings
    // Otherwise use the values from the preset
    if( preset == "" ){
        delay = GetConVarFloat( "cv_mqtv4_weapon_delay" )
        taglength = GetConVarInt( "cv_mqtv4_weapon_taglength" )
        reverse = GetConVarBool( "cv_mqtv4_weapon_shouldReverse" )
    } else {
        table preset = expect table( allPresets[ "weapon" ][ preset ] )

        delay = expect float( preset.delay )
        taglength = expect int( preset.taglength )
        reverse = expect bool( preset.reverse )
    }

    // Not in a match (menus/lobby) - nothing to check a weapon against, so
    // scroll a custom placeholder marquee instead
    if( GetMapName() == "mp_lobby" ){
        array<string> lobbyTags = makeMarquee( MQT_LOBBY_TAG, taglength )
        if( reverse )
            lobbyTags.reverse()

        thread weaponMarqueeLoop( lobbyTags, delay )
        return
    }

    entity player = GetLocalClientPlayer()
        entity lastWeapon = null

        if( player != null && IsValid( player ) ){
            if( !IsAlive( player ) ){
                thread weaponMarqueeLoop( makeMarquee( "DEAD", taglength ), delay )
            } else {
                try{
                    lastWeapon = player.GetActiveWeapon()
                } catch( exception ){
                    lastWeapon = null
                }
                if( lastWeapon != null && IsValid( lastWeapon ) )
                    thread weaponMarqueeLoop( makeWeaponTags( lastWeapon, taglength, reverse ), delay )
            }
        }

        for(;;){
            WaitSignal( clGlobal.signalDummy, "mqt_signal_newWeapon" )

            player = GetLocalClientPlayer()
            if( player == null || !IsValid( player ) ){
                wait 0.1
                continue
            }

            if( !IsAlive( player ) ){
                thread weaponMarqueeLoop( makeMarquee( "DEAD", taglength ), delay )
                lastWeapon = null
                continue
            }

            entity weapon
            bool gotWeapon = false

            for(;;){
                // Re-fetch and re-check EVERY pass - during respawn spam the
                // player entity can go invalid between two adjacent lines,
                // and calling a native method on it throws a hard error that
                // otherwise kills this entire thread permanently.
                player = GetLocalClientPlayer()
                if( player == null || !IsValid( player ) )
                    break

                if( !IsAlive( player ) )
                    break

                try{
                    weapon = player.GetActiveWeapon()
                } catch( exception ){
                    debugPrint( "GetActiveWeapon threw - player went invalid mid-poll, recovering" )
                    break
                }

                if( weapon != lastWeapon && weapon != null && IsValid( weapon ) ){
                    gotWeapon = true
                    break
                }

                wait 0
            }

            if( !gotWeapon )
                continue // died again or player vanished mid-poll - next signal re-evaluates cleanly

            lastWeapon = weapon

            thread weaponMarqueeLoop( makeWeaponTags( weapon, taglength, reverse ), delay )
        }
    }

void function weaponMarqueeLoop( array<string> tags, float delay ){
    EndSignal( clGlobal.signalDummy, "mqt_signal_newWeapon" )

    for(;;){
        for( int i = 0; i < tags.len(); i++ ){
            wait delay/2
            setTag( tags[i] )
            wait delay/2
        }
    }
}
