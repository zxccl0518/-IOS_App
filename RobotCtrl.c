/***********************************************************************************************
** File Name:      RobotCtrl.c                                                                 *
** Author:         andy.wang                                                                   *
** Date:           25/02/2016                                                                  *
** Copyright:      2016 RoboSys, Incorporated. All Rights Reserved.                            *
** Description:    机器人交互接口类                                                            *
************************************************************************************************/
#include "RobotCtrl.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "cJSON.h"

RobotCtrl robotCtrl;

extern void b64_encode(char *clrstr, char *b64dst, int srcLen);
extern int b64_decode(char *b64src, char *clrdst, int srcLen);
/***********************************************************************************************/
//  @Description                    : LRC检验
//  @param data                     : 待检验数据
//  @param len						: 待检验数据长度
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
unsigned char Lrc(char *data, int len)
{
	int i = 0;
	unsigned char lrc = 0;
	
	if(data == NULL)
	{
		return 0xFF;
	}
	
	for(i = 0;i < len;i++)
	{
		lrc ^= data[i];
	}
	
	return lrc;
}

int hex2str(char *hex, char *str, short wHexLen)
{
    char bLowByte,bHighByte;
    short i;
    
    for(i = 0; i < wHexLen*2; i += 2)
    {
        bLowByte = hex[i/2] & 0x0f;
        bHighByte = hex[i/2] / 16;
        if (bHighByte >= 10)
            str[i] = bHighByte + '7';
        else
            str[i] = bHighByte + '0';
        if (bLowByte >= 10)
            str[i+1] = bLowByte + '7';
        else
            str[i+1] = bLowByte + '0';
    }
    return 2*wHexLen;
    //str[wHexLen*2] = '\0';
}

int str2hex(char *str, char *hex, short wStrLen)
{
    char bLowByte,bHighByte;
    char bHiBase,bLowBase;
    short i;
    
    for(i = 0; i < wStrLen; i += 2)
    {
        bHighByte = toupper(str[i]);
        if ((bHighByte >= 'A') && (bHighByte <= 'F'))
            bHiBase = '7';
        else if ((bHighByte >= '0') && (bHighByte <= '9'))
            bHiBase = '0';
        else
            bHiBase = 0x00;
        bLowByte = toupper(str[i+1]);
        if ((bLowByte >= 'A') && (bLowByte <= 'F'))
            bLowBase = '7';
        else if ((bLowByte >= '0') && (bLowByte <= '9'))
            bLowBase = '0';
        else
            bLowBase = 0x00;
        hex[(i/2)] = ((bHighByte - bHiBase) * 16 + (bLowByte - bLowBase));
    }
    return wStrLen/2;
}


/***********************************************************************************************/
//  @Description                    : 设置机器人的控制模式--当mode为REMOTE_CONTROL_MODE远程控制时需要设置APP登陆服务器账号、token、控制机器人的SN号, 如果为近场控制模式后三个参数为空
//  @param mode                     : 控制模式 NEAR_CONTROL_MODE-0-近场控制模式 REMOTE_CONTROL_MODE-1-远程控制模式
//  @param account					: APP登陆服务器的账号
//  @param token					: APP登陆服务器返回的token
//  @param robotSN					: 控制机器人的SN号
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
void RobotCtrl_SetRobotContrlMode(RobotCtrl *pThis, int mode, char *account, char *token, char *robotSN)
{
    if(mode == NEAR_CONTROL_MODE)
    {
        pThis->isRemoteControl = NEAR_CONTROL_MODE;
    }
    else
    {
        pThis->isRemoteControl = REMOTE_CONTROL_MODE;
    }
    
    memset(pThis->account, 0x00, sizeof(pThis->account));
    memset(pThis->token, 0x00, sizeof(pThis->token));
    memset(pThis->robotSN, 0x00, sizeof(pThis->robotSN));
    
    if(account != NULL)
    {
        if(strlen(account) > 32)
        {
            memcpy(pThis->account, account, 32);
        }
        else
        {
            strcpy(pThis->account, account);
        }
    }
    
    if(token != NULL)
    {
        if(strlen(token) > 64)
        {
            memcpy(pThis->token, token, 64);
        }
        else
        {
            strcpy(pThis->token, token);
        }
    }
    
    if(robotSN != NULL)
    {
        if(strlen(robotSN) > 33)
        {
            memcpy(pThis->robotSN, robotSN, 33);
        }
        else
        {
            strcpy(pThis->robotSN, robotSN);
        }
    }
}


/***********************************************************************************************/
//  @Description                    : 请求控制机器人
//  @param                          : None
//  @return                         : None
//  @Author: max.liu
//  Note:
/***********************************************************************************************/
static int RequestRobotCtrl_LY(RobotCtrl *pThis, char *cmd, int len, char *output, int recvFlag)
{
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        return RobotConn_SendCmd(&pThis->roboConn, cmd, len, output, recvFlag);
    }
    else
    {
        cJSON *root = NULL;
        cJSON *content = NULL;
        char *sendJson = NULL;
        char recvBuf[30*1024] = {0};
        int ret = 0;
        int status = -1;
        char cmdBuf[1024] = {0};
        
        if((cmd == NULL) || (len <= 0))
        {
            return -1;
        }
        
        root = cJSON_CreateObject();
        content = cJSON_CreateObject();
        if((NULL == root) || (NULL == content))
        {
            return -1;
        }
        
        b64_encode(cmd, cmdBuf, len);
        cJSON_AddStringToObject(root, "cmd", "message");
        cJSON_AddStringToObject(root, "user_name", pThis->account);
        cJSON_AddStringToObject(root, "token", pThis->token);
        cJSON_AddStringToObject(content, "method", "control");
        cJSON_AddStringToObject(content, "robot_id", pThis->robotSN);
        cJSON_AddStringToObject(content, "sequence", cmdBuf);
        cJSON_AddNumberToObject(content, "wait_result", recvFlag);
        cJSON_AddItemToObject(root, "content", content);
        
        sendJson = cJSON_Print(root);
        //        printf("senJson    \n     %s \n",sendJson);
        
        
        if(sendJson == NULL)
        {
            cJSON_Delete(root);
            return -1;
        }
        
        //发送数据
        ret = RobotConn_RequestServer_LY(&pThis->roboConn, sendJson, (int)strlen(sendJson), recvBuf, recvFlag);
        printf("ret abcdef   %d", ret);
        
        printf("recvBuf   +++++++     %s\n", recvBuf);
        
        if(ret > 0)
        {
            //接收数据的处理
            cJSON *rsp = NULL;
            cJSON *pStatus = NULL;
            cJSON *pContent = NULL;
            
            if((rsp = cJSON_Parse(recvBuf)) != NULL)
            {
                pStatus = cJSON_GetObjectItem(rsp, "status");
                if(pStatus != NULL)
                {
                    status = pStatus->valueint;
                    
                    //                    printf("status1 +++++++  %d\n",status);
                    
                }
                
                pContent = cJSON_GetObjectItem(rsp, "content");
                if((pContent != NULL) && (pContent->valuestring != NULL))
                {
                    int contentLen = 0;
                    contentLen = (strlen(pContent->valuestring) > 30*1024) ? 30*1024 : strlen(pContent->valuestring);
                    status = b64_decode(pContent->valuestring, output, contentLen);
                    
                    //                    printf("status2 +++++++ %d\n",status);
                }
            }
        }
        
        //释放内存
        cJSON_Delete(root);
        if(sendJson != NULL)
        {
            free(sendJson);
            sendJson = NULL;
        }
        
        return status;
    }
}

/***********************************************************************************************/
//  @Description                    : 请求控制机器人
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int RequestRobotCtrl(RobotCtrl *pThis, char *cmd, int len, char *output, int recvFlag)
{
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        return RobotConn_SendCmd(&pThis->roboConn, cmd, len, output, recvFlag);
    }
    else
    {
        cJSON *root = NULL;
        cJSON *content = NULL;
        char *sendJson = NULL;
        char recvBuf[30*1024] = {0};
        int ret = 0;
        int status = -1;
        char cmdBuf[1024] = {0};
        
        if((cmd == NULL) || (len <= 0))
        {
            return -1;
        }
        
        root = cJSON_CreateObject();
        content = cJSON_CreateObject();
        if((NULL == root) || (NULL == content))
        {
            return -1;
        }
        
        b64_encode(cmd, cmdBuf, len);
        cJSON_AddStringToObject(root, "cmd", "message");
        cJSON_AddStringToObject(root, "user_name", pThis->account);
        cJSON_AddStringToObject(root, "token", pThis->token);
        cJSON_AddStringToObject(content, "method", "control");
        cJSON_AddStringToObject(content, "robot_id", pThis->robotSN);
        cJSON_AddStringToObject(content, "sequence", cmdBuf);
        cJSON_AddNumberToObject(content, "wait_result", recvFlag);
        cJSON_AddItemToObject(root, "content", content);
        
        sendJson = cJSON_Print(root);
//        printf("senJson    \n     %s \n",sendJson);
        
        
        if(sendJson == NULL)
        {
            cJSON_Delete(root);
            return -1;
        }
        
        //发送数据
        ret = RobotConn_RequestServer(&pThis->roboConn, sendJson, (int)strlen(sendJson), recvBuf, recvFlag);
        printf("ret abcdef   %d", ret);
        
//        printf("recvBuf   +++++++     %s\n", recvBuf);
        
        if(ret > 0)
        {
            //接收数据的处理
            cJSON *rsp = NULL;
            cJSON *pStatus = NULL;
            cJSON *pContent = NULL;
            
            if((rsp = cJSON_Parse(recvBuf)) != NULL)
            {
                pStatus = cJSON_GetObjectItem(rsp, "status");
                if(pStatus != NULL)
                {
                    status = pStatus->valueint;
                    
//                    printf("status1 +++++++  %d\n",status);
                    
                }
                
                pContent = cJSON_GetObjectItem(rsp, "content");
                if((pContent != NULL) && (pContent->valuestring != NULL))
                {
                    int contentLen = 0;
                    contentLen = (strlen(pContent->valuestring) > 30*1024) ? 30*1024 : strlen(pContent->valuestring);
                    status = b64_decode(pContent->valuestring, output, contentLen);
                   
//                    printf("status2 +++++++ %d\n",status);
                }
            }
        }
        
        //释放内存
        cJSON_Delete(root);
        if(sendJson != NULL)
        {
            free(sendJson);
            sendJson = NULL;
        }
        
        return status;
    }
}

