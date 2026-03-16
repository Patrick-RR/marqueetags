untyped
global function mqtSettings_Init

const string MQT_PRESET_FILEPATH = "mqtv4_presets.json"

const array<string> boolEnum = [ "No", "Yes" ]
const array<string> modeEnum = [ "Static", "Marquee", "Full", "Copy", "Clock", "Ping", "Stat", "Position" ]
const array<string> timezoneEnum = [
    "GMT-12", "GMT-11", "GMT-10", "GMT-9", "GMT-8", "GMT-7", "GMT-6",
    "GMT-5", "GMT-4", "GMT-3", "GMT-2", "GMT-1", "GMT", "GMT+1",
    "GMT+2", "GMT+3", "GMT+4", "GMT+5", "GMT+6", "GMT+7", "GMT+8",
    "GMT+9", "GMT+10", "GMT+11", "GMT+12", "GMT+13", "GMT+14"
]
const array<string> statEnum = [ "0", "1" ] // To be filled

void function debugPrint( string message ){
    printt( "[MQTV4 : Settings] " + message )
}

void function mqtSettings_Init(){
    thread main()
}

// This function is threaded so we can dynamically add presets
// Loading presets from a json is async meaning we must wait until we actually load content
void function main(){
    ModSettings_AddModTitle( "^FFFFFF00[MQTv4] Marquee Tags ^7D83FF00v4.0" )
    ModSettings_AddModCategory(	" > General settings" )

    ModSettings_AddEnumSetting(	"cv_mqtv4_enabled", "Enabled", boolEnum )
    //ModSettings_AddEnumSetting( "cv_mqtv4_mode", "Mode", modeEnum )
    ModSettings_AddSetting(	"cv_mqtv4_activePreset", "Active preset", "string" )

    // "Hardcoded" network IDs to use later on
    ModSettings_AddSetting(	"cv_mqtv4_networkID_owned", "Owned network ID", "int" )
    ModSettings_AddSetting(	"cv_mqtv4_networkID_invisible", "Invisible network ID", "int" )

    // Does what it says on the tin
    // Does nothing if youre the party leader yourself
    ModSettings_AddEnumSetting(	"cv_mqtv4_syncToPartyLeader", "Auto sync with party leader", boolEnum )

    // Tag that gets set when opening the chatbox as to only change the tag for the message being sent or while typing
    ModSettings_AddEnumSetting(	"cv_mqtv4_useChatPreset", "Use unique preset for chat messages", boolEnum )
    ModSettings_AddSetting(	"cv_mqtv4_chatPreset", "Chat preset", "string" )

    // Preset that gets selected on entering a gamestate (postgame or eog)
    ModSettings_AddEnumSetting(	"cv_mqtv4_useEOGPreset", "Use unique preset for EOG", boolEnum )
    ModSettings_AddSetting(	"cv_mqtv4_EOGPreset", "EOG preset", "string" )

    // Load preset json so we can easily get every preset for each mode
    table allPresets = getAllPresets()

    // ==========================================================================================

    // Static
    // input
    ModSettings_AddModCategory(	" > Static settings" )
    ModSettings_AddSetting(	"cv_mqtv4_static_input", "Input", "string" )

    ModSettings_AddButton( "[ Update tag to use current settings ]", void function():(){ setActiveMode( "static" ) } )

    ModSettings_AddSetting(	"cv_mqtv4_static_presetName", "Preset name", "string" )
    ModSettings_AddButton( "[ Save current settings as preset ]", void function():(){ saveCurrentPresetToFile( "static" ) } )
    
    // *static presets*
    foreach( table preset in ( "static" in allPresets ? allPresets[ "static" ] : [] ) ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePresetAndMode( "static", presetName )
            }
        )
    }

    // ==========================================================================================

    // Marquee
    // input
    // delay
    // taglength (auto bitslicelength)
    // reverse
    ModSettings_AddModCategory(	" > Marquee settings" )
    ModSettings_AddSetting(	"cv_mqtv4_marquee_input", "Input", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_marquee_delay", "Delay", "float" )
    ModSettings_AddSetting(	"cv_mqtv4_marquee_taglength", "Tag length", "int" )
    ModSettings_AddEnumSetting( "cv_mqtv4_marquee_shouldReverse", "Reverse", boolEnum )

    ModSettings_AddButton( "[ Update tag to use current settings ]", void function():(){ setActiveMode( "marquee" ) } )

    ModSettings_AddSetting(	"cv_mqtv4_marquee_presetName", "Preset name", "string" )
    ModSettings_AddButton( "[ Save current settings as preset ]", void function():(){ saveCurrentPresetToFile( "marquee" ) } )

    // *marquee presets*
    foreach( table preset in ( "marquee" in allPresets ? allPresets[ "marquee" ] : [] ) ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePresetAndMode( "marquee", presetName )
            }
        )
    }

    // ==========================================================================================

    // Full
    // input
    // delay
    // taglength (auto bitslicelength)
    // auto taglength
    ModSettings_AddModCategory(	" > Full settings" )
    ModSettings_AddSetting(	"cv_mqtv4_full_input", "Input", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_full_delay", "Delay", "float" )
    ModSettings_AddSetting(	"cv_mqtv4_full_taglength", "Tag length", "int" )
    ModSettings_AddEnumSetting( "cv_mqtv4_full_shouldAutoSize", "Auto taglength", boolEnum )

    ModSettings_AddButton( "[ Update tag to use current settings ]", void function():(){ setActiveMode( "full" ) } )

    ModSettings_AddSetting(	"cv_mqtv4_full_presetName", "Preset name", "string" )
    ModSettings_AddButton( "[ Save current settings as preset ]", void function():(){ saveCurrentPresetToFile( "full" ) } )

    // *full presets*
    foreach( table preset in ( "full" in allPresets ? allPresets[ "full" ] : [] ) ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePresetAndMode( "full", presetName )
            }
        )
    }

    // ==========================================================================================

    // Copy
    // playername
    ModSettings_AddModCategory(	" > Copy settings" )
    ModSettings_AddSetting(	"cv_mqtv4_copy_playerName", "Player to copy", "string" )

    ModSettings_AddButton( "[ Update tag to use current settings ]", void function():(){ setActiveMode( "copy" ) } )

    ModSettings_AddSetting(	"cv_mqtv4_copy_presetName", "Preset name", "string" )
    ModSettings_AddButton( "[ Save current settings as preset ]", void function():(){ saveCurrentPresetToFile( "copy" ) } )

    // *copy presets*
    foreach( table preset in ( "copy" in allPresets ? allPresets[ "copy" ] : [] ) ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePresetAndMode( "copy", presetName )
            }
        )
    }

    // ==========================================================================================

    // Clock
    // timezone offset
    ModSettings_AddModCategory(	" > Clock settings" )
    ModSettings_AddEnumSetting( "cv_mqtv4_clock_timezone", "Timezone", timezoneEnum )

    ModSettings_AddButton( "[ Update tag to use current settings ]", void function():(){ setActiveMode( "clock" ) } )

    ModSettings_AddSetting(	"cv_mqtv4_clock_presetName", "Preset name", "string" )
    ModSettings_AddButton( "[ Save current settings as preset ]", void function():(){ saveCurrentPresetToFile( "clock" ) } )

    // *clock presets*
    foreach( table preset in ( "clock" in allPresets ? allPresets[ "clock" ] : [] ) ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePresetAndMode( "clock", presetName )
            }
        )
    }

    // ==========================================================================================

    // Ping
    // refreshrate
    // append ms suffix
    ModSettings_AddModCategory(	" > Ping settings" )
    ModSettings_AddSetting(	"cv_mqtv4_ping_refreshrate", "Refreshrate", "float" )
    ModSettings_AddEnumSetting( "cv_mqtv4_ping_useSuffix", "Append ms suffix for ping < 100", boolEnum )

    ModSettings_AddButton( "[ Update tag to use current settings ]", void function():(){ setActiveMode( "clock" ) } )

    ModSettings_AddSetting(	"cv_mqtv4_ping_presetName", "Preset name", "string" )
    ModSettings_AddButton( "[ Save current settings as preset ]", void function():(){ saveCurrentPresetToFile( "clock" ) } )
    
    // *ping presets*
    foreach( table preset in ( "ping" in allPresets ? allPresets[ "ping" ] : [] ) ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePresetAndMode( "ping", presetName )
            }
        )
    }

    // ==========================================================================================

    // PGS
    // playername (defaults to self)
    // refreshrate
    // stat
    ModSettings_AddModCategory(	" > Stat settings" )
    ModSettings_AddSetting(	"cv_mqtv4_stat_playerName", "Playername to grab stats from", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_stat_refreshrate", "Refreshrate", "float" )
    ModSettings_AddEnumSetting(	"cv_mqtv4_stat_toTrack", "Stat to track", statEnum )
    
    ModSettings_AddButton( "[ Update tag to use current settings ]", void function():(){ setActiveMode( "stat" ) } )

    ModSettings_AddSetting(	"cv_mqtv4_stat_presetName", "Preset name", "string" )
    ModSettings_AddButton( "[ Save current settings as preset ]", void function():(){ saveCurrentPresetToFile( "stat" ) } )

    // *pgs presets*
    foreach( table preset in ( "stat" in allPresets ? allPresets[ "stat" ] : [] ) ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePresetAndMode( "stat", presetName )
            }
        )
    }

    // ==========================================================================================
    
    // Position
    // top 1 preset or static tag
    // top 2 "
    // top 3 "
    // top 4 "
    // top 5 "
    // top 6 "
    ModSettings_AddModCategory(	" > Position settings" )
    ModSettings_AddSetting(	"cv_mqtv4_position_preset_top1", "Top 1 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_position_preset_top2", "Top 2 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_position_preset_top3", "Top 3 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_position_preset_top4", "Top 4 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_position_preset_top5", "Top 5 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_position_preset_top6", "Top 6 preset name", "string" )

    ModSettings_AddButton( "[ Update tag to use current settings ]", void function():(){ setActiveMode( "position" ) } )

    ModSettings_AddSetting(	"cv_mqtv4_position_presetName", "Preset name", "string" )
    ModSettings_AddButton( "[ Save current settings as preset ]", void function():(){ saveCurrentPresetToFile( "position" ) } )

    // *position presets*
    foreach( table preset in ( "position" in allPresets ? allPresets[ "position" ] : [] ) ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePresetAndMode( "position", presetName )
            }
        )
    }
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
    
    return expect table( state.data )
}

