/**
 * Sourcemod 1.7 Plugin Template
 */
#pragma semicolon 1
#include <sourcemod>

#pragma newdecls required

#define PLUGIN_VERSION "0.0.0"
public Plugin myinfo = {
	name = "User Message Definitions",
	author = "nosoop",
	description = "Proof of concept for creating cross-game usermessages out of KeyValues.",
	version = PLUGIN_VERSION,
	url = "https://gist.github.com"
}

#define USERMSG_PATH_FMT "data/usermsg/%s.txt"

enum MessageFieldType {
	MessageField_Unimplemented,
	MessageField_Byte,
	MessageField_Short,
	MessageField_Int,
	MessageField_String,
}

KeyValues g_UserMessageDefinition;

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int maxlen) {
	char filepath[PLATFORM_MAX_PATH], game[32];
	
	GetGameFolderName(game, sizeof(game));
	BuildPath(Path_SM, filepath, sizeof(filepath), USERMSG_PATH_FMT, game);
	
	if (!FileExists(filepath)) {
		SetFailState("Could not load user message definition " ... USERMSG_PATH_FMT, game);
	}
	
	g_UserMessageDefinition = new KeyValues("UserMessages");
	g_UserMessageDefinition.ImportFromFile(filepath);
	
	RegPluginLibrary("usermsgdef");
	CreateNative("SendMessageFromKV", NativeSendMessageFromKV);
	
	return APLRes_Success;
}

public int NativeSendMessageFromKV(Handle plugin, int argc) {
	int numClients = GetNativeCell(3);
	int flags = GetNativeCell(4);
	
	int[] clients = new int[numClients];
	
	GetNativeArray(2, clients, numClients);
	
	KeyValues kv = GetNativeCell(1);
	
	char msgName[128];
	kv.GetSectionName(msgName, sizeof(msgName));
	
	g_UserMessageDefinition.Rewind();
	
	if (!g_UserMessageDefinition.JumpToKey(msgName)
			|| !g_UserMessageDefinition.GotoFirstSubKey(false)) {
		ThrowError("No user message definition present for message name %s", msgName);
	}
	
	Handle userMessage = StartMessage(msgName, clients, numClients, flags);
	switch (GetUserMessageType()) {
		case UM_BitBuf: {
			BfWrite msg = UserMessageToBfWrite(userMessage);
			do {
				char field[128], type[128];
				g_UserMessageDefinition.GetSectionName(field, sizeof(field));
				g_UserMessageDefinition.GetString(NULL_STRING, type, sizeof(type));
				
				switch (ParseFieldType(type)) {
					case MessageField_Byte: {
						msg.WriteByte(kv.GetNum(field));
					}
					case MessageField_String: {
						char messageString[256];
						kv.GetString(field, messageString, sizeof(messageString));
						msg.WriteString(messageString);
					}
					default: {
						ThrowError("Uminplemented type %s (from field %s.%s)",
								type, msgName, field);
					}
				}
			} while (g_UserMessageDefinition.GotoNextKey(false));
		}
		case UM_Protobuf: {
			// TODO implementation
		}
		default: {
			ThrowError("Unknown usermessage type %d", GetUserMessageType());
		}
	}
	EndMessage();
}

MessageFieldType ParseFieldType(const char[] type) {
	if (StrEqual(type, "byte")) {
		return MessageField_Byte;
	}
	if (StrEqual(type, "short")) {
		return MessageField_Short;
	}
	if (StrEqual(type, "int")) {
		return MessageField_Int;
	}
	if (StrEqual(type, "string")) {
		return MessageField_String;
	}
	return MessageField_Unimplemented;
}