/***********************************************************************************************/
//  @Description                    : 学习
//  @param                          : None
//  @return                         : None
//  @Author: max.liu
//  Note:
/***********************************************************************************************/
static void Study(RobotCtrl *pThis,char *courseid,char *coursetitle,char *coursepath,char *stop,int revcFlag){
    
    cJSON *root = NULL;
    cJSON *content = NULL;
//    char *output = NULL;
    char *sendJson = NULL;
    
    int ret = 0;
    
    root = cJSON_CreateObject();
    content = cJSON_CreateObject();
    
//    b64_encode(cmd, cmdBuf, len);
    cJSON_AddStringToObject(root, "cmd", "message");
    cJSON_AddStringToObject(root, "user_name", pThis->account);
    cJSON_AddStringToObject(root, "token", pThis->token);
    cJSON_AddStringToObject(content, "method", "study_course");
    cJSON_AddStringToObject(content, "robot_id", pThis->robotSN);
    cJSON_AddStringToObject(content, "courseid", courseid);
    cJSON_AddStringToObject(content, "coursetitle", coursetitle);
    cJSON_AddStringToObject(content, "coursepath", coursepath);
    cJSON_AddStringToObject(content, "stop", stop);
    cJSON_AddNumberToObject(content, "wait_result", revcFlag);
    cJSON_AddItemToObject(root, "content", content);
    
    sendJson = cJSON_Print(root);
    //        printf("senJson    \n     %s \n",sendJson);
    
    
    if(sendJson == NULL)
    {
        cJSON_Delete(root);
    }
    
    //发送数据
    
    ret = RobotConn_RequestServer(&pThis->roboConn, sendJson, (int)strlen(sendJson), NULL, revcFlag);
//    ret = RobotConn_RequestServer(&pThis->roboConn, sendJson, (int)strlen(sendJson), setvbuf, revcFlag);
    
    //释放内存
    cJSON_Delete(root);
    if(sendJson != NULL)
    {
        free(sendJson);
        sendJson = NULL;
    }
}

/***********************************************************************************************/
//  @Description                    : 连接机器人
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int ConnRobot(RobotCtrl *pThis)
{
    char cmd[128] = {0};
    char output[128] = {0};
    int ret = 0;
    int status = -1;
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 1;
    cmd[2] = APP_MANAGE_CMD_CONNECT;
    cmd[3] = Lrc(cmd, 3);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 4, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, 4, output, 1);
    }
    
    printf("返回的数据output %d    %d  %d \n",output[0],output[1],output[2]);
    
    printf("ret   +++++++   %d\n",ret);
    
//    printf("ret   +++++++   %d\n",ret);
    
    if(ret >= 4)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
//            printf("%d\n",ret);
            //判断数据返
            
            if(output[0] == ROBOT_CMD_RSP_HEAD)
            {
                if(output[3] == 0)
                {
                    status = 0;
                }
            }
//            printf("%d\n",ret);
        }
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 组合动作
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void CombActions(RobotCtrl *pThis, char *actions)
{
	char *cmd = NULL;
	int len = 0;
	int ret = 0;
	char output[1024] = {0};

	if(actions == NULL)
	{
		return;
	}

	cmd = (char*)malloc(10*1024);
	if(cmd == NULL)
	{
		return;
	}
	memset(cmd, 0x00, 10*1024);

	//组命令数据
	len = strlen(actions);
    cmd[0] = ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN;
    sprintf(&cmd[1], "%04x", len+1);
    cmd[3] = APP_CTRL_CMD_COMB_ACTIONS;
    memcpy(&cmd[4], actions, len);
    cmd[len+4] = Lrc(cmd, len+4);

	//发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, len+5, output, 0);
        
//        printf("发送的命令:ret %d ++++++\n output: %d   %d   %d  接收到的数据\n",ret,output[0],output[1],output[2]);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, len+5, output, 0);
    }

	if(cmd != NULL)
	{
		free(cmd);
	}
}

