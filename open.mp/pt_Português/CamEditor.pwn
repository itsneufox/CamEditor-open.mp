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
    print(" CamEditor criado por Drebin");
    print(" Atualizado para open.mp por itsneufox");
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
        SendClientMessage(playerid, -1, "{FFFFFF}Digite {8EFF8E}/editorcamera{FFFFFF} para acessar o editor de câmera");
    }

    return true;
}
 
public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/editorcamera", true))
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

    if (!strcmp(cmdtext, "/fechareditorcamera", true))
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
            SendClientMessage(playerid, -1, "{8EFF8E}Editor de Câmera{FFFFFF} foi fechado");
        }
        else 
        {
            SendClientMessage(playerid, -1, "{F58282}Erro: {FFFFFF}O Editor de Câmera não está ativo no momento");
            SendClientMessage(playerid, -1, "{FFFFFF}Use {8EFF8E}/editorcamera{FFFFFF} para iniciar o editor");
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
                    SendClientMessage(playerid, -1, "{8EFF8E}>{FFFFFF} Ponto inicial foi {8EFF8E}redefinido com sucesso");
                    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"{FFFFFF}Editor de Câmera - Próximo Passo?","{FFFFFF}Visualizar Movimento da Câmera\nModificar Ponto Inicial\nModificar Ponto Final\nAjustar Velocidades\nSalvar em Arquivo","{8EFF8E}Confirmar","{F58282}Cancelar");
                    IsReSettingStart[playerid]      = false;
                    IsReSettingEnd[playerid]        = false;
                    SettingFirstLoc[playerid]       = false;
                    SettingLastLoc[playerid]        = false;
                }
                else
                {
                    SendClientMessage(playerid, -1, "{8EFF8E}Ponto inicial{FFFFFF} salvo com sucesso");
                    SendClientMessage(playerid, -1, "{FFFFFF}Agora pressione {F58282}~k~~PED_FIREWEAPON~{FFFFFF} para definir o {8EFF8E}ponto final{FFFFFF}");
                    SettingLastLoc[playerid] = true;
                    SettingFirstLoc[playerid] = false;
                }
            }

            else if (SettingLastLoc[playerid] == true)
            {
                new 
                    string[512]
                ;

                format(string, sizeof(string), "{FFFFFF}Por favor, insira a duração desejada para o {F58282}movimento{FFFFFF} em milissegundos\n\nVelocidade atual do movimento: \t{F58282}%i milissegundos\n{FFFFFF}Velocidade atual da rotação: \t{F58282}%i milissegundos\n\n\n{CFCFCF}Nota: {FFFFFF}1 segundo = 1000 milissegundos", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "{FFFFFF}Configurações de Duração do Movimento", string,"{8EFF8E}Confirmar","{F58282}Cancelar");
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
                    SendClientMessage(playerid, -1, "{8EFF8E}>{FFFFFF} Ponto final foi {8EFF8E}redefinido com sucesso");
                    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"{FFFFFF}Editor de Câmera - Próximo Passo?","{FFFFFF}Visualizar\nAlterar Início\nAlterar Fim\nAlterar Velocidade\nSalvar","{8EFF8E}Confirmar","{F58282}Cancelar");

                    IsReSettingStart[playerid]      = false;
                    IsReSettingEnd[playerid]        = false;
                    SettingFirstLoc[playerid]       = false;
                    SettingLastLoc[playerid]        = false;
                }
                else
                {
                    SendClientMessage(playerid, -1, "{8EFF8E}Ponto final{FFFFFF} salvo com sucesso");

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
                    case 0: //Visualizar
                    {
                        PreviewMovement(playerid);
                    }
                    case 1: //Alterar início
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

                        SendClientMessage(playerid, -1, "{FFFFFF}Pressione {F58282}~k~~PED_FIREWEAPON~ {FFFFFF}para definir o novo {F58282}ponto inicial{FFFFFF}");
                    }
                    case 2: //Alterar fim
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

                        SendClientMessage(playerid, -1, " {FFFFFF}Pressione {F58282}~k~~PED_FIREWEAPON~ {FFFFFF}para definir o novo {F58282}ponto final{FFFFFF}");
                    }
                    case 3: //Alterar velocidade
                    {
                        new 
                            string[512]
                        ;
                        format(string, sizeof(string), "{FFFFFF}Por favor, insira a duração desejada para o {F58282}movimento da câmera{FFFFFF} em milissegundos\n\nVelocidade atual do movimento: \t{F58282}%i milissegundos\n{FFFFFF}Velocidade atual da rotação: \t{F58282}%i milissegundos\n\n\n{F58282}Nota: {FFFFFF}1 segundo = 1000 milissegundos", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                        ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "{FFFFFF}Velocidade do Movimento", string,"{8EFF8E}Confirmar","{F58282}Cancelar");
                    }
                    case 4: //Exportar
                    {
                        ShowPlayerDialog(playerid, DIALOG_EXPORTNAME, DIALOG_STYLE_INPUT, "{FFFFFF}Salvar Movimento da Câmera","{FFFFFF}Digite um nome descritivo para este movimento de câmera","{8EFF8E}Salvar","{FFCC00}Voltar");
                    }
                }
            }
            else
            {
                CancelFlyMode(playerid);
                SendClientMessage(playerid, -1, "{F58282}Você saiu do editor de movimento de câmera.");

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

                        format(string, sizeof(string), "{FFFFFF}Por favor, insira a duração desejada para a {F58282}rotação{FFFFFF} em milissegundos\n\nVelocidade atual do movimento: \t{F58282}%i milissegundos\n{FFFFFF}Velocidade atual da rotação: \t{F58282}%i milissegundos\n\n\n{F58282}Nota: {FFFFFF}1 segundo = 1000 milissegundos", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                        ShowPlayerDialog(playerid, DIALOG_ROT_SPEED, DIALOG_STYLE_INPUT, "{FFFFFF}Velocidade da Rotação", string,"{8EFF8E}Confirmar","{F58282}Cancelar");
                        
                        IsReSettingStart[playerid] = false;
                        IsReSettingEnd[playerid]   = false;
                    }
                    else
                    {
                        new
                            string[512]
                        ;

                        format(string, sizeof(string), "{FFFFFF}Por favor, insira a duração desejada para o {F58282}movimento{FFFFFF} em milissegundos\n\nVelocidade atual do movimento: \t{F58282}%i milissegundos\n{FFFFFF}Velocidade atual da rotação: \t{F58282}%i milissegundos\n{FF0000}SOMENTE NÚMEROS\n\n{F58282}Nota: {FFFFFF}1 segundo = 1000 milissegundos", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                        ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "{FFFFFF}Velocidade do Movimento", string,"{8EFF8E}Confirmar","{F58282}Cancelar");
                    }
                }
                else
                {
                    new 
                        string[512]
                    ;

                    format(string, sizeof(string), "{FFFFFF}Por favor, insira a duração desejada para o {F58282}movimento{FFFFFF} em milissegundos\n\nVelocidade atual do movimento: \t{F58282}%i milissegundos\n{FFFFFF}Velocidade atual da rotação: \t{F58282}%i milissegundos\n{FF0000}Você precisa inserir um valor\n\n{F58282}Nota: {FFFFFF}1 segundo = 1000 milissegundos", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                    ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "{FFFFFF}Velocidade do Movimento", string,"{8EFF8E}Confirmar","{F58282}Cancelar");
                }
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"{FFFFFF}Editor de Câmera - Próximo Passo?","{FFFFFF}Visualizar\nAlterar Início\nAlterar Fim\nAlterar Velocidade\nSalvar","{8EFF8E}Confirmar","{F58282}Cancelar");
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

                        ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"{FFFFFF}Editor de Câmera - Próximo Passo?","{FFFFFF}Visualizar\nAlterar Início\nAlterar Fim\nAlterar Velocidade\nSalvar","{8EFF8E}Confirmar","{F58282}Cancelar");

                        IsReSettingStart[playerid] = false;
                        IsReSettingEnd[playerid]   = false;
                    }
                    else
                    {
                        new 
                            string[512]
                        ;

                        format(string, sizeof(string), "{FFFFFF}Por favor, insira a duração desejada para a {F58282}rotação{FFFFFF} em milissegundos\n\nVelocidade atual do movimento: \t{F58282}%i milissegundos\n{FFFFFF}Velocidade atual da rotação: \t{F58282}%i milissegundos\n{FF0000}SOMENTE NÚMEROS!\n\n{F58282}Nota: {FFFFFF}1 segundo = 1000 milissegundos", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                        ShowPlayerDialog(playerid, DIALOG_ROT_SPEED, DIALOG_STYLE_INPUT, "{FFFFFF}Velocidade da Rotação", string,"{8EFF8E}Confirmar","{F58282}Cancelar");
                    }
                }
                else
                {
                    new 
                        string[512]
                    ;
                    
                    format(string, sizeof(string), "{FFFFFF}Por favor, insira a duração desejada para a {F58282}rotação{FFFFFF} em milissegundos\n\nVelocidade atual do movimento: \t{F58282}%i milissegundos\n{FFFFFF}Velocidade atual da rotação: \t{F58282}%i milissegundos\n{FF0000}Você precisa inserir um valor\n\n{F58282}Nota: {FFFFFF}1 segundo = 1000 milissegundos", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                    ShowPlayerDialog(playerid, DIALOG_ROT_SPEED, DIALOG_STYLE_INPUT, "{FFFFFF}Velocidade da Rotação", string,"{8EFF8E}Confirmar","{F58282}Cancelar");
                }
            }
            else
            {
                new 
                    string[512]
                ;

                format(string, sizeof(string), "{FFFFFF}Por favor, insira a duração desejada para o {F58282}movimento{FFFFFF} em milissegundos\n\nVelocidade atual do movimento: \t{F58282}%i milissegundos\n{FFFFFF}Velocidade atual da rotação: \t{F58282}%i milissegundos\n\n\n{F58282}Nota: {FFFFFF}1 segundo = 1000 milissegundos", coordInfo[playerid][MoveSpeed], coordInfo[playerid][RotSpeed]);
                ShowPlayerDialog(playerid, DIALOG_MOVE_SPEED, DIALOG_STYLE_INPUT, "{FFFFFF}Velocidade do Movimento",string,"{8EFF8E}Confirmar","{F58282}Cancelar");
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
                    ShowPlayerDialog(playerid, DIALOG_EXPORTNAME, DIALOG_STYLE_INPUT, "{FFFFFF}Salvar movimento","{FFFFFF}Digite um nome para este movimento de câmera\n{F58282}Você precisa digitar um texto","{8EFF8E}Confirmar","{F58282}Cancelar");
                }
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"{FFFFFF}Editor de Câmera - Próximo Passo?","{FFFFFF}Visualizar\nAlterar Início\nAlterar Fim\nAlterar Velocidade\nSalvar","{8EFF8E}Confirmar","{F58282}Cancelar");
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
                SendClientMessage(playerid, -1, "{8EFF8E}Editor de Câmera{FFFFFF} foi fechado");
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

    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,"{FFFFFF}Editor de Câmera - Próximo Passo?","{FFFFFF}Visualizar\nAlterar Início\nAlterar Fim\nAlterar Velocidade\nSalvar","{8EFF8E}Confirmar","{F58282}Cancelar");

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

    format(myOutpString, sizeof(myOutpString), "{FFFFFF}Movimento da câmera salvo como {F58282}%s{FFFFFF} na pasta scriptfiles!\n\nO que você gostaria de fazer agora?", filename);
    ShowPlayerDialog(playerid, DIALOG_CLOSE_NEW, DIALOG_STYLE_MSGBOX,"{FFFFFF}O que fazer?",myOutpString,"{8EFF8E}Criar Novo","{F58282}Sair do Editor");
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

    SendClientMessage(playerid, -1, "{8EFF8E}Editor de Câmera{FFFFFF} foi ativado com sucesso");
    SendClientMessage(playerid, -1, "{FFFFFF}Use {F58282}~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~ e ~k~~GO_RIGHT~{FFFFFF} para navegar no espaço 3D");
    SendClientMessage(playerid, -1, "{FFFFFF}Pressione {F58282}~k~~PED_FIREWEAPON~{FFFFFF} para definir o {8EFF8E}ponto inicial{FFFFFF}");
    SendClientMessage(playerid, -1, "{FFFFFF}Digite {F58282}/fechareditorcamera{FFFFFF} para sair do editor");

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