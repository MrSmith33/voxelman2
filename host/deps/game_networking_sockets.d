module deps.game_networking_sockets;
extern(C):

// List obtained from running `dumpbin /exports GameNetworkingSockets.dll`
void GameNetworkingSockets_Init();
void GameNetworkingSockets_Kill();
void SteamAPI_ISteamNetworkingSockets_AcceptConnection();
void SteamAPI_ISteamNetworkingSockets_CloseConnection();
void SteamAPI_ISteamNetworkingSockets_CloseListenSocket();
void SteamAPI_ISteamNetworkingSockets_ConfigureConnectionLanes();
void SteamAPI_ISteamNetworkingSockets_ConnectByIPAddress();
void SteamAPI_ISteamNetworkingSockets_CreateCustomSignaling();
void SteamAPI_ISteamNetworkingSockets_CreateListenSocketIP();
void SteamAPI_ISteamNetworkingSockets_CreatePollGroup();
void SteamAPI_ISteamNetworkingSockets_CreateSocketPair();
void SteamAPI_ISteamNetworkingSockets_DestroyPollGroup();
void SteamAPI_ISteamNetworkingSockets_FlushMessagesOnConnection();
void SteamAPI_ISteamNetworkingSockets_GetAuthenticationStatus();
void SteamAPI_ISteamNetworkingSockets_GetCertificateRequest();
void SteamAPI_ISteamNetworkingSockets_GetConnectionInfo();
void SteamAPI_ISteamNetworkingSockets_GetConnectionName();
void SteamAPI_ISteamNetworkingSockets_GetConnectionRealTimeStatus();
void SteamAPI_ISteamNetworkingSockets_GetConnectionUserData();
void SteamAPI_ISteamNetworkingSockets_GetDetailedConnectionStatus();
void SteamAPI_ISteamNetworkingSockets_GetIdentity();
void SteamAPI_ISteamNetworkingSockets_GetListenSocketAddress();
void SteamAPI_ISteamNetworkingSockets_InitAuthentication();
void SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnConnection();
void SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnPollGroup();
void SteamAPI_ISteamNetworkingSockets_ReceivedP2PCustomSignal2();
void SteamAPI_ISteamNetworkingSockets_RunCallbacks();
void SteamAPI_ISteamNetworkingSockets_SendMessageToConnection();
void SteamAPI_ISteamNetworkingSockets_SendMessages();
void SteamAPI_ISteamNetworkingSockets_SetCertificate();
void SteamAPI_ISteamNetworkingSockets_SetConnectionName();
void SteamAPI_ISteamNetworkingSockets_SetConnectionPollGroup();
void SteamAPI_ISteamNetworkingSockets_SetConnectionUserData();
void SteamAPI_ISteamNetworkingUtils_AllocateMessage();
void SteamAPI_ISteamNetworkingUtils_GetConfigValue();
void SteamAPI_ISteamNetworkingUtils_GetConfigValueInfo();
void SteamAPI_ISteamNetworkingUtils_GetLocalTimestamp();
void SteamAPI_ISteamNetworkingUtils_IterateGenericEditableConfigValues();
void SteamAPI_ISteamNetworkingUtils_SetConfigValue();
void SteamAPI_ISteamNetworkingUtils_SetConfigValueStruct();
void SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueFloat();
void SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueInt32();
void SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueString();
void SteamAPI_ISteamNetworkingUtils_SetDebugOutputFunction();
void SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamNetAuthenticationStatusChanged();
void SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamNetConnectionStatusChanged();
void SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamRelayNetworkStatusChanged();
void SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueFloat();
void SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueInt32();
void SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValuePtr();
void SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueString();
void SteamAPI_SteamNetworkingIPAddr_Clear();
void SteamAPI_SteamNetworkingIPAddr_GetIPv4();
void SteamAPI_SteamNetworkingIPAddr_IsEqualTo();
void SteamAPI_SteamNetworkingIPAddr_IsIPv4();
void SteamAPI_SteamNetworkingIPAddr_IsIPv6AllZeros();
void SteamAPI_SteamNetworkingIPAddr_IsLocalHost();
void SteamAPI_SteamNetworkingIPAddr_ParseString();
void SteamAPI_SteamNetworkingIPAddr_SetIPv4();
void SteamAPI_SteamNetworkingIPAddr_SetIPv6();
void SteamAPI_SteamNetworkingIPAddr_SetIPv6LocalHost();
void SteamAPI_SteamNetworkingIPAddr_ToString();
void SteamAPI_SteamNetworkingIdentity_Clear();
void SteamAPI_SteamNetworkingIdentity_GetGenericBytes();
void SteamAPI_SteamNetworkingIdentity_GetGenericString();
void SteamAPI_SteamNetworkingIdentity_GetIPAddr();
void SteamAPI_SteamNetworkingIdentity_GetSteamID();
void SteamAPI_SteamNetworkingIdentity_GetSteamID64();
void SteamAPI_SteamNetworkingIdentity_IsEqualTo();
void SteamAPI_SteamNetworkingIdentity_IsInvalid();
void SteamAPI_SteamNetworkingIdentity_IsLocalHost();
void SteamAPI_SteamNetworkingIdentity_ParseString();
void SteamAPI_SteamNetworkingIdentity_SetGenericBytes();
void SteamAPI_SteamNetworkingIdentity_SetGenericString();
void SteamAPI_SteamNetworkingIdentity_SetIPAddr();
void SteamAPI_SteamNetworkingIdentity_SetLocalHost();
void SteamAPI_SteamNetworkingIdentity_SetSteamID();
void SteamAPI_SteamNetworkingIdentity_SetSteamID64();
void SteamAPI_SteamNetworkingIdentity_ToString();
void SteamAPI_SteamNetworkingMessage_t_Release();
void SteamAPI_SteamNetworkingSockets_v009();
void SteamAPI_SteamNetworkingUtils_v003();
void SteamNetworkingIPAddr_GetFakeIPType();
void SteamNetworkingIPAddr_ParseString();
void SteamNetworkingIPAddr_ToString();
void SteamNetworkingIdentity_ParseString();
void SteamNetworkingIdentity_ToString();
void SteamNetworkingMessages_LibV2();
void SteamNetworkingSockets_DefaultPreFormatDebugOutputHandler();
void SteamNetworkingSockets_LibV12();
void SteamNetworkingSockets_Poll();
void SteamNetworkingSockets_SetLockAcquiredCallback();
void SteamNetworkingSockets_SetLockHeldCallback();
void SteamNetworkingSockets_SetLockWaitWarningThreshold();
void SteamNetworkingSockets_SetManualPollMode();
void SteamNetworkingSockets_SetPreFormatDebugOutputHandler();
void SteamNetworkingUtils_LibV4();