/***********************************************************************************************/
//  @Description                    : 前进
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void Forward(RobotCtrl *pThis, int speed, int time, int distance)
{
	char action[64] = "";
	
	if(speed == 0)
	{
		return;
	}

	if(distance != 0)
	{
		sprintf(action, "%d#%d", 12, distance);
	}
	else if(time != 0)
	{
		sprintf(action, "%d#%d", 11, time);
	}
    else
	{
		sprintf(action, "%d#%d", 10, speed);
	}
	
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 后退
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void Fallback(RobotCtrl *pThis, int speed, int time, int distance)
{
	char action[64] = "";
	
	if(speed == 0)
	{
		return;
	}
	
	if(distance != 0)
	{
		sprintf(action, "%d#%d", 15, distance);
	}
	else if(time != 0)
	{
		sprintf(action, "%d#%d", 14, time);
	}
    else
	{
		sprintf(action, "%d#%d", 13, speed);
	}
	
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 左转右转
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void Turn(RobotCtrl *pThis, int leftSpeed, int rightSpeed)
{
	char action[64] = "";
	
	if((leftSpeed == 0) && (rightSpeed == 0))
	{
		return;
	}
	
	sprintf(action, "%d#%d#%d", 17, leftSpeed, rightSpeed);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 点头
//  @param speed                    : 速度类型 3--高速 2--中速 1--低速
//  @param times                    : 点头次数 
//  @param angle                    : 点头角度(0-8度)
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void Nod(RobotCtrl *pThis, int speed, int times, int angle)
{
	char action[64] = "";
	
	if(times == 0)
	{
		return;
	}

	if(speed <= 0)
	{
		speed = 2;
	}

	if(angle <= 0)
	{
		angle = 6;
	}
	
	sprintf(action, "%d#%d#%d#%d", 24, speed, times, angle);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 摇头
//  @param speed                    : 速度类型 3--高速 2--中速 1--低速
//  @param times                    : 摇头次数 
//  @param angle                    : 摇头角度(0-40度)
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void Shake(RobotCtrl *pThis, int speed, int times, int angle)
{
	char action[64] = "";
	
	if(times == 0)
	{
		return;
	}
	
	if(speed <= 0)
	{
		speed = 2;
	}
	
	if(angle <= 0)
	{
		angle = 40;
	}
	
	sprintf(action, "%d#%d#%d#%d", 25, speed, times, angle);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 向上看
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void LookUp(RobotCtrl *pThis)
{
	char action[64] = "";
	
	sprintf(action, "%d", 27);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 向下看
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void LookDown(RobotCtrl *pThis)
{
	char action[64] = "";
	
	sprintf(action, "%d", 28);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 向左看
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void LookLeft(RobotCtrl *pThis)
{
	char action[64] = "";
	
	sprintf(action, "%d", 29);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 向右看
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void LookRight(RobotCtrl *pThis)
{
	char action[64] = "";
	
	sprintf(action, "%d", 30);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 向前看
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void LookForward(RobotCtrl *pThis)
{
	char action[64] = "";
	
	sprintf(action, "%d", 31);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 停止运动
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void StopRun(RobotCtrl *pThis)
{
	char action[64] = "";
	
	sprintf(action, "%d", 22);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 顺时针旋转
//  @param speedType                : 速度类型 0--高速 1--中速 2--低速
//  @param angle                    : 角度
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void ClockwiseWhirl(RobotCtrl *pThis, int speedType, int angle)
{
	char action[64] = "";
	
	if(speedType <= 0)
	{
		speedType = 1;
	}

	sprintf(action, "%d#%d#%d", 20, speedType, angle);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 逆时针旋转
//  @param speedType                : 速度类型 0--高速 1--中速 2--低速
//  @param angle                    : 角度
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void CounterClockwiseWhirl(RobotCtrl *pThis, int speedType, int angle)
{
	char action[64] = "";
	
	if(speedType <= 0)
	{
		speedType = 1;
	}
	
	sprintf(action, "%d#%d#%d", 21, speedType, angle);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 顺时针旋转
//  @param speed                    : 速度值
//  @param time                     : 时间
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void ClockwiseWhirlByTime(RobotCtrl *pThis, int speed, int time)
{
    char action[64] = "";
    
    if(speed < 0)
    {
        speed = 0;
    }
    
    sprintf(action, "%d#%d#%d", 61, speed, time);
    CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 逆时针旋转
//  @param speed                    : 速度值
//  @param time                     : 角度
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void CounterClockwiseWhirlByTime(RobotCtrl *pThis, int speed, int time)
{
    char action[64] = "";
    
    if(speed < 0)
    {
        speed = 0;
    }
    
    sprintf(action, "%d#%d#%d", 62, speed, time);
    CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 播放合成音
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void SST(RobotCtrl *pThis, const char *text)
{
	char *action = NULL;
	int len = 0;

	if(text == NULL)
	{
		return;
	}

	action = (char*)malloc(10*1024);
	if(action == NULL)
	{
		return;
	}
	memset(action, 0x00, 10*1024);

	//判断长度是否超过
	len = (strlen(text) > (10*1024-10)) ? (10*1024-10) : strlen(text);

	sprintf(action, "%d#%s", 1, text);
	CombActions(pThis, action);

	if(action != NULL)
	{
		free(action);
		action = NULL;
	}
}

/***********************************************************************************************/
//  @Description                    : 设置运动模式
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void SetRunMode(RobotCtrl *pThis, int mode)
{
	char cmd[128] = {0};
	
	//组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 2;
    cmd[2] = APP_CTRL_CMD_ACTION_MODE_CTRL;
    cmd[3] = (unsigned char)mode;
    cmd[4] = Lrc(cmd, 4);
	
	//发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5, NULL, 0);
    }
}

/***********************************************************************************************/
//  @Description                    : 设置机器人眼睛情绪
//  @param mode                     : 眼睛情绪
//  @return                         : None
//EMOTION_EYE_CLOSE = 0,	// 关闭
//EMOTION_EYE_CALM = 1,	// 淡定
//EMOTION_EYE_HAPPY = 2,	// 喜悦
//EMOTION_EYE_PRAISE = 3,	// 赞扬
//EMOTION_EYE_DESPITE = 4,	// 瞧不起
//EMOTION_EYE_NAUGHTY = 5,	// 调皮
//EMOTION_EYE_WORRY = 6,	// 烦闷
//EMOTION_EYE_SAD = 7,	// 悲伤
//EMOTION_EYE_LIKE = 8,	// 喜爱
//EMOTION_EYE_ANGRY = 9,	// 愤怒
//EMOTION_EYE_SURPRISE = 10,	// 惊奇
//EMOTION_EYE_DISAPPOINTED = 11,	// 失望
//EMOTION_EYE_YES = 12,	// 确认
//EMOTION_EYE_NO  = 13, 	// 否认
//EMOTION_EYE_CONFUSED= 14, 	// 慌张
//EMOTION_EYE_CONCEITED = 15, 	// 高傲
//EMOTION_EYE_SUSPECT = 16,	// 疑问
//EMOTION_EYE_WAITING = 17,	// 请等待
//EMOTION_EYE_CROSS = 18,	// 电量低, 需要治疗, 十字
//EMOTION_EYE_CRY_STATIC  = 19,	// 哭, 静态
//EMOTION_EYE_CRY_DYNAMIC = 20	// 哭, 动态
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void SetRobotEye(RobotCtrl *pThis, int mode)
{
	char action[64] = "";
	
	sprintf(action, "%d#%d", 32, mode);
	CombActions(pThis, action);
}


/***********************************************************************************************/
//  @Description                    : 设置机器人耳朵效果
//  @param mode                     : 耳朵效果
//  @return                         : None
//FUN_MODE_ALL_OFF	0 ALL OFF
//FUN_MODE_ALL_ON            1	八颗全亮
//FUN_MODE_RUNNING_FAST      2	快速跑马灯
//FUN_MODE_RUNNING_SLOW      3	慢速跑马灯
//FUN_MODE_BREATH_FAST       4	快速呼吸
//FUN_MODE_BREATH_MID        5	中速呼吸
//FUN_MODE_BREATH_SLOW       6	慢速呼吸
//FUN_MODE_MUSIC_PLAY        7	律动
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void SetRobotEar(RobotCtrl *pThis, int mode)
{
	char action[64] = "";
	
	sprintf(action, "%d#%d", 40, mode);
	CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 音乐播放
//  @param type                     : 音乐控制类型 0-开始播放 1-播放上一首 2-播放下一首 3--停止
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void MusicCtrl(RobotCtrl *pThis, int type)
{
	char cmd[128] = {0};
	
	//组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 2;
    cmd[2] = APP_CTRL_CMD_SING;
    cmd[3] = (unsigned char)type;
    cmd[4] = Lrc(cmd, 4);
	
	//发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5, NULL, 0);
    }
}

/***********************************************************************************************/
//  @Description                    : 讲故事
//  @param type                     : 讲故事控制类型 0-开始播放 1-播放上一个 2-播放下一个 3--停止
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void StoryCtrl(RobotCtrl *pThis, int type, char *keyword)
{
	char cmd[128] = {0};
	
	//组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 2;
    cmd[2] = APP_CTRL_CMD_STORY;
    cmd[3] = (unsigned char)type;
    cmd[4] = Lrc(cmd, 4);
	
	//发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5, NULL, 0);
    }
}

/***********************************************************************************************/
//  @Description                    : 停止音频内容的播放
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void StopAudioPlay(RobotCtrl *pThis)
{
    char action[64] = "";
    
    sprintf(action, "%d", 2);
    CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 还原网络设置
//  @param type                     :
//  @return                         : None
//  @Author: max.liu
//  Note:
/***********************************************************************************************/
static void ReSetWifiConfig(RobotCtrl *pThis)
{
    char cmd[128] = {0};
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 1;
    cmd[2] = APP_MANAGE_CMD_GET_ROBOT_RET;
    cmd[4] = Lrc(cmd, 4);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5, NULL, 0);
    }
}



/***********************************************************************************************/
//  @Description                    : 请求连接指定wifi列表
//  @param index                    : 账号和密码
//  @return                         : None
//  @Author: max.liu
//  Note:
/***********************************************************************************************/
static void ConnectSpecifiedWifi(RobotCtrl *pThis, char *wifiData,int lenData)
{
    char cmd[250] = {0};
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    
    //长度
    cmd[1] = lenData + 1;
    
    //连接指定wifi和密码命令
    cmd[2] = APP_MANAGE_CMD_GET_ROBOT_SPECIED;
    
    //内容 发送的内容
//    cmd[3] = wifiData;
    memcpy(&cmd[3], wifiData, lenData);
    
    cmd[4+lenData] = Lrc(cmd, lenData + 4);
    
//    printf("cmd----------------------------------------\n %s",&cmd[3]);

    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5 + lenData, NULL, 0 );
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5 + lenData, NULL, 0);
    }
}

/***********************************************************************************************/
//  @Description                    : 获取机器人WIFI列表
//  @param type                     :
//  @return                         : None
//  @Author: max.liu
//  Note:
/***********************************************************************************************/

static int QueryRobotWifiList(RobotCtrl *pThis, char *wifiList)
{
    //字符数组 命令
    char cmd[128] = {0};
    
//    返回标识
    int ret = 0;
    
    //空指针  存储返回的数据
    char *output = NULL;
    
    int status = -1;
    
    //动态分配内存空间 定义字符串指针 分配内存空间
    output = (char *)malloc(100*1024);
    
    //指针为空
    if (output == NULL) {
        
        return status;
    }
    
    memset(output, 0x00, 100*1024);
    
    //设置组命令数据
    //命令头
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    //长度
    cmd[1] = 1;
    
    //查询wifi列表的命令
    cmd[2] = APP_MANAGE_CMD_GET_ROBOT_WIFI;
    
    //lrc 校验
    cmd[3] = Lrc(cmd, 3);
    
    //发送数据  近场控制
    if (pThis->isRemoteControl == NEAR_CONTROL_MODE) {
        
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 4, output, 1);
    }else{
        
//        printf("cmd = %d %d %d",cmd[0],cmd[1],cmd[2]);
        
        //远程控制  走服务器
        ret = RequestRobotCtrl_LY(pThis, cmd, 4, output, 1);
    }
    
//    printf("ret === %d  \n",ret);
    
//    printf("output ==  %s \n",output);
//    返回的数据
    if (ret > 4) {
        
        if (Lrc(output, ret) == 0) {
            
            char *p = NULL;
            int len = 0;
            
            //判断数据返回头
            if (output[0] == ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN) {
                len = ((output[1] & 0xff) * 256) | (output[2] & 0xff);
                
//                printf("len :++++++++++++  %d  \n",len);
                //判断长度 返回为0 为成功
                if ((len > 2) && (output[4] == 0)) {
                    p = &output[5];
                    output[ret - 1] = 0;
                    
//                    printf("\n output : %x %x\n",output[1],output[2]);
//                    printf("p======  %s \n",p);
                    
                    //内存复制函数  返回指向 wifilist指针
                    memcpy(wifiList, p, len - 2);
                    
                    status = 0;
                }
            }
        }
    }
    
    //释放内存
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 请求查看Robot本地音乐列表
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int QueryRobotMusicList(RobotCtrl *pThis, char **musicList)
{
    char cmd[128] = {0};
    char *output = NULL;
    int ret = 0;
    int status = -1;
    
    output = (char*)malloc(100*1024);
    if(output == NULL)
    {
        return status;
    }
    memset(output, 0x00, 100*1024);
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN;
    cmd[1] = 0;
    cmd[2] = 1;
    cmd[3] = APP_CTRL_CMD_GET_MUSIC_LIST;
    cmd[4] = Lrc(cmd, 4);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 5, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, 5, output, 1);
    }
    
    if(ret > 4)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            char *p = NULL;
            char *item = NULL;
            int i = 0;
            int len = 0;
            
            //判断数据返回头
            if(output[0] == ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN)
            {
                len = output[1]*256+output[2];
                
                //判断长度
                if((len > 2) && (output[4] == 0))
                {
                    p = &output[5];
                    while((item=strsep(&p, "#")) != NULL)
                    {
                        strcpy(musicList[i], item);
                        
                        i++;
                    }
                    
                    status = 0;
                }
            }
        }
    }
    
    //释放内存
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 请求播放Robot本地音乐列表中指定的音乐
//  @param index                    : 请求播放的本地音乐列表索引
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void PlayRobotMusicByIndex(RobotCtrl *pThis, int index)
{
    char cmd[128] = {0};
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 2;
    cmd[2] = APP_CTRL_CMD_PLAY_MUSIC_INDEX;
    cmd[3] = (unsigned char)index;
    cmd[4] = Lrc(cmd, 4);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5, NULL, 0);
    }
}

/***********************************************************************************************/
//  @Description                    : 心跳包
//  @param battery                  : 机器人返回的电量
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int TickRequeset(RobotCtrl *pThis, int *battery)
{
    char cmd[128] = {0};
    char *output = NULL;
    int ret = 0;
    int status = -1;
    
    if(battery == NULL)
    {
        return status;
    }
    
    output = (char*)malloc(100*1024);
    if(output == NULL)
    {
        return status;
    }
    memset(output, 0x00, 100*1024);
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 1;
    cmd[2] = APP_CTRL_CMD_TICK;
    cmd[3] = Lrc(cmd, 3);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 4, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, 4, output, 1);
    }
    if(ret > 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if(output[0] == ROBOT_CMD_RSP_HEAD)
            {
                int len = output[1];
                
                //判断长度
                if((len > 2) && (output[4] == 0))
                {
                    *battery = output[5];
                    
                    status = 0;
                }
            }
        }
        
        
    }
    
    //释放内存
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}



/***********************************************************************************************/
//  @Description                    : 播放URL
//  @param url                      : 播放的URL
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int PlayUrl(RobotCtrl *pThis, char *url)
{
//    printf("000000");
//    char cmd[256] = {0};
//    char output[256] = {0};
    char cmd[512] = {0};
    char output[512] = {0};
    int len = 0;
    int ret = 0;
    int status = -1;
    
    if(url == NULL)
    {
        return status;
    }
    
//    printf("11111111");
    
    //组命令数据
    len = strlen(url) + 1;
//    printf("22222222");
    cmd[0] = ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN;
    cmd[1] = (len & 0x0000FF00) >> 8;
    cmd[2] = (len & 0x000000FF);
    cmd[3] = APP_CTRL_CMD_PLAY_URL;
    memcpy(&cmd[4], url, len);
    cmd[len+4] = Lrc(cmd, len+4);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, len+5, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, len+5, output, 1);
    }
    if(ret >= 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if((output[0] == ROBOT_CMD_RSP_HEAD) && ((unsigned char)output[2] == (unsigned char)APP_CTRL_CMD_PLAY_URL))
            {
                status = output[3];
            }
        }
    }
    
    
    return status;
}



/***********************************************************************************************/
//  @Description                    : 播放URL
//  @param num                      : 批量删除脚本的数量
//  @param idList                   : 批量删除脚本ID的列表
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int DeleteScriptMulti(RobotCtrl *pThis, int num, int *idList)
{
    char cmd[2048] = {0};
    char output[512] = {0};
    int len = 0;
    int ret = 0;
    int i = 0;
    int status = -1;
    
    if((idList == NULL) || (num == 0))
    {
        return status;
    }
    
    //组命令数据
    len = 4*num + 5;
    cmd[0] = ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN;
    cmd[1] = (len & 0x0000FF00) >> 8;
    cmd[2] = (len & 0x000000FF);
    cmd[3] = APP_CTRL_CMD_DELETE_SCRIPT_MULTI;
    cmd[4] = (num & 0xFF000000) >> 24;
    cmd[5] = (num & 0x00FF0000) >> 16;
    cmd[6] = (num & 0x0000FF00) >> 8;
    cmd[7] = num & 0x000000FF;
    for(i = 0;i < num;i++)
    {
        cmd[4*i+8] = (idList[i] & 0xFF000000) >> 24;
        cmd[4*i+8+1] = (idList[i] & 0x00FF0000) >> 16;
        cmd[4*i+8+2] = (idList[i] & 0x0000FF00) >> 8;
        cmd[4*i+8+3] = (idList[i] & 0x000000FF);
    }
    cmd[len+3] = Lrc(cmd, len+3);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, len+5, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, len+5, output, 1);
    }
    if(ret >= 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if((output[0] == ROBOT_CMD_RSP_HEAD) && ((unsigned char)output[2] == (unsigned char)APP_CTRL_CMD_DELETE_SCRIPT_MULTI))
            {
                status = output[3];
            }
        }
    }
    
    
    return status;
}


