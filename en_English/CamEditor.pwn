/*
*                                                                                             
*      ______                ______    ___ __            
*     / ____/___ _____ ___  / ____/___/ (_) /_____  _____
*    / /   / __ `/ __ `__ \/ __/ / __  / / __/ __ \/ ___/
*   / /___/ /_/ / / / / / / /___/ /_/ / / /_/ /_/ / /    
*   \____/\__,_/_/ /_/ /_/_____/\__,_/_/\__/\____/_/     
*
*                     - CamEditor by Drebin
*                     - Updated to open.mp by itsneufox
*/

//==========================================================================
//
//==========================================================================

#define             FILTERSCRIPT

#include            <open.mp>

#define             MOVE_SPEED              100.0
#define             ACCEL_RATE              0.03

#define             CAMERA_MODE_NONE        0
#define             CAMERA_MODE_FLY         1
 
#define             MOVE_FWD                1
#define             MOVE_BACK               2
#define             MOVE_LEFT               3
#define             MOVE_RIGHT              4
#define             MOVE_FWD_L              5
#define             MOVE_FWD_R              6
#define             MOVE_BACK_L             7
#define             MOVE_BACK_R             8

#define             DIALOG_MENU             1678
#define             DIALOG_MOVE_SPEED       1679
#define             DIALOG_ROT_SPEED        1680
#define             DIALOG_EXPORTNAME       1681
#define             DIALOG_CLOSE_NEW        1682
 
const 
    Float:fScale = 5.0
;

new 
    MenuTimer
;

new Float:fPX, 
    Float:fPY,
    Float:fPZ,
    Float:fVX,
    Float:fVY,
    Float:fVZ,
    Float:object_x,
    Float:object_y,
    Float:object_z
;

new 
    bool:IsCreating[MAX_PLAYERS]        = false,
    bool:IsReSettingStart[MAX_PLAYERS]  = false,
    bool:IsReSettingEnd[MAX_PLAYERS]    = false,
    bool:SettingFirstLoc[MAX_PLAYERS]   = false,
    bool:SettingLastLoc[MAX_PLAYERS]    = false,
    bool:IsCamMoving[MAX_PLAYERS]       = false
;
 
enum noclipenum
{
    cameramode,
    flyobject,
    mode,
    lrold,
    udold,
    lastmove,
    Float:accelmul
}

new 
    noclipdata[MAX_PLAYERS][noclipenum]
;
 
enum Coordinates
{
    Float:StartX,
    Float:StartY,
    Float:StartZ,
    Float:EndX,
    Float:EndY,
    Float:EndZ,
    Float:StartLookX,
    Float:StartLookY,
    Float:StartLookZ,
    Float:EndLookX,
    Float:EndLookY,
    Float:EndLookZ,
    MoveSpeed,
    RotSpeed
}

new 
    coordInfo[MAX_PLAYERS][Coordinates]
;

//==========================================================================
//
//==========================================================================
 
#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
    print(" ");
    print("--------------------------------------");
    print(" CamEditor created by Drebin");
    print(" Updated to open.mp by itsneufox");
    print("--------------------------------------");
    print(" ");

    return true;
}
 
public OnFilterScriptExit()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (noclipdata[i][cameramode] == CAMERA_MODE_FLY) 
            CancelFlyMode(i);
    }

    return true;
}

#endif
 
public OnPlayerConnect(playerid)
{
    noclipdata[playerid][cameramode]    = CAMERA_MODE_NONE;
    noclipdata[playerid][lrold]         = 0;
    noclipdata[playerid][udold]         = 0;
    noclipdata[playerid][mode]          = 0;
    noclipdata[playerid][lastmove]      = 0;
    noclipdata[playerid][accelmul]      = 0.0;
    IsCreating[playerid]                = false;
    IsReSettingStart[playerid]          = false;
    IsReSettingEnd[playerid]            = false;
    SettingFirstLoc[playerid]           = false;
    SettingLastLoc[playerid]            = false;
    IsCamMoving[playerid]               = false;
    coordInfo[playerid][MoveSpeed]      = 1000;
    coordInfo[playerid][RotSpeed]       = 1000;

    return true;
}
 
public OnPlayerSpawn(playerid)
{
    if (IsCreating[playerid] == false)
    {
        SendClientMessage(playerid, -1, "{FFFFFF}Type {8EFF8E}/cameditor{FFFFFF} to access the camera editor");
    }

    return true;
}
 
