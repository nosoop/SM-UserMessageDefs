/**
 * Sourcemod 1.7 Plugin Template
 */
#pragma semicolon 1
#include <sourcemod>

#include <tf2_stocks>

#pragma newdecls required

#include <usermsgdef>

public void OnMapStart() {
	KeyValues hud = new KeyValues("HudNotifyCustom");
	hud.SetString("message", "oh shit waddup");
	hud.SetString("icon", "obj_status_sapper");
	hud.SetNum("team", view_as<int>(TFTeam_Red));
	
	SendMessageFromKVAll(hud);
	
	delete hud;
}