/***********************************************************************************************/
//  @Description                    : 获取歌单音乐列表
//  @param albumId                  : 歌单ID
//  @param page                		: 返回的第几页
//  @param musicItem                : 返回的歌曲列表
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int PlayerGetAlbumList(RobotCtrl *pThis, int albumId, int page, MusicItem **musicItemList)
{   
    char cmd[128] = {0};
    char *output = NULL;
    int ret = 0;
    int status = -1;
    
    if(musicItemList == NULL)
    {
        return status;
    }
    
    output = (char*)malloc(20*1024);
    if(output == NULL)
    {
        return status;
    }
    memset(output, 0x00, 20*1024);
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 9;
    cmd[2] = APP_CTRL_CMD_PLAYER_GET_ALBUM_LIST;
    cmd[3] = (albumId&0xFF000000)>>24;
    cmd[4] = (albumId&0x00FF0000)>>16;
    cmd[5] = (albumId&0x0000FF00)>>8;
    cmd[6] = albumId&0x000000FF;
	cmd[7] = (page&0xFF000000)>>24;
    cmd[8] = (page&0x00FF0000)>>16;
    cmd[9] = (page&0x0000FF00)>>8;
    cmd[10] = page&0x000000FF;
    cmd[11] = Lrc(cmd, 11);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 12, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, 12, output, 1);
    }
    if(ret > 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if(output[0] == ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN)
            {
                int len = (unsigned char)output[1]*256+(unsigned char)output[2];
                
                //判断长度
                if((len > 2) && (output[4] == 0))
                {
                    int musicInfoLen = output[5]<<24 + output[6]<<16 + output[7]<<8 + output[8];
                    char *p = &output[9];
                    char *pTmp = NULL;
                    int i = 0;
                    MusicItem item = {0};
					output[ret-1] = 0;		//将校验值置0
                    while((pTmp = strsep(&p, "*")) != NULL)
                    {
                        char *pItem = NULL;
                        memset(&item, 0x00, sizeof(MusicItem));
                            
                        //歌曲ID
                        pItem = strsep(&pTmp, "#");
                        if(pItem == NULL)
                        {
                            continue;
                        }
                        item.musicid = atoi(pItem);
                            
                        //歌曲名
                        pItem = strsep(&pTmp, "#");
                        if(pItem == NULL)
                        {
                            continue;
                        }
                        strcpy(item.name, pItem);
                            
                        //所在专辑ID
                        pItem = strsep(&pTmp, "#");
                        if(pItem == NULL)
                        {
                            continue;
                        }
                        item.albumId = atoi(pItem);
                            
                        //添加至歌曲列表中
                        memcpy(musicItemList[i], &item, sizeof(MusicItem));
                        printf("%d--%s--%d\n",item.musicid,item.name,item.albumId);
                        i++;
                    }                    
                    
                    status = 0;
                }
            }
        }
    }
    
    //释放内存
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}



/***********************************************************************************************/
//  @Description                    : 播放器播放音乐
//  @param type                     : 音频来源
//  @param startInfo                : 播放信息
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int PlayerStart(RobotCtrl *pThis, int type, char *startInfo,int startInfoLen)
{
    char cmd[512] = {0};
    char output[512] = {0};
    int len = 0;
    int ret = 0;
    int status = -1;
    
    if(startInfo == NULL)
    {
        return status;
    }
    
    
    //组命令数据
    len = startInfoLen + 2;
    cmd[0] = ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN;
    cmd[1] = (len & 0x0000FF00) >> 8;
    cmd[2] = (len & 0x000000FF);
    cmd[3] = APP_CTRL_CMD_PLAYER_START;
    cmd[4] = (char)type;
    memcpy(&cmd[5], startInfo, startInfoLen);
    
    cmd[len+3] = Lrc(cmd, len+3);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, len+4, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, len+4, output, 1);
    }
    if(ret >= 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if((output[0] == ROBOT_CMD_RSP_HEAD) && ((unsigned char)output[2] == (unsigned char)APP_CTRL_CMD_PLAYER_START))
            {
                status = output[3];
            }
        }
    }
    
    
    return status;
}



/***********************************************************************************************/
//  @Description                    : 播放器控制播放音乐
//  @param cmd                      : 播放控制命令
//  @param param                    : 播放控制命令参数
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int PlayerCtrl(RobotCtrl *pThis, int comd, int param)
{
    char cmd[512] = {0};
    char output[512] = {0};
    int len = 0;
    int ret = 0;
    int status = -1;

	
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 6;
    cmd[2] = APP_CTRL_CMD_PLAYER_CTRL;
	cmd[3] = (char)comd;
	cmd[4] = (param&0xFF000000)>>24;
    cmd[5] = (param&0x00FF0000)>>16;
    cmd[6] = (param&0x0000FF00)>>8;
    cmd[7] = param&0x000000FF;
    cmd[8] = Lrc(cmd, 8);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 9, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, 9, output, 1);
    }
    if(ret >= 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if((output[0] == ROBOT_CMD_RSP_HEAD) && ((unsigned char)output[2] == (unsigned char)APP_CTRL_CMD_PLAYER_CTRL))
            {
                status = output[3];
            }
        }
    }
    
    
    return status;
}


/***********************************************************************************************/
//  @Description                    : 获取歌单音乐列表
//  @param page                     : 返回的第几页
//  @param path                		: 指定目录的路径
//  @param direcItemList            : 返回的歌曲/目录列表
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int PlayerQueryDirecMusicList(RobotCtrl *pThis, int page, char *path, DirecItem **direcItemList)
{   
    char cmd[128] = {0};
    char *output = NULL;
    int ret = 0;
	int len = 0;
    int status = -1;
    
    if((direcItemList == NULL) || (path == NULL))
    {
        return status;
    }
    
    output = (char*)malloc(20*1024);
    if(output == NULL)
    {
        return status;
    }
    memset(output, 0x00, 20*1024);
    
    //组命令数据
	len = (int)strlen(path) + 5;
    cmd[0] = ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN;
    cmd[1] = (len & 0x0000FF00) >> 8;
    cmd[2] = (len & 0x000000FF);
    cmd[3] = APP_CTRL_CMD_PLAYER_QUERY_DIREC_MUSIC_LIST;
    cmd[4] = (page&0xFF000000)>>24;
    cmd[5] = (page&0x00FF0000)>>16;
    cmd[6] = (page&0x0000FF00)>>8;
    cmd[7] = page&0x000000FF;
	memcpy(&cmd[8], path, strlen(path));
    cmd[len+3] = Lrc(cmd, len+3);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, len+4, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, len+4, output, 1);
    }
    if(ret > 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if(output[0] == ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN)
            {
                int len = (unsigned char)output[1]*256+(unsigned char)output[2];
                
                //判断长度
                if((len > 2) && (output[4] == 0))
                {
                    int musicInfoLen = (output[5]<<24) + (output[6]<<16) + (output[7]<<8) + (output[8]);
                    char *p = &output[9];
                    char *pTmp = NULL;
                    int i = 0;
                    DirecItem item = {0};
                       
					output[ret-1] = 0;		//将校验值置0
                    while((pTmp = strsep(&p, "*")) != NULL)
                    {
                        char *pItem = NULL;
                        memset(&item, 0x00, sizeof(DirecItem));
                            
                        //歌曲ID
                        pItem = strsep(&pTmp, ":");
                        if(pItem == NULL)
                        {
                            continue;
                        }
                        item.type = atoi(pItem);
                            
                        //歌曲名
                        pItem = strsep(&pTmp, ":");
                        if(pItem == NULL)
                        {
                            continue;
                        }
                        strcpy(item.name, pItem);
                            
                        //添加至歌曲列表中
                        memcpy(direcItemList[i], &item, sizeof(DirecItem));
//                        printf("%s\n",item.name);
//                        printf("%d",item.type);
                        i++;
                    }                    
                    
                    status = 0;
                }
            }
        }
    }
    
    //释放内存
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 随机卖萌
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void Cute(RobotCtrl *pThis)
{
    char cmd[128] = {0};
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 1;
    cmd[2] = APP_CTRL_CMD_CUTE;
    cmd[3] = Lrc(cmd, 3);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 4, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 4, NULL, 0);
    }
}

/***********************************************************************************************/
//  @Description                    : 控制音量+-
//  @param type                     : 0--音量-  1--音量+
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void VolumeCtrl(RobotCtrl *pThis, int type)
{
    char cmd[128] = {0};
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 2;
    cmd[2] = APP_CTRL_CMD_VOLUME_CTRL;
    cmd[3] = (unsigned char)type;
    cmd[4] = Lrc(cmd, 4);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5, NULL, 0);
    }
}