void function saveCurrentPresetToFile( string mode ){
    void functionref( string ) onSuccess = void function( string content ) : ( mode ){
        table json = ( content == "" ? {} : DecodeJSON( content ) ) 

        string presetName = GetConVarString( format( "cv_mqtv4_%s_presetName", mode ) ) 

        // Create mode category in json if its missing
        if( !( mode in json ) )
            json[ mode ] <- {}
        
        // Create preset entry for category if its missing
        if( !( presetName in json[ mode ] ) )
            json[ mode ][ presetName ] <- {}

        table preset = expect table( json[ mode ][ presetName ] )

        // General preset value every mode has
        preset.presetName <- presetName

        // Each mode has different preset values so we must create them accordingly
        json[ mode ][ presetName ] = addPresetEntriesForMode( preset, mode )

        NSSaveJSONFile( MQT_PRESET_FILEPATH, json )
        updatePresets()
    }

    // Create .json file if its missing
    if( !NSDoesFileExist( MQT_PRESET_FILEPATH ) )
		NSSaveJSONFile( MQT_PRESET_FILEPATH, {} )

    NSLoadFile( MQT_PRESET_FILEPATH, onSuccess, void function(){ debugPrint( "fuck fuck FUCKKKKKKKKKKKKK" ) } )
}