public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/cameditor", true))
    {
        if (IsCamMoving[playerid] == false)
        {
            if (GetPVarType(playerid, "FlyMode"))
            {
                CancelFlyMode(playerid);
                IsCreating[playerid] = false;
            }
            else 
            {
                FlyMode(playerid);
            }
        }

        return true;
    }

    if (!strcmp(cmdtext, "/closecameditor", true))
    {
        if (IsCreating[playerid])
        {
            CancelFlyMode(playerid);
            IsCreating[playerid] = false;
            noclipdata[playerid][cameramode]    = CAMERA_MODE_NONE;
            noclipdata[playerid][lrold]         = 0;
            noclipdata[playerid][udold]         = 0;
            noclipdata[playerid][mode]          = 0;
            noclipdata[playerid][lastmove]      = 0;
            noclipdata[playerid][accelmul]      = 0.0;
            IsCreating[playerid]                = false;
            IsReSettingStart[playerid]          = false;
            IsReSettingEnd[playerid]            = false;
            SettingFirstLoc[playerid]           = false;
            SettingLastLoc[playerid]            = false;
            IsCamMoving[playerid]               = false;
            coordInfo[playerid][MoveSpeed]      = 1000;
            coordInfo[playerid][RotSpeed]       = 1000;
            SendClientMessage(playerid, -1, "{8EFF8E}Camera Editor{FFFFFF} has been closed");
        }
        else 
        {
            SendClientMessage(playerid, -1, "{F58282}Error: {FFFFFF}The Camera Editor is not currently active");
            SendClientMessage(playerid, -1, "{FFFFFF}Use {8EFF8E}/cameditor{FFFFFF} to start the editor");
        }

        return true;
    }

    return false;
}

public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
    if ((newkeys & KEY_FIRE) && !(oldkeys & KEY_FIRE))
    {
        if (IsCreating[playerid] == true)
        {
            if (SettingFirstLoc[playerid] == true)
            {
                GetPlayerCameraPos(playerid, fPX, fPY, fPZ);
                GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);
                object_x = fPX + floatmul(fVX, fScale);
                object_y = fPY + floatmul(fVY, fScale);
                object_z = fPZ + floatmul(fVZ, fScale);
                coordInfo[playerid][StartX]         = fPX;
                coordInfo[playerid][StartY]         = fPY;
                coordInfo[playerid][StartZ]         = fPZ;
                coordInfo[playerid][StartLookX]     = object_x;
                coordInfo[playerid][StartLookY]     = object_y;
                coordInfo[playerid][StartLookZ]     = object_z;

                if (IsReSettingStart[playerid] == true)
                {
                    SendClientMessage(playerid, -1, "{8EFF8E}>{FFFFFF} Start point has been {8EFF8E}successfully re-set");
                    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"Camera Editor - Next Step?","Preview Camera Movement\nModify Start Point\nModify End Point\nAdjust Speed Settings\nSave to File","{8EFF8E}Confirm","{F58282}Cancel");
                    IsReSettingStart[playerid]      = false;
                    IsReSettingEnd[playerid]        = false;
                    SettingFirstLoc[playerid]       = false;
                    SettingLastLoc[playerid]        = false;
                }
                else
                {
                    SendClientMessage(playerid, -1, "{8EFF8E}Start point{FFFFFF} saved successfully");
                    SendClientMessage(playerid, -1, "{FFFFFF}Now press {F58282}~k~~PED_FIREWEAPON~{FFFFFF} to define the {8EFF8E}end point{FFFFFF}");
                    SettingLastLoc[playerid] = true;
                    SettingFirstLoc[playerid] = false;
                }
            }

            else if (SettingLastLoc[playerid] == true)
            {
                new 
                    string[512]
                ;

                format(string, sizeof(string), "Please enter the desired {F58282}movement{FFFFFF} duration in milliseconds\n\nCurrent movement speed: \t{F58282}%i milliseconds\n{FFFFFF}Current rotation speed: \t{F58282}%i milliseconds\n\n\n{CFCFCF}Note: {FFFFFF}1 second = 1000 milliseconds", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "Movement Duration Settings", string,"{8EFF8E}Confirm","{F58282}Cancel");
                GetPlayerCameraPos(playerid, fPX, fPY, fPZ);
                GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);

                object_x = fPX + floatmul(fVX, fScale);
                object_y = fPY + floatmul(fVY, fScale);
                object_z = fPZ + floatmul(fVZ, fScale);

                coordInfo[playerid][EndX]           = fPX;
                coordInfo[playerid][EndY]           = fPY;
                coordInfo[playerid][EndZ]           = fPZ;
                coordInfo[playerid][EndLookX]       = object_x;
                coordInfo[playerid][EndLookY]       = object_y;
                coordInfo[playerid][EndLookZ]       = object_z;

                if (IsReSettingEnd[playerid] == true)
                {
                    SendClientMessage(playerid, -1, "{8EFF8E}>{FFFFFF} end point has been {8EFF8E}successfully re-set");
                    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"Camera Editor - Next Step?","Preview\nChange Start\nChange End\nChange Speed\nSave","{8EFF8E}Confirm","{F58282}Cancel");

                    IsReSettingStart[playerid]      = false;
                    IsReSettingEnd[playerid]        = false;
                    SettingFirstLoc[playerid]       = false;
                    SettingLastLoc[playerid]        = false;
                }
                else
                {
                    SendClientMessage(playerid, -1, "{8EFF8E}End point{FFFFFF} saved successfully");

                    SettingLastLoc[playerid] = false;
                }
            }
        }
    }

    return true;
}
 
