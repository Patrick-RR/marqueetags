global function mqtSettings_Init

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
    ModSettings_AddEnumSetting( "cv_mqtv4_mode", "Mode", modeEnum )
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


    // Static
    // input
    ModSettings_AddModCategory(	" > Static settings" )
    ModSettings_AddSetting(	"cv_mqtv4_input_static", "Input", "string" )

    // *static presets*

    // Marquee
    // input
    // delay
    // taglength (auto bitslicelength)
    // reverse
    ModSettings_AddModCategory(	" > Marquee settings" )
    ModSettings_AddSetting(	"cv_mqtv4_input_marquee", "Input", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_delay_marquee", "Delay", "float" )
    ModSettings_AddSetting(	"cv_mqtv4_taglength_marquee", "Tag length", "int" )
    ModSettings_AddEnumSetting( "cv_mqtv4_reverse_marquee", "Reverse", boolEnum )

    // *marquee presets*

    // Full
    // input
    // delay
    // taglength (auto bitslicelength)
    // auto taglength
    ModSettings_AddModCategory(	" > Full settings" )
    ModSettings_AddSetting(	"cv_mqtv4_input_full", "Input", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_delay_full", "Delay", "float" )
    ModSettings_AddSetting(	"cv_mqtv4_taglength_full", "Tag length", "int" )
    ModSettings_AddEnumSetting( "cv_mqtv4_auto_full", "Auto taglength", boolEnum )

    // *full presets*

    // Copy
    // playername
    ModSettings_AddModCategory(	" > Copy settings" )
    ModSettings_AddSetting(	"cv_mqtv4_input_copy", "Player to copy", "string" )

    // *copy presets*

    // Clock
    // timezone offset
    ModSettings_AddModCategory(	" > Clock settings" )
    ModSettings_AddEnumSetting( "cv_mqtv4_clock_offset", "Timezone", timezoneEnum )

    // *clock presets*

    // Ping
    // refreshrate
    // append ms suffix
    ModSettings_AddModCategory(	" > Ping settings" )
    ModSettings_AddSetting(	"cv_mqtv4_ping_refreshrate", "Refreshrate", "float" )
    ModSettings_AddEnumSetting( "cv_mqtv4_ping_useSuffix", "Append ms suffix for ping < 100", boolEnum )

    // *ping presets*

    // PGS
    // playername (defaults to self)
    // stat
    ModSettings_AddModCategory(	" > Stat settings" )
    ModSettings_AddSetting(	"cv_mqtv4_input_stat", "Playername to grab stats from", "string" )
    ModSettings_AddEnumSetting(	"cv_mqtv4_stat_toTrack", "Stat to track", statEnum )

    // *pgs presets*

    // Position
    // top 1 preset or static tag
    // top 2 "
    // top 3 "
    // top 4 "
    // top 5 "
    // top 6 "
    ModSettings_AddModCategory(	" > Position settings" )
    ModSettings_AddSetting(	"cv_mqtv4_preset_top1", "Top 1 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_preset_top2", "Top 2 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_preset_top3", "Top 3 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_preset_top4", "Top 4 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_preset_top5", "Top 5 preset name", "string" )
    ModSettings_AddSetting(	"cv_mqtv4_preset_top6", "Top 6 preset name", "string" )

    // *position presets*
    // shorten: [top1] [top2] [top3] [top4] [top5] [top5]

}

void function updateTag(){
    debugPrint( "Sent mqt_newSettings signal" )
    RunClientScript( "mqt_signalNewSettings" )
}

void function refreshPresets(){

}