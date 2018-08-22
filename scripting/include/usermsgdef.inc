/**
 * Include description here.
 */

#if defined __usermsgdef_included
	#endinput
#endif

#define __usermsgdef_included

native void SendMessageFromKV(KeyValues kv, const int[] clients, int numClients, int flags = 0);

stock void SendMessageFromKVAll(KeyValues kv, int flags = 0) {
	int total;
	int[] clients = new int[MaxClients];
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientConnected(i)) {
			clients[total++] = i;
		}
	}
	SendMessageFromKV(kv, clients, total, flags);
}

stock void SendMessageFromKVOne(KeyValues kv, int client, int flags = 0) {
	int players[1];
	players[0] = client;
	SendMessageFromKV(kv, players, 1, flags);
}

public SharedPlugin __pl_usermsgdef = {
	name = "usermsgdef",
	file = "usermsgdef.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};