public OnPlayerUpdate(playerid)
{
    if (noclipdata[playerid][cameramode] == CAMERA_MODE_FLY)
    {
        new 
            KEY:keys, updown, leftright
        ;

        GetPlayerKeys(playerid,keys,updown,leftright);
 
        if (noclipdata[playerid][mode] && (GetTickCount() - noclipdata[playerid][lastmove] > 100))
        {
            MoveCamera(playerid);
        }
        if (noclipdata[playerid][udold] != updown || noclipdata[playerid][lrold] != leftright)
        {
            if ((noclipdata[playerid][udold] != 0 || noclipdata[playerid][lrold] != 0) && updown == 0 && leftright == 0)
            {
                StopPlayerObject(playerid, noclipdata[playerid][flyobject]);

                noclipdata[playerid][mode]      = 0;
                noclipdata[playerid][accelmul]  = 0.0;
            }
            else
            {
                noclipdata[playerid][mode] = GetMoveDirectionFromKeys(updown, leftright);
                MoveCamera(playerid);
            }
        }

        noclipdata[playerid][udold] = updown; noclipdata[playerid][lrold] = leftright;

        return false;
    }

    return true;
}
 
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_MENU:
        {
            if (response)
            {
                switch(listitem)
                {
                    case 0: //Preview
                    {
                        PreviewMovement(playerid);
                    }
                    case 1: //Change start
                    {
                        DestroyPlayerObject(playerid, noclipdata[playerid][flyobject]);

                        IsReSettingEnd[playerid]    = false;
                        SettingLastLoc[playerid]    = false;
                        IsReSettingStart[playerid] = true;
                        SettingFirstLoc[playerid]  = true;
                        noclipdata[playerid][flyobject] = CreatePlayerObject(playerid, 19300, coordInfo[playerid][StartX], coordInfo[playerid][StartY], coordInfo[playerid][StartZ], 0.0, 0.0, 0.0);

                        TogglePlayerSpectating(playerid, true);
                        AttachCameraToPlayerObject(playerid, noclipdata[playerid][flyobject]);
                        SetPVarInt(playerid, "FlyMode", 1);

                        noclipdata[playerid][cameramode] = CAMERA_MODE_FLY;

                        SendClientMessage(playerid, -1, "{FFFFFF}Press {F58282}~k~~PED_FIREWEAPON~ {FFFFFF}to set your new {F58282}start {FFFFFF}point");
                    }
                    case 2: //Change end
                    {
                        DestroyPlayerObject(playerid, noclipdata[playerid][flyobject]);

                        IsReSettingStart[playerid]  = false;
                        SettingFirstLoc[playerid]   = false;
                        IsReSettingEnd[playerid] = true;
                        SettingLastLoc[playerid] = true;
                        IsCreating[playerid]     = true;

                        SetCameraBehindPlayer(playerid);

                        noclipdata[playerid][flyobject] = CreatePlayerObject(playerid, 19300, coordInfo[playerid][EndX], coordInfo[playerid][EndY], coordInfo[playerid][EndZ], 0.0, 0.0, 0.0);

                        TogglePlayerSpectating(playerid, true);
                        AttachCameraToPlayerObject(playerid, noclipdata[playerid][flyobject]);
                        SetPVarInt(playerid, "FlyMode", 1);

                        noclipdata[playerid][cameramode] = CAMERA_MODE_FLY;

                        SendClientMessage(playerid, -1, " {FFFFFF}Press {F58282}~k~~PED_FIREWEAPON~ {FFFFFF}to set your new {F58282}end {FFFFFF}point");
                    }
                    case 3: //Change speed
                    {
                        new 
                            string[512]
                        ;
                        format(string, sizeof(string), "{FFFFFF}Please enter the desired {F58282}camera movement{FFFFFF} duration in milliseconds\n\nCurrent movement speed: \t{F58282}%i milliseconds\n{FFFFFF}Current rotation speed: \t{F58282}%i milliseconds\n\n\n{F58282}Note: {FFFFFF}1 second = 1000 milliseconds", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                        ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "Movement Speed", string,"{8EFF8E}Confirm","{F58282}Cancel");
                    }
                    case 4: //Export
                    {
                        ShowPlayerDialog(playerid, DIALOG_EXPORTNAME, DIALOG_STYLE_INPUT, "Save Camera Movement","Enter a descriptive name for this camera movement","{8EFF8E}Save","{FFCC00}Back");
                    }
                }
            }
            else
            {
                CancelFlyMode(playerid);
                SendClientMessage(playerid, -1, "{F58282}You exited the camera movement editor.");

                IsCreating[playerid] = false;
            }
        }
        case DIALOG_MOVE_SPEED:
        {
            if (response)
            {
                if (strlen(inputtext))
                {
                    if (IsNumeric(inputtext))
                    {
                        coordInfo[playerid][MoveSpeed] = strval(inputtext);

                        new 
                            string[512]
                        ;

                        format(string, sizeof(string), "{FFFFFF}Please enter the desired {F58282}rotation{FFFFFF} duration in milliseconds\n\nCurrent movement speed: \t{F58282}%i milliseconds\n{FFFFFF}Current rotation speed: \t{F58282}%i milliseconds\n\n\n{F58282}Note: {FFFFFF}1 second = 1000 milliseconds", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                        ShowPlayerDialog(playerid, DIALOG_ROT_SPEED, DIALOG_STYLE_INPUT, "Rotation Speed", string,"{8EFF8E}Confirm","{F58282}Cancel");
                        
                        IsReSettingStart[playerid] = false;
                        IsReSettingEnd[playerid]   = false;
                    }
                    else
                    {
                        new
                            string[512]
                        ;

                        format(string, sizeof(string), "{FFFFFF}Please enter the desired {F58282}movement{FFFFFF} duration in milliseconds\n\nCurrent movement speed: \t{F58282}%i milliseconds\n{FFFFFF}Current rotation speed: \t{F58282}%i milliseconds\n{FF0000}NUMBERS ONLY\n\n{F58282}Note: {FFFFFF}1 second = 1000 milliseconds", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                        ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "Movement Speed", string,"{8EFF8E}Confirm","{F58282}Cancel");
                    }
                }
                else
                {
                    new 
                        string[512]
                    ;

                    format(string, sizeof(string), "{FFFFFF}Please enter the desired {F58282}movement{FFFFFF} time in milliseconds\n\nCurrent movement speed: \t{F58282}%i milliseconds\n{FFFFFF}Current rotation speed: \t{F58282}%i milliseconds\n{FF0000}You need to enter a value\n\n{F58282}Note: {FFFFFF}1 second = 1000 milliseconds", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                    ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "Movement Speed", string,"{8EFF8E}Confirm","{F58282}Cancel");
                }
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"Camera Editor - Next Step?","Preview\nChange Start\nChange End\nChange Speed\nSave","{8EFF8E}Confirm","{F58282}Cancel");
            }
        }
        case DIALOG_ROT_SPEED:
        {
            if (response)
            {
                if (strlen(inputtext))
                {
                    if (IsNumeric(inputtext))
                    {
                        coordInfo[playerid][RotSpeed] = strval(inputtext);

                        ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"Camera Editor - Next Step?","Preview\nChange Start\nChange End\nChange Speed\nSave","{8EFF8E}Confirm","{F58282}Cancel");

                        IsReSettingStart[playerid] = false;
                        IsReSettingEnd[playerid]   = false;
                    }
                    else
                    {
                        new 
                            string[512]
                        ;

                        format(string, sizeof(string), "{FFFFFF}Please enter the desired {F58282}rotation{FFFFFF} time in milliseconds\n\nCurrent movement speed: \t{F58282}%i milliseconds\n{FFFFFF}Current rotation speed: \t{F58282}%i milliseconds\n{FF0000}NUMBERS ONLY!\n\n{F58282}Note: {FFFFFF}1 second = 1000 milliseconds", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                        ShowPlayerDialog(playerid, DIALOG_ROT_SPEED, DIALOG_STYLE_INPUT, "Rotation Speed", string,"{8EFF8E}Confirm","{F58282}Cancel");
                    }
                }
                else
                {
                    new 
                        string[512]
                    ;
                    
                    format(string, sizeof(string), "{FFFFFF}Please enter the desired {F58282}rotation{FFFFFF} time in milliseconds\n\nCurrent movement speed: \t{F58282}%i milliseconds\n{FFFFFF}Current rotation speed: \t{F58282}%i milliseconds\n{FF0000}You need to enter a value\n\n{F58282}Note: {FFFFFF}1 second = 1000 milliseconds", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                    ShowPlayerDialog(playerid, DIALOG_ROT_SPEED, DIALOG_STYLE_INPUT, "Rotation Speed", string,"{8EFF8E}Confirm","{F58282}Cancel");
                }
            }
            else
            {
                new 
                    string[512]
                ;

                format(string, sizeof(string), "{FFFFFF}Please enter the desired {F58282}movement{FFFFFF} time in milliseconds\n\nCurrent movement speed: \t{F58282}%i milliseconds\n{FFFFFF}Current rotation speed: \t{F58282}%i milliseconds\n\n\n{F58282}Note: {FFFFFF}1 second = 1000 milliseconds", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "Movement Speed",string,"{8EFF8E}Confirm","{F58282}Cancel");
            }
        }
        case DIALOG_EXPORTNAME:
        {
            if (response)
            {
                if (strlen(inputtext))
                {
                    ExportMovement(playerid, inputtext);
                }
                else
                {
                    ShowPlayerDialog(playerid, DIALOG_EXPORTNAME, DIALOG_STYLE_INPUT, "Save movement","{FFFFFF}Enter a name for this camera movement\n{F58282}You need to enter text","{8EFF8E}Confirm","{F58282}Cancel");
                }
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"Camera Editor - Next Step?","Preview\nChange Start\nChange End\nChange Speed\nSave","{8EFF8E}Confirm","{F58282}Cancel");
            }
        }
        case DIALOG_CLOSE_NEW:
        {
            if (response)
            {
                IsCreating[playerid]      = true;
                SettingFirstLoc[playerid] = true;

                FlyMode(playerid);
            }
            else
            {
                SendClientMessage(playerid, -1, "{8EFF8E}Camera Editor{FFFFFF} has been closed");
                CancelFlyMode(playerid);

                IsCreating[playerid] = false;
            }
        }
    }
    return true;
}
 