table function addPresetEntriesForMode( table preset, string mode ){
    switch( mode ){
        case "static":
            preset.input <- GetConVarString( "cv_mqtv4_static_input" )
            break

        case "marquee":
            preset.input <- GetConVarString( "cv_mqtv4_marquee_input" )
            preset.delay <- GetConVarFloat( "cv_mqtv4_marquee_delay" )
            preset.taglength <- GetConVarInt( "cv_mqtv4_marquee_taglength" )
            preset.reverse <- GetConVarBool( "cv_mqtv4_marquee_shouldReverse" )
            break

        case "full":
            preset.input <- GetConVarString( "cv_mqtv4_full_input" )
            preset.delay <- GetConVarFloat( "cv_mqtv4_full_delay" )
            preset.taglength <- GetConVarInt( "cv_mqtv4_full_taglength" )
            preset.auto <- GetConVarBool( "cv_mqtv4_full_shouldAutoSize" )
            break

        case "copy":
            preset.input <- GetConVarString( "cv_mqtv4_copy_playerName" )
            break

        case "clock":
            preset.timezone <- GetConVarInt( "cv_mqtv4_clock_timezone" )
            break

        case "ping":
            preset.refreshrate <- GetConVarFloat( "cv_mqtv4_ping_refreshrate" )
            preset.useSuffix <- GetConVarBool( "cv_mqtv4_ping_useSuffix" )
            break

        case "stat":
            preset.input <- GetConVarString( "cv_mqtv4_stat_playerName" )
            preset.refreshrate <- GetConVarFloat( "cv_mqtv4_stat_refreshrate" )
            preset.toTrack <- GetConVarInt( "cv_mqtv4_stat_toTrack" )
            break

        case "position":
            preset.top1 <- GetConVarString( "cv_mqtv4_position_preset_top1" )
            preset.top2 <- GetConVarString( "cv_mqtv4_position_preset_top2" )
            preset.top3 <- GetConVarString( "cv_mqtv4_position_preset_top3" )
            preset.top4 <- GetConVarString( "cv_mqtv4_position_preset_top4" )
            preset.top5 <- GetConVarString( "cv_mqtv4_position_preset_top5" )
            preset.top6 <- GetConVarString( "cv_mqtv4_position_preset_top6" )
            break
    }

    return preset
}

void function setActiveMode( string mode ){
    debugPrint( format( "Set active mode to '%s'", mode ) )  
    SetConVarString( "cv_mqtv4_activePreset", "" ) 
    SetConVarString( "cv_mqtv4_activeMode", mode )
    updateTag()
}

void function setActivePresetAndMode( string mode, string presetName ){
    debugPrint( format( "Set active preset to '%s' in '%s' mode", presetName, mode ) )  
    SetConVarString( "cv_mqtv4_activePreset", presetName ) 
    SetConVarString( "cv_mqtv4_activeMode", mode ) 
    updateTag()
}

void function updateTag(){
    try{
        debugPrint( "Sent mqt_signal_NewSettings signal" )
        RunClientScript( "mqt_signalNewSettings" )
    }catch(e){
        debugPrint( expect string( e ) )
    }
}

void function updatePresets(){
    try{
        debugPrint( "Sent mqt_signal_UpdatePresets signal" )
        RunClientScript( "mqt_signalUpdatePresets" )
    }catch(e){
        debugPrint( expect string( e ) )
    }
}