/***********************************************************************************************/
//  @Description                    : 设置闹铃
//  @param                          : None
//  @return                         : None
/*格式:
提醒内容|提醒时间|提前提醒类型|重复类型
提醒时间:YYYYMMDDHHMM
提醒类型:0--正点提醒
1--5分钟前
2--10分钟前
3--15分钟前
4--30分钟前
5--1小时前
6--2小时前
7--1天前
8--2天前
9--1周前
10--自定义   10#YYYYMMDDHHMM
重复类型:0--不重复
1--每天
2--每周
3--每两周
4--每月
5--每年
6--自定义   6#一个字节，每一位代表周一----周日*/
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int SetAlarm(RobotCtrl *pThis, char *alarmStr)
{
    char cmd[256] = {0};
    char output[256] = {0};
    int len = 0;
    int ret = 0;
    int status = -1;
    
    if(alarmStr == NULL)
    {
        return status;
    }
    
    //判断长度是否过长
    if(strlen(alarmStr) > 250)
    {
        return status;
    }
    
    //组命令数据
    len = strlen(alarmStr);
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = len + 1;
    cmd[2] = APP_CTRL_CMD_SET_ALARM;
    memcpy(&cmd[3], alarmStr, len);
    cmd[len+3] = Lrc(cmd, len+3);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, len+4, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, len+4, output, 1);
    }
    if(ret >= 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if((output[0] == ROBOT_CMD_RSP_HEAD) && ((unsigned char)output[2] == (unsigned char)APP_CTRL_CMD_SET_ALARM))
            {
                status = output[3];
            }
        }
    }
    
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 手臂抬起
//  @param type                     : 0--左手 1--右手
//  @param angle                    : 角度 0-1000 精确到0.1度
//  @param speed                    : 1--低速 2--中速 3--高速
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void HandUp(RobotCtrl *pThis, int type, int angle, int speed)
{
    char action[64] = "";
    
    angle = (angle > 1000) ? 1000 : angle;
    
    if(type == 0)
    {
        sprintf(action, "%d#%d#%d", 54, angle, speed);
    }
    else
    {
        sprintf(action, "%d#%d#%d", 56, angle, speed);
    }
    CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 手臂后摆
//  @param type                     : 0--左手 1--右手
//  @param angle                    : 角度 0-300 精确到0.1度
//  @param speed                    : 1--低速 2--中速 3--高速
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void HandBack(RobotCtrl *pThis, int type, int angle, int speed)
{
    char action[64] = "";
    
    angle = (angle > 300) ? -300 : -angle;
    
    if(type == 0)
    {
        sprintf(action, "%d#%d#%d", 55, angle, speed);
    }
    else
    {
        sprintf(action, "%d#%d#%d", 57, angle, speed);
    }
    CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 手臂前后摆动
//  @param type                     : 0--左手 1--右手
//  @param num                      : 前后摆动手臂的次数
//  @param upAngle                  : 向前摆动的角度 0-1000 精确到0.1度
//  @param backAngle                : 向后摆动的角度 0-300 精确到0.1度
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void HandShake(RobotCtrl *pThis, int type, int num, int upAngle, int backAngle)
{
    char action[64] = "";
    
    upAngle = (upAngle > 1000) ? 1000 : upAngle;
    backAngle = (backAngle > 300) ? 300 : backAngle;
    
    if(type == 0)
    {
        sprintf(action, "%d#%d#%d#%d", 58, num, backAngle, upAngle);
    }
    else
    {
        sprintf(action, "%d#%d#%d#%d", 59, num, backAngle, upAngle);
    }
    CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 手臂左右交叉摆动
//  @param num                      : 前后摆动手臂的次数
//  @param upAngle                  : 向前摆动的角度 0-1000 精确到0.1度
//  @param backAngle                : 向后摆动的角度 0-300 精确到0.1度
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void HandBothShake(RobotCtrl *pThis, int num, int upAngle, int backAngle)
{
    char action[64] = "";
    
    upAngle = (upAngle > 1000) ? 1000 : upAngle;
    backAngle = (backAngle > 300) ? 300 : backAngle;
    
    sprintf(action, "%d#%d#%d#%d", 60, num, backAngle, upAngle);
    CombActions(pThis, action);
}

/***********************************************************************************************/
//  @Description                    : 获取闹铃列表
//  @param page                     : 第几页
//  @param alarmList                : 返回的闹铃列表
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int GetAlarmList(RobotCtrl *pThis, int page, AlarmItem **alarmList)
{
//    printf("aaaaaaaa");
    
    char cmd[128] = {0};
    char *output = NULL;
    int ret = 0;
    int status = -1;
    
    if(alarmList == NULL)
    {
        return status;
    }
    
    output = (char*)malloc(100*1024);
    if(output == NULL)
    {
        return status;
    }
    memset(output, 0x00, 100*1024);
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 1;
    cmd[2] = APP_CTRL_CMD_GET_ALARM_LIST;
    cmd[3] = (page&0xFF000000)>>24;
    cmd[4] = (page&0x00FF0000)>>16;
    cmd[5] = (page&0x0000FF00)>>8;
    cmd[6] = page&0x000000FF;
    cmd[7] = Lrc(cmd, 7);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 8, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, 8, output, 1);
    }
    if(ret > 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if(output[0] == ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN)
            {
                int len = (unsigned char)output[1]*256+(unsigned char)output[2];
                
                //判断长度
                if((len > 2) && (output[5] == 0))
                {
                    int count = output[4];
                    if(count > 0)
                    {
                        char *p = &output[6];
                        char *pTmp = NULL;
                        int i = 0;
                        AlarmItem item = {0};
                        
                        while((pTmp = strsep(&p, "@")) != NULL)
                        {
                            char *pItem = NULL;
                            memset(&item, 0x00, sizeof(AlarmItem));
                            
                            //ID
                            pItem = strsep(&pTmp, "$");
                            if(pItem == NULL)
                            {
                                continue;
                            }
                            item.id = atoi(pItem);
                            
                            //content
                            pItem = strsep(&pTmp, "$");
                            if(pItem == NULL)
                            {
                                continue;
                            }
                            strcpy(item.alarmContent, pItem);
                            
                            //计划年月日
                            pItem = strsep(&pTmp, "$");
                            if(pItem == NULL)
                            {
                                continue;
                            }
                            item.alarmPlanYMD = atoi(pItem);
                            
                            //计划时分
                            pItem = strsep(&pTmp, "$");
                            if(pItem == NULL)
                            {
                                continue;
                            }
                            item.alarmPlanHM = atoi(pItem);
                            
                            //计划年月日
                            pItem = strsep(&pTmp, "$");
                            if(pItem == NULL)
                            {
                                continue;
                            }
                            item.alarmJingleYMD = atoi(pItem);
                            
                            //计划时分
                            pItem = strsep(&pTmp, "$");
                            if(pItem == NULL)
                            {
                                continue;
                            }
                            item.alarmJingleHMS = atoi(pItem);
                            
                            //提前属性
                            pItem = strsep(&pTmp, "$");
                            if(pItem == NULL)
                            {
                                continue;
                            }
                            strcpy(item.alarmAdvance, pItem);
                            
                            //重复属性
                            pItem = strsep(&pTmp, "$");
                            if(pItem == NULL)
                            {
                                continue;
                            }
                            strcpy(item.alarmRepeat, pItem);
                            
                            //添加至闹铃列表中
                            memcpy(alarmList[i], &item, sizeof(AlarmItem));
                            
                            i++;
                        }
                    }
                    
                    status = 0;
                }
            }
        }
        
        
    }
    
    //释放内存
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 更新闹铃列表
//  @param alarmItem                : 更新的闹铃
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int UpdateAlarmItem(RobotCtrl *pThis, int alarmId, char *udpateAlarmStr)
{
    char cmd[256] = {0};
    char output[256] = {0};
    int len = 0;
    int ret = 0;
    int status = -1;
    
    if(udpateAlarmStr == NULL)
    {
        return status;
    }
    
    //判断长度是否过长
    if(strlen(udpateAlarmStr) > 250)
    {
        return status;
    }
    
    //组命令数据
    len = strlen(udpateAlarmStr);
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = len + 5;
    cmd[2] = APP_CTRL_CMD_UPDATE_ALARM;
    cmd[3] = (alarmId & 0xFF000000) >> 24;
    cmd[4] = (alarmId & 0x00FF0000) >> 16;
    cmd[5] = (alarmId & 0x0000FF00) >> 8;
    cmd[6] = alarmId & 0x000000FF;
    memcpy(&cmd[7], udpateAlarmStr, len);
    cmd[len+7] = Lrc(cmd, len+7);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, len+8, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, len+8, output, 1);
    }
    if(ret >= 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if((output[0] == ROBOT_CMD_RSP_HEAD) && ((unsigned char)output[2] == (unsigned char)APP_CTRL_CMD_UPDATE_ALARM))
            {
                status = output[3];
            }
        }
    }
    
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 删除闹铃列表
//  @param alarmItem                : 更新的闹铃
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int DeleteAlarmItem(RobotCtrl *pThis, int alarmId)
{
    char cmd[128] = {0};
    char output[256] = {0};
    int ret = 0;
    int status = -1;
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 5;
    cmd[2] = APP_CTRL_CMD_DELETE_ALARM;
    cmd[3] = (alarmId & 0xFF000000) >> 24;
    cmd[4] = (alarmId & 0x00FF0000) >> 16;
    cmd[5] = (alarmId & 0x0000FF00) >> 8;
    cmd[6] = alarmId & 0x000000FF;
    cmd[7] = Lrc(cmd, 7);
    
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 8, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, 8, output, 1);
    }
    if(ret >= 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if((output[0] == ROBOT_CMD_RSP_HEAD) && ((unsigned char)output[2] == (unsigned char)APP_CTRL_CMD_DELETE_ALARM))
            {
                status = output[3];
            }
        }
    }
    
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 设置音量
//  @param volume                   : 音量值
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void SetVolume(RobotCtrl *pThis, int volume)
{
    char cmd[128] = {0};
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 2;
    cmd[2] = APP_CTRL_CMD_SET_VOLUME;
    cmd[3] = (char)volume;
    cmd[4] = Lrc(cmd, 4);
    
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5, NULL, 0);
    }
}

/***********************************************************************************************/
//  @Description                    : 唤醒/休眠控制
//  @param type                     : 0--休眠 1--唤醒
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void SleepCtrl(RobotCtrl *pThis, int type)
{
    char cmd[128] = {0};
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 2;
    cmd[2] = APP_MANAGE_CMD_STOP_RECOGNIZE;
    cmd[3] = (char)type;
    cmd[4] = Lrc(cmd, 4);
    
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5, NULL, 0);
    }
}

/***********************************************************************************************/
//  @Description                    : 讲笑话
//  @param type                     : 讲笑话控制类型 0-开始播放 1-播放上一个 2-播放下一个 3--停止
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void JokeCtrl(RobotCtrl *pThis, int type, char *keyword)
{
    char cmd[128] = {0};
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 2;
    cmd[2] = APP_CTRL_CMD_JOKE;
    cmd[3] = (unsigned char)type;
    cmd[4] = Lrc(cmd, 4);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 5, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 5, NULL, 0);
    }
}


/***********************************************************************************************/
//  @Description                    : 获取机器人属性
//  @param attr                     : 机器人返回的属性
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int GetRobotAttr(RobotCtrl *pThis, RobotAttr *attr)
{
    char cmd[128] = {0};
    char output[4096] = {0};
    int ret = 0;
    int status = -1;
    
    if(attr == NULL)
    {
        return status;
    }
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 1;
    cmd[2] = APP_MANAGE_CMD_GET_ROBOT_ATTR;
    cmd[3] = Lrc(cmd, 3);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 4, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, 4, output, 1);
    }
    if(ret > 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if(output[0] == ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN)
            {
                int index = 0;
                
                //判断长度
                if(output[3] == (char)APP_MANAGE_CMD_GET_ROBOT_ATTR)
                {
                    index = 4;
                    
                    //机器人姓名长度
                    attr->robotNameLen = output[index];
                    index++;
                    
                    //机器人姓名
                    memcpy(attr->robotName, &output[index], attr->robotNameLen);
                    index += attr->robotNameLen;
                    
                    //管理员姓名长度
                    attr->masterNameLen = output[index];
                    index++;
                    
                    //管理员姓名
                    memcpy(attr->masterName, &output[index], attr->masterNameLen);
                    index += attr->masterNameLen;
                    
                    //口头禅长度
                    attr->mantraLen = output[index];
                    index++;
                    
                    //管理员姓名
                    memcpy(attr->mantra, &output[index], attr->mantraLen);
                    index += attr->mantraLen;
                    
                    //生日长度
                    attr->birthdayLen = output[index];
                    index++;
                    
                    //生日
                    memcpy(attr->birthday, &output[index], attr->birthdayLen);
                    index += attr->birthdayLen;
                    
                    //星座
                    attr->constellation = output[index];
                    index++;
                    
                    //性别
                    attr->sex = output[index];
                    index++;
                    
                    //语速
                    attr->speakSpeed = output[index];
                    index++;
                    
                    //音色
                    attr->speakType = output[index];
                    index++;
                    
                    status = 0;
                }
            }
        }
        
        
    }
    

    return status;
}