forward ShowPlayerMenu(playerid);
public ShowPlayerMenu(playerid)
{
    KillTimer(MenuTimer);

    IsCamMoving[playerid] = false;

    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"Camera Editor - Next Step?","Preview\nChange Start\nChange End\nChange Speed\nSave","{8EFF8E}Confirm","{F58282}Cancel");

    return true;
}
 
forward PreviewMovement(playerid);
public PreviewMovement(playerid)
{
    IsCamMoving[playerid] = true;

    DestroyObject(noclipdata[playerid][flyobject]);
    SetCameraBehindPlayer(playerid);

    if (coordInfo[playerid][MoveSpeed] > coordInfo[playerid][RotSpeed])
    {
        MenuTimer = SetTimerEx("ShowPlayerMenu", coordInfo[playerid][MoveSpeed], false, "i", playerid);
    }
    else
    {
        MenuTimer = SetTimerEx("ShowPlayerMenu", coordInfo[playerid][RotSpeed], false, "i", playerid);

        InterpolateCameraPos(playerid, coordInfo[playerid][StartX], coordInfo[playerid][StartY], coordInfo[playerid][StartZ], coordInfo[playerid][EndX], coordInfo[playerid][EndY], coordInfo[playerid][EndZ],coordInfo[playerid][MoveSpeed]);
        InterpolateCameraLookAt(playerid, coordInfo[playerid][StartLookX],coordInfo[playerid][StartLookY],coordInfo[playerid][StartLookZ],coordInfo[playerid][EndLookX],coordInfo[playerid][EndLookY],coordInfo[playerid][EndLookZ],coordInfo[playerid][RotSpeed]);
    }

    return true;
}
 
