#include <sourcemod>

new Handle:cv_enablepause;

new iInitialAllTalk = 0;

new bool:isGamePaused = false;
new bool:allowPause = false;

#define PLUGIN_VERSION "1.0"

const L4D_UNPAUSE_DELAY = 5;



public Plugin:myinfo = {
	name = "L4D2 Pause plugin",
	author = "DannyD",
	description = "Pauses the game",
	version = PLUGIN_VERSION,
	url = "n/a"
};


public OnPluginStart() {
	RegAdminCmd("sm_pause", Command_PauseGame, ADMFLAG_GENERIC, "Pause the game");
	RegAdminCmd("sm_unpause", Command_UnpauseGame, ADMFLAG_GENERIC, "Unpause the game");
}

public Action:Command_PauseGame(client, args) {

	if (isGamePaused) return Plugin_Handled;
	
	allowPause = true;
	SetConVarInt(FindConVar("sv_pausable"), 1); //Ensure sv_pausable is set to 1
	FakeClientCommand(client, "setpause"); //Send pause command
	SetConVarInt(FindConVar("sv_pausable"), 0); //Reset sv_pausable back to 0
	allowPause = false;
	
	iInitialAllTalk = GetConVarInt(FindConVar("sv_alltalk"));
	SetConVarInt(FindConVar("sv_alltalk"), 1);
	
	PrintToChatAll("\x03[PAUSE]\x01 \x04%N\x01 has paused the game, and AllTalk is now on.", client);
	
	isGamePaused = true;
		
	return Plugin_Handled;
	
}

public Action:Command_UnpauseGame(client, args) {

	if (!isGamePaused) return Plugin_Handled;
			
	PrintToChatAll("\x03[PAUSE]\x01 \x04%N\x01 has unpaused the game", client);
			
	CreateTimer(1.0, UnPauseCountDown, client, TIMER_REPEAT);
	
	return Plugin_Handled;
}

public Action:UnPauseCountDown(Handle:timer, any:client) {

	static Countdown = L4D_UNPAUSE_DELAY-1;

	if (Countdown <= 0)
	{
		Countdown = L4D_UNPAUSE_DELAY-1;
		
		PrintToChatAll("\x03[PAUSE]\x01 Game is now live!");
					
		allowPause = true;
		SetConVarInt(FindConVar("sv_pausable"), 1);
		FakeClientCommand(client, "unpause");
		SetConVarInt(FindConVar("sv_alltalk"), iInitialAllTalk);
		SetConVarInt(FindConVar("sv_pausable"), 0);
		allowPause = false;
		
		SetConVarInt(FindConVar("sv_alltalk"), iInitialAllTalk);
		
		isGamePaused = false;
		return Plugin_Stop;
	}
	PrintToChatAll("\x03[PAUSE]\x01 Game is going live in %d seconds...", Countdown);
				
	Countdown--;
	
	return Plugin_Continue;
}

// This blocks the pause/unpause that happens when clients open developer console
public Action:Client_Pause(client, const String:command[], argc)  {

	if(!GetConVarBool(cv_enablepause)) { return Plugin_Continue; }

	if(allowPause) { return Plugin_Continue; }
	
	return Plugin_Handled;
}