/***********************************************************************************************/
//  @Description                    : 设置机器人属性
//  @param type                     : 设置的机器人属性类型 0--机器人名字 1--管理员姓名 2--性别 3--星座 4--生日 5--口头禅 6--音色 7--语速
//  @param value                    : 设置的机器人属性值
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int SetRobotAttr(RobotCtrl *pThis, int type, char *value)
{
    char cmd[128] = {0};
    char output[4096] = {0};
    int ret = 0;
    int status = -1;
    int valueLen = 0;
    
    if(value == NULL)
    {
        return status;
    }
    valueLen = strlen(value);
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = valueLen+2;
    cmd[2] = APP_MANAGE_CMD_ATTR_SETUP;
    cmd[3] = type;
    memcpy(&cmd[4], value, valueLen);
    cmd[valueLen+4] = Lrc(cmd, valueLen+4);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, valueLen+5, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, valueLen+5, output, 1);
    }
    if(ret >= 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if((output[0] == ROBOT_CMD_RSP_HEAD) && ((unsigned char)output[2] == (unsigned char)APP_MANAGE_CMD_ATTR_SETUP))
            {
                status = output[3];
            }
        }
    }
    
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 设置机器人属性
//  @param audioCount               : 脚本中包含的音频数量
//  @param audioInfo                : 脚本中包含的音频信息列表   【音频文件ID/音频文件名长度/音频文件名】
//  @param scriptInfo               : 脚本信息内容 中间用逗号分隔 【脚本名字,脚本内容,脚本时长】
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int PushScript(RobotCtrl *pThis, int audioCount, char *audioInfo, int audioInfoLen, char *scriptInfo, int scriptInfoLen)
{
    char cmd[1024] = {0};
    char output[4096] = {0};
    int ret = 0;
    int status = -1;
    int index = 0;
    int len = 0;
    
    if(audioInfo == NULL)
    {
        return status;
    }
    
    if(audioInfo == NULL)
    {
        return status;
    }
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN;
    len = audioInfoLen+scriptInfoLen+6;
    cmd[1] = (len&0xFF00)>>8;
    cmd[2] = len&0x00FF;
    cmd[3] = APP_MANAGE_CMD_PUSH_SCRIPT;
    cmd[4] = 1;     //IOS只有远程推送
    cmd[5] = (audioCount&0xFF000000)>>24;
    cmd[6] = (audioCount&0x00FF0000)>>16;
    cmd[7] = (audioCount&0x0000FF00)>>8;
    cmd[8] = (audioCount&0x000000FF);
    index = 9;
    
    memcpy(&cmd[index], audioInfo, audioInfoLen);
    index += audioInfoLen;
    
    memcpy(&cmd[index], scriptInfo, scriptInfoLen);
    index += scriptInfoLen;

    cmd[index++] = Lrc(cmd, index);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, index, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, index, output, 1);
    }
    if(ret >= 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if((output[0] == ROBOT_CMD_RSP_HEAD) && ((unsigned char)output[2] == (unsigned char)APP_MANAGE_CMD_PUSH_SCRIPT))
            {
                status = output[3];
            }
        }
    }
    
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 获取机器人属性
//  @param attr                     : 机器人返回的属性
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int QueryScript(RobotCtrl *pThis, RobotScript *scriptList)
{
    char cmd[128] = {0};
    char output[4096] = {0};
    int ret = 0;
    int status = -1;
    
    if(scriptList == NULL)
    {
        return status;
    }
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 1;
    cmd[2] = APP_MANAGE_CMD_QUERY_SCRIPT;
    cmd[3] = Lrc(cmd, 3);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        ret = RobotConn_SendCmd(&pThis->roboConn, cmd, 4, output, 1);
    }
    else
    {
        ret = RequestRobotCtrl(pThis, cmd, 4, output, 1);
    }
    if(ret > 5)
    {
        //判断检验值
        if(Lrc(output, ret) == 0)
        {
            //判断数据返回头
            if(output[0] == ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN)
            {
                //判断长度
                if(output[3] == (char)APP_MANAGE_CMD_QUERY_SCRIPT)
                {
                    char *p = &output[5];
                    char *pTmp = NULL;
                    int index = 0;
                    
                    while((pTmp = strsep(&p, ",")) != NULL)
                    {
                        char *pItem = NULL;
                        
                        //ID
                        pItem = strsep(&pTmp, "#");
                        if(pItem == NULL)
                        {
                            continue;
                        }
                        scriptList[index].id = atoi(pItem);
                        
                        //name
                        pItem = strsep(&pTmp, "#");
                        if(pItem == NULL)
                        {
                            continue;
                        }
                        strcpy(scriptList[index].name, pItem);
                        
                        //time
                        pItem = strsep(&pTmp, "#");
                        if(pItem == NULL)
                        {
                            continue;
                        }
                        strcpy(scriptList[index].time, pItem);
                        
                        //date
                        pItem = strsep(&pTmp, "#");
                        if(pItem == NULL)
                        {
                            continue;
                        }
                        strcpy(scriptList[index].date, pItem);
                        
                        
                        index++;
                    }
                    
                    status = 0;
                }
            }
        }
        
        
    }
    
    
    return status;
}


/***********************************************************************************************/
//  @Description                    : 执行脚本
//  @param type                     : 操作类型 0--执行脚本 1--删除脚本 2--停止执行 3--暂停执行 4--恢复执行
//  @param id                       : 脚本ID
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static void ExecScript(RobotCtrl *pThis, int type, int id)
{
    char cmd[128] = {0};
    
    //组命令数据
    cmd[0] = ROBOT_CMD_REQUEST_HEAD;
    cmd[1] = 3;
    cmd[2] = APP_NANAGE_CMD_EXEC_SCRIPT;
    cmd[3] = (unsigned char)type;
    cmd[4] = (unsigned char)((id&0xFF000000)>>24);
    cmd[5] = (unsigned char)((id&0x00FF0000)>>16);
    cmd[6] = (unsigned char)((id&0x0000FF00)>>8);
    cmd[7] = (unsigned char)(id&0x000000FF);
    cmd[8] = Lrc(cmd, 8);
    
    //发送数据
    if(pThis->isRemoteControl == NEAR_CONTROL_MODE)
    {
        RobotConn_SendCmd(&pThis->roboConn, cmd, 9, NULL, 0);
    }
    else
    {
        RequestRobotCtrl(pThis, cmd, 9, NULL, 0);
    }
}


/***********************************************************************************************/
//  @Description                    : 获取短信验证码
//  @param mobileNo                 : 手机号码
//  @param type                     : 获取验证验证码的类型
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int GetMobileCode(RobotCtrl *pThis, char *mobileNo, int type)
{
    cJSON *root = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if(mobileNo == NULL)
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "get_verification_code");
    cJSON_AddStringToObject(root, "phone", mobileNo);
    cJSON_AddNumberToObject(root, "type", type);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, (int)strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;

        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 用户注册
