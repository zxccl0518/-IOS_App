              /***********************************************************************************************
** File Name:      RobotConn.h                                                                 *
** Author:         andy.wang                                                                   *
** Date:           26/02/2016                                                                  *
** Copyright:      2016 RoboSys, Incorporated. All Rights Reserved.                            *
** Description:    机器人Socket通讯类                                                            *
************************************************************************************************/
#include "RobotConn.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#include "stdlib.h"
#include "netdb.h"

/***********************************************************************************************/
//  @Description                    : 与机器人通讯
//  @param cmd                      : 命令
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
int RobotConn_SendCmd(RobotConn *pThis, char *cmd, int len, char *output, int recvFlag)
{
    int ret = 0;
    
    int sclient;
    struct addrinfo hints, *res = NULL;
    char portStr[16] = {0};
    
    memset(&hints, 0, sizeof(hints));
    
    snprintf(portStr, 10, "%d", pThis->robotPort);
    
    if(cmd == NULL)
    {
        return -1;
    }
    
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_CANONNAME;
    
    ret = getaddrinfo(pThis->robotIp, portStr, &hints, &res);
//    printf("ret ======== %d",ret);
    
    if(ret != 0)
    {
        return -1;
    }
    
    //sclient 1
    sclient = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    
    
    if(sclient < 0)
    {
        return -1;
    }
    
    struct timeval timeout = {0};
    timeout.tv_sec = SOCKET_SEND_TIMEOUT;       //设置发送超时时间
    setsockopt(sclient, SOL_SOCKET, SO_SNDTIMEO, (const char*)&timeout, sizeof(timeout));
    
    if (connect(sclient, res->ai_addr, res->ai_addrlen) < 0)
    {
        close(sclient);
        return -1;
    }
    
    send(sclient, cmd, len, 0);
    
    if(recvFlag == 1)
    {
        char recData[10*1024] = {0};
        struct timeval timeout = {0};
        
        timeout.tv_sec = SOCKET_RECV_TIMEOUT;       //设置接收超时时间
        setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof(timeout));
        
        int recvLen = 0;
        int count = 0;
        while((recvLen = recv(sclient, recData, 10*1024, 0)) > 0)
        {
            memcpy(&output[count], recData, recvLen);
            count += recvLen;
            ret = count;
        }
//        printf("recvLen = %d  count = %d ",recvLen,count);
        
    }
    
    close(sclient);
    return ret;
}

/***********************************************************************************************/
//  @Description                    : 与服务器通讯
//  @param cmd                      : 命令
//  @return                         : None
//  @Author: max.liu
//  Note:
/***********************************************************************************************/
int RobotConn_RequestServer_LY(RobotConn *pThis, char *cmd, int len, char *output, int recvFlag)
{
    int ret = 0;
    int sclient;
    struct sockaddr_in serAddr;
    
    struct addrinfo hints, *res = NULL;
    
    memset(&hints, 0, sizeof(hints));
    
    int i = 0;
    char *pSendBuf = NULL;
    
    if(cmd == NULL)
    {
        return -1;
    }
    
    pSendBuf = (char*)malloc(len+1);
    if(pSendBuf == NULL)
    {
        return -1;
    }
    memset(pSendBuf, 0x00, len+1);
    
    memcpy(pSendBuf, cmd, len);
    for(i = 0;i < len;i++)
    {
        if(pSendBuf[i] == '\n')
        {
            pSendBuf[i] = 0x20;
        }
    }
    pSendBuf[len] = '\n';
    
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_CANONNAME;
    
    ret = getaddrinfo(SERVER_DNS, "6781", &hints, &res);
    //    printf("getaddrinfo : ret=%d \n",ret);
    
    if(ret != 0)
    {
        return -1;
    }
    
    //sclient = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    sclient = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    //    printf("sclient : %d",sclient);
    if(sclient < 0)
    {
        if(pSendBuf != NULL)
        {
            free(pSendBuf);
            pSendBuf = NULL;
        }
        return -1;
    }
    
    //通过域名获取IP
#ifndef SERVER_DEBUG_MODE
    
#else
    struct timeval timeout = {0};
    timeout.tv_sec = SOCKET_SEND_TIMEOUT;       //设置发送超时时间
    setsockopt(sclient, SOL_SOCKET, SO_SNDTIMEO, (const char*)&timeout, sizeof(timeout));
    
    serAddr.sin_family = AF_INET;
    serAddr.sin_port = htons(SERVER_PORT);
    serAddr.sin_addr.s_addr = inet_addr(SERVER_DNS);
#endif
    
    if (connect(sclient, res->ai_addr, res->ai_addrlen) < 0)
    {
        close(sclient);
        if(pSendBuf != NULL)
        {
            free(pSendBuf);
            pSendBuf = NULL;
        }
        //        printf("connect  faild \n");
        return -1;
    }
    
    int ret2 = send(sclient, pSendBuf, len+1, 0);
    //    printf("ret2 : %d \n",ret2);
    
    if(recvFlag == 1)
    {
        static char recData[30*1024] = {0};
        struct timeval timeout = {0};
        
        timeout.tv_sec = SOCKET_RECV_TIMEOUT_LY;       //设置接收超时时间
        setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof(timeout));
        
        int recvLen = 0;
        int count = 0;
        while((recvLen = recv(sclient, recData, 30*1024, 0)) > 0)
        {
            memcpy(&output[count], recData, recvLen);
            count += recvLen;
            ret = count;
            
            //            printf("ret ======= +++++++ %d\n",ret);
        }
        //        printf("recvLen : %d \n",recvLen);
    }
    
    
    if(pSendBuf != NULL)
    {
        free(pSendBuf);
        pSendBuf = NULL;
    }
    close(sclient);
    return ret;
}