forward ExportMovement(playerid, inputtext[]);
public ExportMovement(playerid, inputtext[])
{
    new 
        tagstring[64],
        movestring[512],
        rotstring[512],
        filename[50]
    ;

    format(filename, 128, "CamEdit_%s.txt", inputtext);
    format(tagstring, sizeof(tagstring), "|----------%s----------|\r\n", inputtext);
    format(movestring, sizeof(movestring),"InterpolateCameraPos(playerid, %f, %f, %f, %f, %f, %f, %i);\r\n",coordInfo[playerid][StartX], coordInfo[playerid][StartY], coordInfo[playerid][StartZ], coordInfo[playerid][EndX], coordInfo[playerid][EndY], coordInfo[playerid][EndZ],coordInfo[playerid][MoveSpeed]);
    format(rotstring,sizeof(rotstring),"InterpolateCameraLookAt(playerid, %f, %f, %f, %f, %f, %f, %i);",coordInfo[playerid][StartLookX],coordInfo[playerid][StartLookY],coordInfo[playerid][StartLookZ],coordInfo[playerid][EndLookX],coordInfo[playerid][EndLookY],coordInfo[playerid][EndLookZ],coordInfo[playerid][RotSpeed]);
    
    new
        File:File = fopen(filename, io_write)
    ;

    fwrite(File, tagstring);
    fwrite(File, movestring);
    fwrite(File, rotstring);
    fclose(File);
    
    new
        myOutpString[256]
    ;

    format(myOutpString, sizeof(myOutpString), "{FFFFFF}Camera movement saved as {F58282}%s{FFFFFF} in the scriptfiles folder!\n\nWhat would you like to do next?", filename);
    ShowPlayerDialog(playerid, DIALOG_CLOSE_NEW, DIALOG_STYLE_MSGBOX,"What next?",myOutpString,"{8EFF8E}Create New","{F58282}Exit Editor");
}
 
