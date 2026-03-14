untyped
global function mqtSettings_Init

const string mqt_preset_filepath = "mqtv4_presets.json"

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
    printt( "[MQTV5 : Settings] " + message )
}

void function mqtSettings_Init(){
    RegisterSignal( "mqt_newSettings" )
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


    ModSettings_AddButton( "[UPDATE TAG]", void function():(){ updateTag() } )
    ModSettings_AddButton( "[REFRESH PRESETS]", void function():(){ refreshPresets() } )

    // Load preset json so we can easily get every preset for each mode
    table allPresets = getAllPresets()

    // Static
    // input
    ModSettings_AddModCategory(	" > Static settings" )
    ModSettings_AddSetting(	"cv_mqtv4_static_input", "Input", "string" )

    // *static presets*
    foreach( table preset in allPresets[ "static" ] ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePreset( presetName )
            }
        )
    }

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

    // *marquee presets*
    foreach( table preset in allPresets[ "marquee" ] ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePreset( presetName )
            }
        )
    }

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

    // *full presets*
    foreach( table preset in allPresets[ "full" ] ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePreset( presetName )
            }
        )
    }

    // Copy
    // playername
    ModSettings_AddModCategory(	" > Copy settings" )
    ModSettings_AddSetting(	"cv_mqtv4_copy_playerName", "Player to copy", "string" )

    // *copy presets*
    foreach( table preset in allPresets[ "copy" ] ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePreset( presetName )
            }
        )
    }

    // Clock
    // timezone offset
    ModSettings_AddModCategory(	" > Clock settings" )
    ModSettings_AddEnumSetting( "cv_mqtv4_clock_timezone", "Timezone", timezoneEnum )

    // *clock presets*
    foreach( table preset in allPresets[ "clock" ] ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePreset( presetName )
            }
        )
    }

    // Ping
    // refreshrate
    // append ms suffix
    ModSettings_AddModCategory(	" > Ping settings" )
    ModSettings_AddSetting(	"cv_mqtv4_ping_refreshrate", "Refreshrate", "float" )
    ModSettings_AddEnumSetting( "cv_mqtv4_ping_useSuffix", "Append ms suffix for ping < 100", boolEnum )

    // *ping presets*
    foreach( table preset in allPresets[ "ping" ] ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePreset( presetName )
            }
        )
    }

    // PGS
    // playername (defaults to self)
    // refreshrate
    // stat
    ModSettings_AddModCategory(	" > Stat settings" )
    ModSettings_AddSetting(	"cv_mqtv4_stat_playerName", "Playername to grab stats from", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_stat_refreshrate", "Refreshrate", "float" )
    ModSettings_AddEnumSetting(	"cv_mqtv4_stat_toTrack", "Stat to track", statEnum )

    // *pgs presets*
    foreach( table preset in allPresets[ "stat" ] ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePreset( presetName )
            }
        )
    }

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

    // *position presets*
    foreach( table preset in allPresets[ "position" ] ){
        string presetName = expect string( preset[ "presetName" ] )
        ModSettings_AddButton(
            format( "[ Load preset '%s' ]", presetName ),
            void function():( presetName ) {
                setActivePreset( presetName )
            }
        )
    }
}

table function getAllPresets(){
    table state = {
        data = [],
        finished = false
    }

    void functionref( string ) onSuccess = void function( string content ) : ( state ){
        state.data = DecodeJSON( content )   
        state.finished = true
    }

    NSLoadFile( mqt_preset_filepath, onSuccess, void function(){ debugPrint( "fuck fuck FUCKKKKKKKKKKKKK" ) } )

    while( !state.finished )
        wait 0
    
    return expect table( state.data )
}

void function setActivePreset( string presetName ){
    debugPrint( format( "Set active preset to '%s'", presetName ) )  
    SetConVarString( "cv_mqtv4_activePreset", presetName ) 
}

void function updateTag(){
    try{
        debugPrint( "Sent mqt_newSettings signal" )
        RunClientScript( "mqt_signalNewSettings" )
    }catch(e){
        debugPrint( expect string( e ) )
    }
}

void function refreshPresets(){

}