/***********************************************************************************************/
//  @Description                    : 与服务器通讯
//  @param cmd                      : 命令
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
int RobotConn_RequestServer(RobotConn *pThis, char *cmd, int len, char *output, int recvFlag)
{
    int ret = 0;
    int sclient;
    struct sockaddr_in serAddr;
    
    struct addrinfo hints, *res = NULL;
    
    memset(&hints, 0, sizeof(hints));
    
    int i = 0;
    char *pSendBuf = NULL;
    
    if(cmd == NULL)
    {
        return -1;
    }
    
    pSendBuf = (char*)malloc(len+1);
    if(pSendBuf == NULL)
    {
        return -1;
    }
    memset(pSendBuf, 0x00, len+1);
    
    memcpy(pSendBuf, cmd, len);
    for(i = 0;i < len;i++)
    {
        if(pSendBuf[i] == '\n')
        {
            pSendBuf[i] = 0x20;
        }
    }
    pSendBuf[len] = '\n';
    
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_CANONNAME;
    
    ret = getaddrinfo(SERVER_DNS, "6781", &hints, &res);
//    printf("getaddrinfo : ret=%d \n",ret);
    
    if(ret != 0)
    {
        return -1;
    }
    
    //sclient = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    sclient = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
//    printf("sclient : %d",sclient);
    if(sclient < 0)
    {
        if(pSendBuf != NULL)
        {
            free(pSendBuf);
            pSendBuf = NULL;
        }
        return -1;
    }
    
    //通过域名获取IP
#ifndef SERVER_DEBUG_MODE

#else
    struct timeval timeout = {0};
    timeout.tv_sec = SOCKET_SEND_TIMEOUT;       //设置发送超时时间
    setsockopt(sclient, SOL_SOCKET, SO_SNDTIMEO, (const char*)&timeout, sizeof(timeout));
    
    serAddr.sin_family = AF_INET;
    serAddr.sin_port = htons(SERVER_PORT);
    serAddr.sin_addr.s_addr = inet_addr(SERVER_DNS);
#endif
    
    if (connect(sclient, res->ai_addr, res->ai_addrlen) < 0)
    {
        close(sclient);
        if(pSendBuf != NULL)
        {
            free(pSendBuf);
            pSendBuf = NULL;
        }
//        printf("connect  faild \n");
        return -1;
    }
    
    int ret2 = send(sclient, pSendBuf, len+1, 0);
//    printf("ret2 : %d \n",ret2);
    
    if(recvFlag == 1)
    {
        static char recData[30*1024] = {0};
        struct timeval timeout = {0};
        
        timeout.tv_sec = SOCKET_RECV_TIMEOUT;       //设置接收超时时间
        setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof(timeout));
        
        int recvLen = 0;
        int count = 0;
        while((recvLen = recv(sclient, recData, 30*1024, 0)) > 0)
        {
            memcpy(&output[count], recData, recvLen);
            count += recvLen;
            ret = count;
            
//            printf("ret ======= +++++++ %d\n",ret);
        }
//        printf("recvLen : %d \n",recvLen);
    }
    
    
    if(pSendBuf != NULL)
    {
        free(pSendBuf);
        pSendBuf = NULL;
    }
    close(sclient);
    return ret;
}

/***********************************************************************************************/
//  @Description                    : 机器人作为热点时通讯
//  @param cmd                      : 命令
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
int RobotConn_RequestRobot(RobotConn *pThis, char *cmd, int len, char *output, int recvFlag)
{
    int ret = 0;
    int sclient;
    struct sockaddr_in serAddr;
    struct addrinfo hints, *res = NULL;
    
    if(cmd == NULL)
    {
        return -1;
    }
    
    memset(&hints, 0, sizeof(hints));
    
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_CANONNAME;
    
    ret = getaddrinfo(ROBOT_SERVER_IP, ROBOT_SERVER_PORT, &hints, &res);
    if(ret != 0)
    {
        return -1;
    }
 
    sclient = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if(sclient < 0)
    {
        return -1;
    }
    
    struct timeval timeout = {0};
    timeout.tv_sec = SOCKET_SEND_TIMEOUT;       //设置发送超时时间
    setsockopt(sclient, SOL_SOCKET, SO_SNDTIMEO, (const char*)&timeout, sizeof(timeout));

    
    if (connect(sclient, res->ai_addr, res->ai_addrlen) < 0)
    {
        close(sclient);
        return -1;
    }
    
    send(sclient, cmd, len, 0);
    
    if(recvFlag == 1)
    {
        char recData[10*1024] = {0};
        
        timeout.tv_sec = SOCKET_RECV_TIMEOUT;       //设置接收超时时间
        setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof(timeout));
        
        int recvLen = 0;
        int count = 0;
        while((recvLen = recv(sclient, recData, 10*1024, 0)) > 0)
        {
            memcpy(&output[count], recData, recvLen);
            count += recvLen;
            ret = count;
        }
    }
    
    close(sclient);
    return ret;
}

/***********************************************************************************************/
//  @Description                    : 设置IP&Port
//  @param ip                       : IP地址
//  @param port						: 端口
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
void RobotConn_SetIp(RobotConn *pThis, char *ip, int port)
{
	int len = 0;

	len = (strlen(ip) > 15) ? 15 : strlen(ip);
	memcpy(pThis->robotIp, ip, len);
	pThis->robotPort = port;
}

/***********************************************************************************************/
//  @Description                    : 初始化
//  @param data                     : 
//  @return                         : None
//  @Author: andy.wang
//  Note:
/***********************************************************************************************/
void RobotConn_Initial(RobotConn *pThis)
{
	memset(pThis->robotIp, 0x00, sizeof(pThis->robotIp));
	pThis->robotPort = ROBOT_CONN_DEFAULT_PORT;
}