stock GetMoveDirectionFromKeys(updown, leftright)
{
    new 
        direction = 0
    ;
 
    if (leftright < 0)
    {
        if (updown < 0)
        {      
            direction = MOVE_FWD_L;
        }
        else if (updown > 0) 
        {
            direction = MOVE_BACK_L;
        }
        else
        {
            direction = MOVE_LEFT;
        }
    }
    else if (leftright > 0)
    {
        if (updown < 0)
        {      
            direction = MOVE_FWD_R;
        }
        else if (updown > 0) 
        {
            direction = MOVE_BACK_R;
        }
        else
        {
            direction = MOVE_RIGHT;
        }
    }
    else if (updown < 0)
    {
        direction = MOVE_FWD;
    }     
    else if (updown > 0)
    {
        direction = MOVE_BACK;
    }
 
    return direction;
}
 
stock MoveCamera(playerid)
{
    new 
        Float:FV[3],
        Float:CP[3]
    ;

    GetPlayerCameraPos(playerid, CP[0], CP[1], CP[2]);
    GetPlayerCameraFrontVector(playerid, FV[0], FV[1], FV[2]);

    if (noclipdata[playerid][accelmul] <= 1) 
    {
        noclipdata[playerid][accelmul] += ACCEL_RATE;
    }

    new 
        Float:speed = MOVE_SPEED * noclipdata[playerid][accelmul],
        Float:X,
        Float:Y,
        Float:Z
    ;

    GetNextCameraPosition(noclipdata[playerid][mode], CP, FV, X, Y, Z);
    MovePlayerObject(playerid, noclipdata[playerid][flyobject], X, Y, Z, speed);
    noclipdata[playerid][lastmove] = GetTickCount();

    return true;
}
 
