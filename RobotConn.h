/***********************************************************************************************
** File Name:      RobotConn.h                                                                 *
** Author:         andy.wang                                                                   *
** Date:           26/02/2016                                                                  *
** Copyright:      2016 RoboSys, Incorporated. All Rights Reserved.                            *
** Description:    机器人Socket通讯类                                                            *
************************************************************************************************/
#ifndef _RobotConn_H
#define _RobotConn_H

#ifdef __cplusplus
	extern "C"  {
#endif
        
//#define SERVER_DEBUG_MODE
//服务器地址
#define SERVER_DNS      "robosys.cc"
#define SERVER_DEBUG    "192.168.0.111"
//服务器端口
#define SERVER_PORT     6781
        
//机器人作为热点时IP
#define ROBOT_SERVER_IP "192.168.8.8"
//机器人作为热点时端口
#define ROBOT_SERVER_PORT "8723"

//接收数据超时时间
#define SOCKET_SEND_TIMEOUT         5   //5S 发送数据超时
#define SOCKET_RECV_TIMEOUT         30  //30S 接收数据超时
#define SOCKET_RECV_TIMEOUT_LY      5
//默认与机器连接TCP端口号
#define ROBOT_CONN_DEFAULT_PORT		9948

typedef struct RobotConn_t RobotConn;
struct RobotConn_t{
	char	robotIp[16];
	int     robotPort;
};

//初始化
extern void RobotConn_Initial(RobotConn *pThis);
//设置IP和端口
extern void RobotConn_SetIp(RobotConn *pThis, char *ip, int port);
//发送命令
extern int RobotConn_SendCmd(RobotConn *pThis, char *cmd, int len, char *output, int recvFlag);
//请求服务器
extern int RobotConn_RequestServer(RobotConn *pThis, char *cmd, int len, char *output, int recvFlag);
//机器人作为热点时与机器人通讯
extern int RobotConn_RequestRobot(RobotConn *pThis, char *cmd, int len, char *output, int recvFlag);
        
//请求服务器
extern int RobotConn_RequestServer_LY(RobotConn *pThis, char *cmd, int len, char *output, int recvFlag);

#ifdef __cplusplus
}
#endif

#endif
