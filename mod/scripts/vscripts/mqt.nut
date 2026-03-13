untyped
global function mqt_Init
global function mqt_signalNewSettings

#if HAS_TOOLS
LogoData LD = {
    logo =
    [
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

const table<int, void functionref()> modeTable

void function debugPrint( string message ){
    printt( "[MQTV5] " + message )
}

void function mqt_signalNewSettings(){
    Signal( clGlobal.signalDummy, "mqt_newSettings" )
}

void function modeTable_Init(){
    modeTable[0] <- mode_static
    modeTable[1] <- mode_marquee
    modeTable[2] <- mode_full
    modeTable[3] <- {}
    modeTable[4] <- {}
    modeTable[5] <- {}
    modeTable[6] <- {}
    modeTable[7] <- {}
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

        RegisterSignal( "mqt_newSettings" )
        modeTable_Init()
        thread main()

        debugPrint( "Initialized! :3")
    #else
        debugPrint( "Missing dependency: 'drachenfruchl.tools'" )
        debugPrint( "Failed to initialize! 3:")
    #endif
}

void function main(){
    // Wait until the tag settings were updated through a button
    // This is different to mqtv3 which constantly checked for new settings by using multiple temp convars
    // The aim here is to make it less perfomance heavy and avoid accidental changes by waiting for manual approval through the user
    for(;;){
        WaitFrame()

        // [ "Static", "Marquee", "Full", "Copy", "Clock", "Ping", "Stat", "Position" ]
        int modeIndex = GetConVarInt( "cv_mqtv4_mode" )
        thread modeTable[ modeIndex ]()
        /*
        switch( mode ){
            // Static
            case 0:
                mode_static()
                break

            // Marquee
            case 1:
                thread mode_marquee()
                break

            // Full
            case 2:
                thread mode_full()
                break

            // Copy
            case 3:
                break

            // Copy
            case 4:
                break

            // Ping
            case 5:
                break

            // Stat
            case 6:
                break

            // Position
            case 7:
                break
        }
        */

        WaitSignal( clGlobal.signalDummy, "mqt_newSettings" )
    }
}

void function mode_static(){
    string input = GetConVarString( "cv_mqtv4_input_static" )
    setTag( input )
}

void function mode_marquee(){
    EndSignal( clGlobal.signalDummy, "mqt_newSettings" )

    string input = GetConVarString( "cv_mqtv4_input_marquee" )
    float delay = GetConVarFloat( "cv_mqtv4_delay_marquee" )
    int taglength = GetConVarInt( "cv_mqtv4_taglength_marquee" )
    bool reverse = GetConVarBool( "cv_mqtv4_reverse_marquee" )

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

void function mode_full(){
    EndSignal( clGlobal.signalDummy, "mqt_newSettings" )

    string input = GetConVarString( "cv_mqtv4_input_full" )
    float delay = GetConVarFloat( "cv_mqtv4_delay_full" )
    int taglength = GetConVarInt( "cv_mqtv4_taglength_full" )
    bool auto = GetConVarBool( "cv_mqtv4_auto_full" )

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

void function setTag( string tag ){
    RunUIScript( "mqt_setTag", tag )
}