//  @param mobileNo                 : 手机号码
//  @param pass                     : 密码
//  @param verifyCode               : 短信验证码
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int UserRegister(RobotCtrl *pThis, char *mobileNo, char *pass, char *verifyCode)
{
    cJSON *root = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if((mobileNo == NULL) || (pass == NULL) || (verifyCode == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "register");
    cJSON_AddStringToObject(root, "user_name", mobileNo);
    cJSON_AddStringToObject(root, "passwd", pass);
    cJSON_AddStringToObject(root, "verify_code", verifyCode);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 用户登陆
//  @param mobileNo                 : 手机号码
//  @param pass                     : 密码
//  @param verifyCode               : 短信验证码
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int UserLogon(RobotCtrl *pThis, char *mobileNo, char *pass, char *pToken,char *pShowDemo, int *robotCount, char **robotId, int **admin, int **online)
{
    cJSON *root = NULL;
    char *output = NULL;
    char recvBuf[10*1024] = {0};
    int ret = 0;
    int status = -1;
    
    if((mobileNo == NULL) || (pass == NULL))
    {
        return -1;
    }
    
    if((pToken == NULL) || (robotCount == NULL) || (robotId == NULL) || (admin == NULL) || (online == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "login");
    cJSON_AddStringToObject(root, "user_name", mobileNo);
    cJSON_AddStringToObject(root, "passwd", pass);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    
    printf("output++++++-------%s",output);
    printf("revcBuf+++++__-----%s",recvBuf);
    
    
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
                if(status == 0)
                {
                    cJSON *pContent = cJSON_GetObjectItem(rsp, "content");
                    if(pContent != NULL)
                    {
                        cJSON *pTokenJSON = NULL;
                        cJSON *pRobotCountJSON = NULL;
                        cJSON *pRobotIdJSON = NULL;
                        cJSON *pAdminJSON = NULL;
                        cJSON *pOnlineJSON = NULL;
                        cJSON *pRobotShowDemoJSON = NULL;
                        
                        //Token
                        pTokenJSON = cJSON_GetObjectItem(pContent, "token");
                        if(NULL != pTokenJSON)
                        {
                            strcpy(pToken, pTokenJSON->valuestring);
                        }
                        
                        //showdemo
                        pRobotShowDemoJSON = cJSON_GetObjectItem(pContent, "showdemo");
                        if (NULL != pRobotShowDemoJSON) {
                            
                            printf("pShowDemo ++++ ----- %s",pShowDemo);
                            strcpy(pShowDemo, pRobotShowDemoJSON->valuestring);
                            printf("pShowDemo ++++ ----- %s",pShowDemo);
                        }
                        
                        //Robot count
                        pRobotCountJSON = cJSON_GetObjectItem(pContent, "robot_count");
                        if(NULL != pRobotCountJSON)
                        {
                            *robotCount = pRobotCountJSON->valueint;
                        }
                        
                        //robot id array
                        pRobotIdJSON = cJSON_GetObjectItem(pContent, "robot_id");
                        if(NULL != pRobotIdJSON)
                        {
                            int i = 0;
                            cJSON *idList = pRobotIdJSON->child;
                            
                            while(idList != NULL)
                            {
                                strcpy(robotId[i], idList->valuestring);
                                
                                i++;
                                idList = idList->next;
                            }
                        }
                        
                        //robot admin flag
                        pAdminJSON = cJSON_GetObjectItem(pContent, "admin");
                        if(NULL != pAdminJSON)
                        {
                            int i = 0;
                            cJSON *idList = pAdminJSON->child;
                            
                            while(idList != NULL)
                            {
                                char *value = idList->valuestring;
                                *admin[i] = atoi(value);
                                
                                i++;
                                idList = idList->next;
                            }
                        }
                        
                        //robot online flag
                        pOnlineJSON = cJSON_GetObjectItem(pContent, "online");
                        if(NULL != pOnlineJSON)
                        {
                            int i = 0;
                            cJSON *idList = pOnlineJSON->child;
                            
                            while(idList != NULL)
                            {
                                char *value = idList->valuestring;
                                *online[i] = atoi(value);
                                
                                i++;
                                idList = idList->next;
                            }
                        }
                    }
                    
//                    printf("content+++++++++++++++  \(pContent)");
//                    printf("content +++++++ %ld",pContent);
                }
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 用户登出
//  @param mobileNo                 : 手机号码
//  @param token                    :
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int UserLogonOut(RobotCtrl *pThis, char *mobileNo, char *token)
{
    cJSON *root = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if(mobileNo == NULL)
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "logout");
    cJSON_AddStringToObject(root, "user_name", mobileNo);
    cJSON_AddStringToObject(root, "token", token);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 用户绑定
//  @param mobileNo                 : 手机号码
//  @param robotId                  : 机器人唯一序列号
//  @param token                    : Token
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int UserBind(RobotCtrl *pThis, char *mobileNo, char *robotId, char *token, int admin)
{
    cJSON *root = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if(mobileNo == NULL)
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "bind");
    cJSON_AddStringToObject(root, "user_name", mobileNo);
    cJSON_AddStringToObject(root, "robot_id", robotId);
    cJSON_AddStringToObject(root, "token", token);
    if(admin == 0)
    {
        cJSON_AddStringToObject(root, "admin", "0");
    }
    else
    {
        cJSON_AddStringToObject(root, "admin", "1");
    }
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 用户解绑
//  @param mobileNo                 : 手机号码
//  @param robotId                  : 机器人唯一序列号
//  @param token                    : Token
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int UnBind(RobotCtrl *pThis, char *mobileNo, char *robotId, char *token)
{
    cJSON *root = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if(mobileNo == NULL)
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "unbind");
    cJSON_AddStringToObject(root, "user_name", mobileNo);
    cJSON_AddStringToObject(root, "robot_id", robotId);
    cJSON_AddStringToObject(root, "token", token);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}


/***********************************************************************************************/
//  @Description                    : 获取用户关联的机器人列表
//  @param mobileNo                 : 手机号码
//  @param token                    : Token
//  @param robotCount               : 返回的机器数
//  @param robotId                  : 返回的机器人ID数组
//  @param admin                    : 返回的机器人是否为管理员
//  @param online                   : 返回的机器人是否在线
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int QueryRobotList(RobotCtrl *pThis, char *mobileNo, char *pToken, int *robotCount, char **robotId, int **admin, int **online)
{
    cJSON *root = NULL;
    cJSON *content = NULL;
    char *output = NULL;
    char recvBuf[4096] = {0};
    int ret = 0;
    int status = -1;
    
    if((mobileNo == NULL) || (pToken == NULL))
    {
        return -1;
    }
    
    if((pToken == NULL) || (robotCount == NULL) || (robotId == NULL) || (admin == NULL) || (online == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    content = cJSON_CreateObject();
    if((NULL == root) || (NULL == content))
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "message");
    cJSON_AddStringToObject(root, "user_name", mobileNo);
    cJSON_AddStringToObject(root, "token", pToken);
    cJSON_AddStringToObject(content, "method", "query");
    cJSON_AddStringToObject(content, "param", "robot_bind");
    cJSON_AddItemToObject(root, "content", content);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
                if(status == 0)
                {
                    cJSON *pContent = cJSON_GetObjectItem(rsp, "content");
                    if(pContent != NULL)
                    {
                        cJSON *pRobotCountJSON = NULL;
                        cJSON *pRobotIdJSON = NULL;
                        cJSON *pAdminJSON = NULL;
                        cJSON *pOnlineJSON = NULL;
                        
                        
                        //Robot count
                        pRobotCountJSON = cJSON_GetObjectItem(pContent, "count");
                        if(NULL != pRobotCountJSON)
                        {
                            *robotCount = pRobotCountJSON->valueint;
                        }
                        
                        //robot id array
                        pRobotIdJSON = cJSON_GetObjectItem(pContent, "robots");
                        if(NULL != pRobotIdJSON)
                        {
                            int i = 0;
                            cJSON *idList = pRobotIdJSON->child;
                            
                            while(idList != NULL)
                            {
                                strcpy(robotId[i], idList->valuestring);
                                
                                i++;
                                idList = idList->next;
                            }
                        }
                        
                        //robot admin flag
                        pAdminJSON = cJSON_GetObjectItem(pContent, "admin");
                        if(NULL != pAdminJSON)
                        {
                            int i = 0;
                            cJSON *idList = pAdminJSON->child;
                            
                            while(idList != NULL)
                            {
                                char *value = idList->valuestring;
                                *admin[i] = atoi(value);
                                
                                i++;
                                idList = idList->next;
                            }
                        }
                        
                        //robot online flag
                        pOnlineJSON = cJSON_GetObjectItem(pContent, "online");
                        if(NULL != pOnlineJSON)
                        {
                            int i = 0;
                            cJSON *idList = pOnlineJSON->child;
                            
                            while(idList != NULL)
                            {
                                char *value = idList->valuestring;
                                *online[i] = atoi(value);
                                
                                i++;
                                idList = idList->next;
                            }
                        }
                    }
                }
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}


/***********************************************************************************************/
//  @Description                    : 获取机器人关联的用户列表
//  @param mobileNo                 : 手机号码
//  @param token                    : Token
//  @param robotId                  : 机器人ID
//  @param userCount                : 返回的机器数
//  @param adminCount               : 返回的管理员的个数
//  @param userList                 : 返回的用户ID数组
//  @param adminList                : 返回的机器人是否为管理员, 只能有一个管理员
//  @return                         : 0--成功 -1--失败 其他--服务器返回的错误码
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int QueryUserList(RobotCtrl *pThis, char *mobileNo, char *pToken, char *robotId, int *userCount, int *adminCount, char **userList, int **adminList)
{
    cJSON *root = NULL;
    cJSON *content = NULL;
    char *output = NULL;
    char recvBuf[4096] = {0};
    int ret = 0;
    int status = -1;
    
    if((mobileNo == NULL) || (pToken == NULL) || (robotId == NULL))
    {
        return -1;
    }
    
    if((userCount == NULL) || (adminCount == NULL) || (userList == NULL) || (adminList == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    content = cJSON_CreateObject();
    if((NULL == root) || (NULL == content))
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "message");
    cJSON_AddStringToObject(root, "user_name", mobileNo);
    cJSON_AddStringToObject(root, "token", pToken);
    cJSON_AddStringToObject(content, "method", "query");
    cJSON_AddStringToObject(content, "param", "user_bind");
    cJSON_AddStringToObject(content, "robot_id", robotId);
    cJSON_AddItemToObject(root, "content", content);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
//    printf("output++++++++++  %s",output);
//    printf("revcBuf+++++++++  %s",recvBuf);
    
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
                if(status == 0)
                {
                    cJSON *pContent = cJSON_GetObjectItem(rsp, "content");
                    if(pContent != NULL)
                    {
                        cJSON *pUserCountJSON = NULL;
                        cJSON *pAdminCountJSON = NULL;
                        cJSON *pUsersJSON = NULL;
                        cJSON *pAdminJSON = NULL;
                        
                        
                        //Robot count
                        pUserCountJSON = cJSON_GetObjectItem(pContent, "count");
                        if(NULL != pUserCountJSON)
                        {
                            *userCount = pUserCountJSON->valueint;
                        }
                        
                        //Admin count
                        pAdminCountJSON = cJSON_GetObjectItem(pContent, "admin_count");
                        if(NULL != pAdminCountJSON)
                        {
                            *adminCount = pAdminCountJSON->valueint;
                        }
                        
                        //user array
                        pUsersJSON = cJSON_GetObjectItem(pContent, "users");
                        if(NULL != pUsersJSON)
                        {
                            int i = 0;
                            cJSON *idList = pUsersJSON->child;
                            
                            while(idList != NULL)
                            {
                                strcpy(userList[i], idList->valuestring);
                                
                                i++;
                                idList = idList->next;
                            }
                        }
                        
                        //robot admin flag
                        pAdminJSON = cJSON_GetObjectItem(pContent, "admin");
                        if(NULL != pAdminJSON)
                        {
                            int i = 0;
                            cJSON *idList = pAdminJSON->child;
                            
                            while(idList != NULL)
                            {
                                char *value = idList->valuestring;
                                
                                printf("value ++++++++++ %s",value);
                                *adminList[i] = atoi(value);
                                
                                i++;
                                idList = idList->next;
                            }
                        }
                    }
                }
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 重置密码
//  @param account                  : 用户名
//  @param verifyCode               : 短信验证码
//  @param newPass                  : 重置的新密码
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int ResetPass(RobotCtrl *pThis, char *account, char *verifyCode, char *newPass)
{
    cJSON *root = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if((account == NULL) || (verifyCode == NULL) || (newPass == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "reset_pass");
    cJSON_AddStringToObject(root, "user_name", account);
    cJSON_AddStringToObject(root, "verify_code", verifyCode);
    cJSON_AddStringToObject(root, "new_pass", newPass);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 修改密码
//  @param account                  : 用户名
//  @param verifyCode               : 短信验证码
//  @param newPass                  : 重置的新密码
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int ChangePass(RobotCtrl *pThis, char *account, char *token, char *oldPass, char *newPass)
{
    cJSON *root = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if((account == NULL) || (token == NULL) || (oldPass == NULL) || (newPass == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "change_pass");
    cJSON_AddStringToObject(root, "user_name", account);
    cJSON_AddStringToObject(root, "token", token);
    cJSON_AddStringToObject(root, "old_pass", oldPass);
    cJSON_AddStringToObject(root, "new_pass", newPass);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 用户反馈
//  @param account                  : 用户名
//  @param token                    : 服务器返回的Token
//  @param text                     : 反馈的文本内容
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int UserFeedback(RobotCtrl *pThis, char *account, char *token, char *text)
{
    cJSON *root = NULL;
    cJSON *content = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if((account == NULL) || (token == NULL) || (text == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    content = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "message");
    cJSON_AddStringToObject(root, "user_name", account);
    cJSON_AddStringToObject(root, "token", token);
    cJSON_AddStringToObject(content, "method", "feedback");
    cJSON_AddStringToObject(content, "text", text);
    cJSON_AddItemToObject(root, "content", content);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 获取用户信息
//  @param account                  : 用户名
//  @param token                    : 服务器返回的Token
//  @param nickName                 : 服务器返回的昵称
//  @param sex                      : 服务器返回的机器人性别 0--男小盒 1--莉莉盒
//  @param registDate               : 服务器返回的机器人注册日期
//  @param registDate               : 服务器返回的机器人生日
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int GetUserInfo(RobotCtrl *pThis, char *account, char *token, char *nickName, int *sex, char *registDate, char *birthday)
{
    cJSON *root = NULL;
    cJSON *content = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if((account == NULL) || (token == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    content = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "message");
    cJSON_AddStringToObject(root, "user_name", account);
    cJSON_AddStringToObject(root, "token", token);
    cJSON_AddStringToObject(content, "method", "get_user_info");
    cJSON_AddItemToObject(root, "content", content);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
                if(status == 0)
                {
                    cJSON *pContent = cJSON_GetObjectItem(rsp, "content");
                    if(pContent != NULL)
                    {
                        cJSON *pNickName = NULL;
                        cJSON *pSex = NULL;
                        cJSON *pRegistDate = NULL;
                        cJSON *pBirthday = NULL;
                        
                        
                        //昵称
                        pNickName = cJSON_GetObjectItem(pContent, "nick_name");
                        if(NULL != pNickName)
                        {
                            strcpy(nickName, pNickName->valuestring);
                        }
                        
                        //性别
                        pSex = cJSON_GetObjectItem(pContent, "sex");
                        if(NULL != pSex)
                        {
                            if(strcmp(pSex->valuestring, "man") == 0)
                            {
                                *sex = 0;
                            }
                            else
                            {
                                *sex = 1;
                            }
                        }
                        
                        //注册日期
                        pRegistDate = cJSON_GetObjectItem(pContent, "regist_date");
                        if(NULL != pRegistDate)
                        {
                            strcpy(registDate, pRegistDate->valuestring);
                        }
                        
                        //生日
                        pBirthday = cJSON_GetObjectItem(pContent, "birthday");
                        if(NULL != pBirthday)
                        {
                            strcpy(birthday, pBirthday->valuestring);
                        }
                    }
                }
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 用户反馈
//  @param account                  : 用户名
//  @param token                    : 服务器返回的Token
//  @param infoType                 : 信息类型串 "nick_name" / "sex" / "birthday"
//  @param infoValue                : 信息类型串 "xxxxxx" / "man/female" / "1993-08-05"
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int SetUserInfo(RobotCtrl *pThis, char *account, char *token, char *infoType, char *infoValue)
{
    cJSON *root = NULL;
    cJSON *content = NULL;
    char *output = NULL;
    char recvBuf[512] = {0};
    int ret = 0;
    int status = -1;
    
    if((account == NULL) || (token == NULL) || (infoType == NULL) || (infoValue == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    content = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "message");
    cJSON_AddStringToObject(root, "user_name", account);
    cJSON_AddStringToObject(root, "token", token);
    cJSON_AddStringToObject(content, "method", "set_user_info");
    cJSON_AddStringToObject(content, "info_type", infoType);
    cJSON_AddStringToObject(content, "info_value", infoValue);
    cJSON_AddItemToObject(root, "content", content);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}


/***********************************************************************************************/
//  @Description                    : 用户反馈
//  @param account                  : 用户名
//  @param token                    : 服务器返回的Token
//  @param QAList                   : 服务器返回的QA常见问题列表
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int GetQA(RobotCtrl *pThis, char *account, char *token, char **QList, char**AList)
{
    cJSON *root = NULL;
    cJSON *content = NULL;
    char *output = NULL;
    char recvBuf[2048] = {0};
    int ret = 0;
    int status = -1;
    
    if((account == NULL) || (token == NULL) || (QList == NULL) || (AList == NULL))
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    content = cJSON_CreateObject();
    if(NULL == root)
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "message");
    cJSON_AddStringToObject(root, "user_name", account);
    cJSON_AddStringToObject(root, "token", token);
    cJSON_AddStringToObject(content, "method", "get_faq");
    cJSON_AddItemToObject(root, "content", content);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
                if(status == 0)
                {
                    cJSON *pContent = cJSON_GetObjectItem(rsp, "content");
                    if(pContent != NULL)
                    {
                        cJSON *pQuestionList = NULL;
                        cJSON *pQList = NULL;
                        cJSON *pAList = NULL;
                        
                        //QA列表
                        pQuestionList = cJSON_GetObjectItem(pContent, "question_list");
                        if(NULL != pQuestionList)
                        {
                            int i = 0;
                            cJSON *idList = pQuestionList->child;
                            
                            while(idList != NULL)
                            {
                                pQList = cJSON_GetObjectItem(idList, "question");
                                if(NULL != pQList)
                                {
                                    strcpy(QList[i], pQList->valuestring);
                                }
                                pAList = cJSON_GetObjectItem(idList, "answer");
                                if(NULL != pAList)
                                {
                                    strcpy(AList[i], pAList->valuestring);
                                }
                                
                                i++;
                                idList = idList->next;
                            }
                        }
                    }
                }
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}



/***********************************************************************************************/
//  @Description                    : 配置网络--发送路由器的SSID和PASS给机器人
//  @param ssid                     : 路由器的SSID
//  @param pass                     : 路由器PASS
//  @param rspRobotSN               : 机器人返回的机器人序列号
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int RobotWifiSetup(RobotCtrl *pThis, char *ssid, char *pass, char* rspRobotSN)
{
    char cmd[128] = {0};
    char output[128] = {0};
    int ret = 0;
    int status = -1;
    
    if((ssid == NULL) || (pass == NULL) || (rspRobotSN == NULL))
    {
        return -1;
    }
    
    //组命令数据
    if(strlen(pass) > 0)
    {
        sprintf(cmd, "STA\"%s\"%s", ssid, pass);
    }
    else
    {
        sprintf(cmd, "STA\"%s\"NULL", ssid);
    }
    
    //发送数据   机器人作为热点时通讯
    ret = RobotConn_RequestRobot(&pThis->roboConn, cmd, strlen(cmd), output, 1);
    if(ret > 0)
    {
        if(memcmp(output, "OK", 2) != 0)
        {
            status = -2;
        }
        else
        {
            strcpy(rspRobotSN, &output[3]);
            status = 0;
        }
        
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 查询配置的机器人联状态
//  @param mobileNo                 : 手机号码
//  @param token                    : Token
//  @param robotCount               : 返回的机器数
//  @param robotId                  : 返回的机器人ID数组
//  @param admin                    : 返回的机器人是否为管理员
//  @param online                   : 返回的机器人是否在线
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
static int QueryRobotStatus(RobotCtrl *pThis, char *account, char *token, char *robotSN, char *robotLanIp, char *robotConnSSID, char *robotMac)
{
    cJSON *root = NULL;
    cJSON *content = NULL;
    char *output = NULL;
    char recvBuf[4096] = {0};
    int ret = 0;
    int status = -1;
    
    if((account == NULL) || (token == NULL) || (robotSN == NULL))
    {
        return -1;
    }
    
//    if((robotLanIp == NULL) || (robotConnSSID == NULL) || (robotMac == NULL))
    if(robotLanIp == NULL)
    {
        return -1;
    }
    
    root = cJSON_CreateObject();
    content = cJSON_CreateObject();
    if((NULL == root) || (NULL == content))
    {
        return -1;
    }
    cJSON_AddStringToObject(root, "cmd", "message");
    cJSON_AddStringToObject(root, "user_name", account);
    cJSON_AddStringToObject(root, "token", token);
    cJSON_AddStringToObject(content, "method", "connect_info");
    cJSON_AddStringToObject(content, "robot_id", robotSN);
    cJSON_AddItemToObject(root, "content", content);
    
    output = cJSON_Print(root);
    if(output == NULL)
    {
        cJSON_Delete(root);
        return -1;
    }
    
//    printf("请求wifi数据: \(output) \(recvBuf)");
    
    //发送数据
    ret = RobotConn_RequestServer(&pThis->roboConn, output, strlen(output), recvBuf, 1);
    
//    printf("请求wifi数据: \(output)");
    if(ret > 0)
    {
        //接收数据的处理
        cJSON *rsp = NULL;
        cJSON *pStatus = NULL;
        
        if((rsp = cJSON_Parse(recvBuf)) != NULL)
        {
            pStatus = cJSON_GetObjectItem(rsp, "status");
            if(pStatus != NULL)
            {
                status = pStatus->valueint;
                if(status == 0)
                {
                    cJSON *pContent = cJSON_GetObjectItem(rsp, "content");
                    if(pContent != NULL)
                    {
                        cJSON *pApJSON = NULL;
                        cJSON *pSSIDJSON = NULL;
                        cJSON *pIpAddrJSON = NULL;
                        
                        //机器人所连接的热点的mac地址
                        pApJSON = cJSON_GetObjectItem(pContent, "ap");
                        if(NULL != pApJSON)
                        {
                            strcpy(robotMac, pApJSON->valuestring);
                        }
                        
                        //机器人所连接的热点
                        pSSIDJSON = cJSON_GetObjectItem(pContent, "ssid");
                        if(NULL != pSSIDJSON)
                        {
                            strcpy(robotConnSSID, pSSIDJSON->valuestring);
                        }
                        
                        //机器人的局域网IP地址
                        //机器人所连接的热点
                        pIpAddrJSON = cJSON_GetObjectItem(pContent, "ipaddr");
                        if(NULL != pIpAddrJSON && (NULL != pIpAddrJSON->valuestring))
                        {
                            strcpy(robotLanIp, pIpAddrJSON->valuestring);
                        }
                    }
                }
            }
        }
    }
    
    //释放内存
    cJSON_Delete(root);
    if(output != NULL)
    {
        free(output);
        output = NULL;
    }
    
    return status;
}

/***********************************************************************************************/
//  @Description                    : 设置IP端口
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
void RobotCtrl_SetIpPort(RobotCtrl *pThis, char *ip, int port)
{
	RobotConn_SetIp(&pThis->roboConn, ip, port);
}

/***********************************************************************************************/
//  @Description                    : 获取单例
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
void RobotCtrl_GetRobotCtrl(RobotCtrl **ppThis)
{
    *ppThis = &robotCtrl;
}

/***********************************************************************************************/
//  @Description                    : 初始化
//  @param                          : None
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
void RobotCtrl_Initial(RobotCtrl **ppThis)
{
    RobotCtrl *pThis = &robotCtrl;
    *ppThis = &robotCtrl;
    
#if 0
    int len = 0;
    char test[128] = {0};
    char buf[128] = {0};
    //buf[0] = 0x3E;
    //buf[1] = 0x01;
    //buf[2] = 0xA0;
    //buf[3] = 0x9F;

    memcpy(buf, "\x3f\x00\x06\x2B\x31\x33\x23\x31\x30\x32", 10);
    b64_encode(buf, test, 10);
    memset(buf, 0x00, sizeof(buf));
    len = b64_decode(test, buf, strlen(test));
    
    memset(buf, 0x00, sizeof(buf));
    memset(test, 0x00, sizeof(test));
    strcpy(test, "PA+gAEIxMENONjY3MDA1MGSL");
    len = b64_decode(test, buf, strlen(test));
#endif
    
	RobotConn_Initial(&pThis->roboConn);

    pThis->study = Study;
    pThis->connRobot = ConnRobot;
	pThis->forward = Forward;
	pThis->fallback = Fallback;
	pThis->turn = Turn;
	pThis->nod = Nod;
	pThis->shake = Shake;
	pThis->lookUp = LookUp;
	pThis->lookDown = LookDown;
	pThis->lookLeft = LookLeft;
	pThis->lookRight = LookRight;
	pThis->lookForward = LookForward;
	pThis->stopRun = StopRun;
	pThis->clockwiseWhirl = ClockwiseWhirl;
	pThis->counterClockwiseWhirl = CounterClockwiseWhirl;
	pThis->sst = SST;
	pThis->setRunMode = SetRunMode;
	pThis->setRobotEye = SetRobotEye;
	pThis->execCombActions = CombActions;
	pThis->setRobotEar = SetRobotEar;
	pThis->musicCtrl = MusicCtrl;
	pThis->storyCtrl = StoryCtrl;
	pThis->stopAudioPlay = StopAudioPlay;
    pThis->queryRobotMusicList = QueryRobotMusicList;
    
    pThis->queryRobotWifiList = QueryRobotWifiList;
    pThis->connectSpecifiedWifi = ConnectSpecifiedWifi;
    pThis->reSetWifiConfig = ReSetWifiConfig;
    
    pThis->playRobotMusicByIndex = PlayRobotMusicByIndex;
    pThis->tickRequest = TickRequeset;
    pThis->cute = Cute;
    pThis->volumeCtrl = VolumeCtrl;
    pThis->setAlarm = SetAlarm;
    pThis->handUp = HandUp;
    pThis->handBack = HandBack;
    pThis->handShake = HandShake;
    pThis->handBothShake = HandBothShake;
    pThis->getAlarmList = GetAlarmList;
    pThis->updateAlarmItem = UpdateAlarmItem;
    pThis->deleteAlarmItem = DeleteAlarmItem;
    pThis->setVolume = SetVolume;
    pThis->sleepCtrl = SleepCtrl;
    pThis->jokeCtrl = JokeCtrl;
    pThis->getRobotAttr = GetRobotAttr;
    pThis->clockwiseWhirlByTime = ClockwiseWhirlByTime;
    pThis->counterclockwiseWhirlByTime = CounterClockwiseWhirlByTime;
    pThis->setRobotAttr = SetRobotAttr;
    pThis->playUrl = PlayUrl;
    pThis->pushScript = PushScript;
    pThis->queryScript = QueryScript;
    pThis->execScript = ExecScript;
    pThis->deleteScriptMulti = DeleteScriptMulti;
    // 新添加接口
	pThis->playerGetAlbumList = PlayerGetAlbumList;
	pThis->playerStart = PlayerStart;
	pThis->playerCtrl = PlayerCtrl;
	pThis->playerQueryDirecMusicList = PlayerQueryDirecMusicList;
    
    pThis->getMobileCode = GetMobileCode;
    pThis->userRegister = UserRegister;
    pThis->userLogon = UserLogon;
    pThis->userLogonOut = UserLogonOut;
    pThis->userBind = UserBind;
    pThis->unBind = UnBind;
    pThis->queryRobotList = QueryRobotList;
    pThis->queryRobotMusicList = QueryRobotMusicList;
    pThis->queryUserList = QueryUserList;
    pThis->resetPass = ResetPass;
    pThis->changePass = ChangePass;
    pThis->userFeedback = UserFeedback;
    pThis->getUserInfo = GetUserInfo;
    pThis->setUserInfo = SetUserInfo;
    pThis->getQA = GetQA;
    
    pThis->robotWifiSetup = RobotWifiSetup;
    pThis->queryRobotStatus = QueryRobotStatus;
}
