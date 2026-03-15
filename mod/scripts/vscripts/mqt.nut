untyped
global function mqt_Init
global function mqt_signalNewSettings
global function mqt_signalUpdatePresets

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

    // color_start = < 255, 255, 255 > // #FFFFFF White
    // color_end   = < 255, 51, 153 > // #ff3399 Soft pink
}
#endif

const string MQT_PRESET_FILEPATH = "mqtv4_presets.json"

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

void function modeTable_Init(){
    modeTable[ "static" ] <- mode_static
    modeTable[ "marquee" ] <- mode_marquee
    modeTable[ "full" ] <- mode_full
    modeTable[ "copy" ] <- null
    modeTable[ "clock" ] <- null
    modeTable[ "ping" ] <- null
    modeTable[ "stat" ] <- null
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

// RunUIScript( "mqt_setTag", tag )
/*
const array<int> timezoneOffsets = [
	-12, -11, -10, -9, -8, -7, -6,
	-5, -4, -3, -2, -1, 0, 1,
	2, 3, 4, 5, 6, 7, 8,
	9, 10, 11, 12, 13, 14
]
*/

void function mqt_Init(){
    // Check dependency
    #if HAS_TOOLS
        dtool_printLogo( LD )
        
        RegisterSignal( "mqt_signal_newSettings" )
        RegisterSignal( "mqt_signal_updatePresets" )

        modeTable_Init()
        
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
    // Wait until the tag settings were updated through a button
    // This is different to mqtv3 which constantly checked for new settings by using multiple temp convars
    // The aim here is to make it less perfomance heavy and avoid accidental changes by waiting for manual approval through the user
    for(;;){
        // [ "Static", "Marquee", "Full", "Copy", "Clock", "Ping", "Stat", "Position" ]
        string mode = GetConVarString( "cv_mqtv4_activeMode" )
        string preset = GetConVarString( "cv_mqtv4_activePreset" )
        
        debugPrint( format( "Setting new tag - Mode: '%s', Preset: %s", mode, ( preset == "" ? "None" : "'" + preset + "'" ) ) )

        // null functions because i havent implemented them yet
        if( modeTable[ mode ] != null )
            thread modeTable[ mode ]( preset )

        WaitSignal( clGlobal.signalDummy, "mqt_signal_newSettings" )
        WaitFrame()
    }
}

void function mode_static( string preset = "" ){
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
    EndSignal( clGlobal.signalDummy, "mqt_signal_newSettings" )

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
    EndSignal( clGlobal.signalDummy, "mqt_signal_newSettings" )

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