stock GetNextCameraPosition(move_mode, const Float:CP[3], const Float:FV[3], &Float:X, &Float:Y, &Float:Z)
{
    #define OFFSET_X (FV[0]*6000.0)
    #define OFFSET_Y (FV[1]*6000.0)
    #define OFFSET_Z (FV[2]*6000.0)

    switch(move_mode)
    {
        case MOVE_FWD:
        {
            X = CP[0]+OFFSET_X;
            Y = CP[1]+OFFSET_Y;
            Z = CP[2]+OFFSET_Z;
        }
        case MOVE_BACK:
        {
            X = CP[0]-OFFSET_X;
            Y = CP[1]-OFFSET_Y;
            Z = CP[2]-OFFSET_Z;
        }
        case MOVE_LEFT:
        {
            X = CP[0]-OFFSET_Y;
            Y = CP[1]+OFFSET_X;
            Z = CP[2];
        }
        case MOVE_RIGHT:
        {
            X = CP[0]+OFFSET_Y;
            Y = CP[1]-OFFSET_X;
            Z = CP[2];
        }
        case MOVE_BACK_L:
        {
            X = CP[0]+(-OFFSET_X - OFFSET_Y);
            Y = CP[1]+(-OFFSET_Y + OFFSET_X);
            Z = CP[2]-OFFSET_Z;
        }
        case MOVE_BACK_R:
        {
            X = CP[0]+(-OFFSET_X + OFFSET_Y);
            Y = CP[1]+(-OFFSET_Y - OFFSET_X);
            Z = CP[2]-OFFSET_Z;
        }
        case MOVE_FWD_L:
        {
            X = CP[0]+(OFFSET_X  - OFFSET_Y);
            Y = CP[1]+(OFFSET_Y  + OFFSET_X);
            Z = CP[2]+OFFSET_Z;
        }
        case MOVE_FWD_R:
        {
            X = CP[0]+(OFFSET_X  + OFFSET_Y);
            Y = CP[1]+(OFFSET_Y  - OFFSET_X);
            Z = CP[2]+OFFSET_Z;
        }
    }
}
 
stock CancelFlyMode(playerid)
{
    DeletePVar(playerid, "FlyMode");
    CancelEdit(playerid);
    TogglePlayerSpectating(playerid, false);
    DestroyPlayerObject(playerid, noclipdata[playerid][flyobject]);

    noclipdata[playerid][cameramode] = CAMERA_MODE_NONE;
    IsReSettingStart[playerid]  = false;
    IsReSettingEnd[playerid]    = false;
    SettingFirstLoc[playerid]   = false;
    SettingLastLoc[playerid]    = false;

    return true;
}
 
stock FlyMode(playerid)
{
    new 
        Float:X,
        Float:Y,
        Float:Z
    ;

    IsCreating[playerid] = true;
    SettingFirstLoc[playerid] = true;

    GetPlayerPos(playerid, X, Y, Z);

    noclipdata[playerid][flyobject] = CreatePlayerObject(playerid, 19300, X, Y, Z, 0.0, 0.0, 0.0);

    TogglePlayerSpectating(playerid, true);
    AttachCameraToPlayerObject(playerid, noclipdata[playerid][flyobject]);
 
    SetPVarInt(playerid, "FlyMode", 1);
    noclipdata[playerid][cameramode] = CAMERA_MODE_FLY;

    SendClientMessage(playerid, -1, "{8EFF8E}Camera Editor{FFFFFF} has been activated successfully");
    SendClientMessage(playerid, -1, "{FFFFFF}Use {F58282}~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~ and ~k~~GO_RIGHT~{FFFFFF} to navigate in 3D space");
    SendClientMessage(playerid, -1, "{FFFFFF}Press {F58282}~k~~PED_FIREWEAPON~{FFFFFF} to set the {8EFF8E}start point{FFFFFF}");
    SendClientMessage(playerid, -1, "{FFFFFF}Type {F58282}/closecameditor{FFFFFF} to exit the editor");

    return true;
}
 
IsNumeric(const szInput[]) 
{
    new 
        iChar, i = 0
    ;
    
    while ((iChar = szInput[i++])) 
    {
        if (!('0' <= iChar <= '9')) 
        {
            return false;
        }
    }

    return true;
}