/***********************************************************************************************
** File Name:      RobotCtrl.h                                                                 *
** Author:         andy.wang                                                                   *
** Date:           25/02/2016                                                                  *
** Copyright:      2016 RoboSys, Incorporated. All Rights Reserved.                            *
** Description:    机器人交互接口类                                                               *
************************************************************************************************/
#ifndef _RobotCtrl_H
#define _RobotCtrl_H

#ifdef __cplusplus
	extern "C"  {
#endif

#include "RobotConn.h"

//控制控制模式
#define NEAR_CONTROL_MODE      0
//远程控制模式
#define REMOTE_CONTROL_MODE    1
        
//命令头
#define ROBOT_CMD_REQUEST_HEAD 0x3E
#define ROBOT_CMD_REQUEST_HEAD_DOUBLE_LEN 0x3F
#define ROBOT_CMD_RSP_HEAD     0x3C

//命令定义
#define APP_CTRL_CMD_FORWARD			 0x10        //前进
#define APP_CTRL_CMD_FALLBACK            0x11        //后退
#define APP_CTRL_CMD_FEET_WHIRL          0x12        //旋转
#define APP_CTRL_CMD_JOG                 0x13        //自由漫步
#define APP_CTRL_CMD_HEAD_WHIRL          0x14        //头部运动
#define APP_CTRL_CMD_STOP                0x15        //停止
#define APP_CTRL_CMD_IR                  0x16        //红外避障更改
#define APP_CTRL_CMD_FOLLOW              0x17        //跟随状态更改
#define APP_CTRL_CMD_SING                0x18        //唱歌
#define APP_CTRL_CMD_STORY               0x19        //讲故事
#define APP_CTRL_CMD_STOP_MEDIA          0x1A        //停止多媒体
#define APP_CTRL_CMD_OPERATE_WEIXIN_TALK 0x1B        //开启关闭微信通话
#define APP_CTRL_CMD_VOLUME_CTRL         0x1C        //音量控制
#define APP_CTRL_CMD_ACTION_MODE_CTRL    0x1D        //运动 模式控制
#define APP_CTRL_CMD_JOKE                0x1E        //讲笑话
#define APP_CTRL_SET_EMOTION_MODE        0x1F	     //设置脸部情绪表情
#define APP_CTRL_CMD_EAR_EXPRESSION      0x2A		 //耳朵效果
#define APP_CTRL_CMD_COMB_ACTIONS		 0x2B		 //组合动作
#define APP_CTRL_CMD_CUTE				 0x2C		 //随机卖萌
#define APP_CTRL_CMD_TRICK				 0x2D		 //脑筋急转弯
#define APP_CTRL_CMD_PLAY_SST			 0x2E		 //播放合成音文本
#define APP_CTRL_CMD_GET_MUSIC_LIST		 0x2F		 //获取Robot本地音乐列表
#define APP_CTRL_CMD_PLAY_MUSIC_INDEX	 0x30		 //请求播放Robot地本音乐列表中指定的音乐
#define APP_CTRL_CMD_TICK		         0x31		 //心跳包，并返回实时数据
#define APP_CTRL_CMD_SET_DATE			 0x32		 //设置系统时间
#define APP_CTRL_CMD_SET_ALARM			 0x33		 //设置闹铃提醒
#define APP_CTRL_CMD_SET_VOLUME          0x34        //设置音量
#define APP_CTRL_CMD_GET_ALARM_LIST      0x35        //获取闹铃列表
#define APP_CTRL_CMD_UPDATE_ALARM        0x36        //更新闹铃
#define APP_CTRL_CMD_DELETE_ALARM        0x37        //删除闹铃
#define APP_CTRL_CMD_DELETE_SCRIPT_MULTI 0x43        //批量删除脚本
#define APP_CTRL_CMD_PLAY_URL            0x44        //播放URL
                                                    // -----------新添加接口----
#define APP_CTRL_CMD_PLAYER_GET_ALBUM_LIST      	0x45        //获取歌单音乐列表
#define APP_CTRL_CMD_PLAYER_START        0x46		 //播放器播放音乐
#define APP_CTRL_CMD_PLAYER_CTRL         0x47 		 //音乐播放控制
#define APP_CTRL_CMD_PLAYER_QUERY_DIREC_MUSIC_LIST 	0x51		//查询指定目录下的文件列表
        
//管理类指令
#define APP_MANAGE_CMD_CONNECT			 0xA0        //连接请求
#define APP_MANAGE_CMD_STOP_RECOGNIZE    0xA1        //语音识别开关控制
#define APP_MANAGE_CMD_ATTR_SETUP        0xA2        //设置参数
#define APP_MANAGE_CMD_PUSH_SCRIPT	     0xA3		 //推送脚本至Robot
#define APP_MANAGE_CMD_QUERY_SCRIPT      0xA4		 //查询脚本列表
#define APP_MANAGE_CMD_SEND_IP_PORT      0xA5        //发送IP&Port包
#define APP_NANAGE_CMD_EXEC_SCRIPT       0xA6		 //执行指定ID的脚本
#define APP_MANAGE_CMD_GET_ROBOT_ATTR    0xA7        //获取机器人属性

//这里获取机器人WIFI列表
#define APP_MANAGE_CMD_GET_ROBOT_WIFI    0xB8        //获取机器人WIFI列表

//连接指定wifi用户名和密码
#define APP_MANAGE_CMD_GET_ROBOT_SPECIED 0xB9        //连接指定的SSID和密码
        
//还原网络设置
#define APP_MANAGE_CMD_GET_ROBOT_RET     0xBA        //还原网络设置
        
        
//闹铃信息Item
typedef struct AlarmItem_t{
    int id;                // 数据库里的 id 号, 设置的时候不需要, 只有app获取的时候才需要上传
    char alarmContent[256];// 提醒的内容
    int alarmPlanYMD;      // 计划年月日
    int alarmPlanHM;       // 计划时分
    char alarmAdvance[16]; // 提前属性
    char alarmRepeat[4];   // 重复属性
    int alarmJingleYMD;    // 响铃年月日
    int alarmJingleHMS;    // 响铃时分秒
    int alarmDone;         // 已完成
}AlarmItem;

//机器人属性Item
typedef struct RobotAttr_t{
    int     robotNameLen;           //机器人姓名长度
    char    robotName[255];         //机器人姓名
    int     masterNameLen;          //管理员姓名长度
    char    masterName[255];        //管理员姓名
    int     mantraLen;              //口头禅长度
    char    mantra[255];            //口头禅
    int     birthdayLen;            //生日长度
    char    birthday[64];           //生日
    int     constellation;          //星座  0-11（十二星座）
    int     sex;                    //性别  0x01男 0x02女
    int     speakSpeed;             //语速  0x00--低速 0x01--中速 0x02--高速
    int     speakType;              //音色  0x00--男孩 0x01--女孩 0x02--志玲
}RobotAttr;
        
//查询脚本信息Item
typedef struct RobotScript_t{
    int id;                 //脚本编号
    char name[128];         //脚本名称
    char time[16];          //脚本时长---分钟'秒数”  单引号表示分钟数，双引号表示秒数
    char date[32];          //脚本日期
}RobotScript;
//--------------- 新添加接口
//歌曲信息Item
typedef struct MusicItem_t{
	int musicid;					//歌曲ID
	char name[256];			//歌曲名
	int albumId;			//所在专辑ID
}MusicItem;

//目录信息列表
typedef struct DirecItem_t{
	char name[256];			//歌曲名
	int type;				//名称类型 1--歌曲名 2--目录名
}DirecItem;
        
//类定义
typedef struct RobotCtrl_t RobotCtrl;

//发送学习数据
typedef void (*RobotCtrl_Study)(RobotCtrl*,char*,char*,char*,char*,int);
        
//连接机器人
typedef int (*RobotCtrl_ConnRobot)(RobotCtrl*);
//前进
typedef void (*RobotCtrl_Forward)(RobotCtrl*, int, int, int);
//后退
typedef void (*RobotCtrl_Fallback)(RobotCtrl*, int, int, int);
//左转右转
typedef void (*RobotCtrl_Turn)(RobotCtrl*, int, int);
//点头
typedef void (*RobotCtrl_Nod)(RobotCtrl*, int, int, int);
//摇头
typedef void (*RobotCtrl_Shake)(RobotCtrl*, int, int, int);
//向上看
typedef void (*RobotCtrl_LookUp)(RobotCtrl*);
//向下看
typedef void (*RobotCtrl_LookDown)(RobotCtrl*);
//向左看
typedef void (*RobotCtrl_LookLeft)(RobotCtrl*);
//向右看
typedef void (*RobotCtrl_LookRight)(RobotCtrl*);
//向前看
typedef void (*RobotCtrl_LookForward)(RobotCtrl*);
//停止运动
typedef void (*RobotCtrl_StopRun)(RobotCtrl*);
//顺时针旋转
typedef void (*RobotCtrl_ClockwiseWhirl)(RobotCtrl*, int, int);
//逆时针旋转
typedef void (*RobotCtrl_CounterclockwiseWhirl)(RobotCtrl*, int, int);
//控制机器人播放合成音
typedef void (*RobotCtrl_SST)(RobotCtrl*, const char*);
//设置机器人运动模式-- 1--远程控制模式/有避障 2--自由漫步 3--跟随模式 4--  远程控制模式/无避障
typedef void (*RobotCtrl_SetRunMode)(RobotCtrl*, int);
//设置机器人眼睛情绪
typedef void (*RobotCtrl_SetRobotEye)(RobotCtrl*, int);
//设置机器人耳朵效果
typedef void (*RobotCtrl_SetRobotEar)(RobotCtrl*, int);
//音乐播放
typedef void (*RobotCtrl_MusicCtrl)(RobotCtrl*, int);
//讲故事
typedef void (*RobotCtrl_StoryCtrl)(RobotCtrl*, int, char*);
//停止音频内容的播放
typedef void (*RobotCtrl_StopAudioPlay)(RobotCtrl*);
//请求查看Robot本地音乐列表
typedef int (*RobotCtrl_QueryRobotMusicList)(RobotCtrl*, char **musicList);
        
//请求查看Robot本地Wifi列表
typedef int (*RobotCtrl_QueryRobotWifiList)(RobotCtrl*, char *wifiList);
//连接指定wifi
typedef void (*RobotCtrl_ConnectSpecifiedWifi)(RobotCtrl*,const char*,int);
//还原网络设置
typedef void (*RobotCtrl_ReSetWifiConfig)(RobotCtrl*);
        
//请求播放Robot本地音乐列表中指定的音乐
typedef void (*RobotCtrl_PlayRobotMusicByIndex)(RobotCtrl*, int);
//心跳包
typedef int (*RobotCtrl_TickRequest)(RobotCtrl*, int *battery);
//执行组合动作
typedef void (*RobotCtrl_execCombActions)(RobotCtrl*, char*);
//随机卖萌
typedef void (*RobotCtrl_Cute)(RobotCtrl*);
//控制音量+-
typedef void (*RobotCtrl_VolumeCtrl)(RobotCtrl*, int);
//设置闹铃
typedef int (*RobotCtrl_SetAlarm)(RobotCtrl*, char*);
//手臂抬起
typedef void (*RobotCtrl_HandUp)(RobotCtrl*, int, int, int);
//手臂后摆
typedef void (*RobotCtrl_HandBack)(RobotCtrl*, int, int, int);
//手臂摆动
typedef void (*RobotCtrl_HandShake)(RobotCtrl*, int, int, int, int);
//手臂左右交叉摆动
typedef void (*RobotCtrl_HandBothShake)(RobotCtrl*, int, int, int);
//获取闹铃列表
typedef int (*RobotCtrl_GetAlarmList)(RobotCtrl*, int, AlarmItem**);
//更新闹铃
typedef int (*RobotCtrl_UpdateAlarmItem)(RobotCtrl*, int, char*);
//删除闹铃
typedef int (*RobotCtrl_DeleteAlarmItem)(RobotCtrl*, int);
//设置音量
typedef void (*RobotCtrl_SetVolume)(RobotCtrl*, int);
//唤醒/休眠
typedef void (*RobotCtrl_SleepCtrl)(RobotCtrl*, int);
//讲故事
typedef void (*RobotCtrl_JokeCtrl)(RobotCtrl*, int, char*);
//获取机器人属性
typedef int (*RobotCtrl_GetRobotAttr)(RobotCtrl*, RobotAttr*);
//顺时针旋转指定速度时间
typedef void (*RobotCtrl_ClockwiseWhirlByTime)(RobotCtrl*, int, int);
//逆时针旋转指定速度时间
typedef void (*RobotCtrl_CounterclockwiseWhirlByTime)(RobotCtrl*, int, int);
//设置机器人属性
typedef int (*RobotCtrl_SetRobotAttr)(RobotCtrl*, int, char*);
//批量删除脚本
typedef int (*RobotCtrl_DeleteScriptMulti)(RobotCtrl*, int num, int*);
//播放URL
typedef int (*RobotCtrl_PlayUrl)(RobotCtrl*, char*);
        //-----------------------------// 新添加接口--------------------------
//获取歌单音乐列表
typedef int (*RobotCtrl_Player_GetAlbumList)(RobotCtrl*, int, int, MusicItem**);
//播放器播放音乐
typedef int (*RobotCtrl_Player_Start)(RobotCtrl*, int, char*, int);
//音乐播放控制
typedef int (*RobotCtrl_Player_Ctrl)(RobotCtrl*, int, int);
//查询指定目录下的文件列表
typedef int (*RobotCtrl_Player_QueryDirecMusicList)(RobotCtrl*, int, char*, DirecItem**);
        
//获取短信验证码
typedef int (*RobotCtrl_GetMobileCode)(RobotCtrl*, char*, int);
//用户注册
typedef int (*RobotCtrl_UserRegister)(RobotCtrl*, char*, char*, char*);
//用户登录
typedef int (*RobotCtrl_UserLogon)(RobotCtrl*, char*, char*, char*,char*, int*, char**, int**, int**);
//用户登出
typedef int (*RobotCtrl_UserLogonOut)(RobotCtrl*, char*, char*);
//用户绑定
typedef int (*RobotCtrl_UserBind)(RobotCtrl*, char*, char*, char*, int);
//解除用户绑定
typedef int (*RobotCtrl_UnBind)(RobotCtrl*, char*, char*, char*);
//获取用户关联的机器人列表
typedef int (*RobotCtrl_QueryRobotList)(RobotCtrl*, char*, char*, int*, char**, int**, int**);
//获取机器人关系的用户列表
typedef int (*RobotCtrl_QueryUserList)(RobotCtrl*, char*, char*, char*, int*, int*, char**, int**);
//重设密码
typedef int (*RobotCtrl_ResetPass)(RobotCtrl*, char*, char*, char*);
//修改密码
typedef int (*RobotCtrl_ChangePass)(RobotCtrl*, char*, char*, char*, char*);
//用户反馈
typedef int (*RobotCtrl_UserFeedback)(RobotCtrl*, char*, char*, char*);
//用户信息获取
typedef int (*RobotCtrl_GetUserInfo)(RobotCtrl*, char*, char*, char*, int*, char*, char*);
//用户信息设置
typedef int (*RobotCtrl_SetUserInfo)(RobotCtrl*, char*, char*, char*, char*);
//获取常见问题
typedef int (*RobotCtrl_GetQA)(RobotCtrl*, char*, char*, char**, char**);
//推送脚本
typedef int (*RobotCtrl_PushScript)(RobotCtrl*, int, char*, int, char*, int);
//查询脚本
typedef int (*RobotCtrl_QueryScript)(RobotCtrl*, RobotScript*);
//操作脚本
typedef void (*RobotCtrl_ExecScript)(RobotCtrl*, int, int);
        
        
//机器人网络配置相关接口
//配置网络--发送路由器的SSID和PASS给机器人
typedef int (*RobotCtrl_RobotWifiSetup)(RobotCtrl*, char*, char*, char*);
//查询配置的机器人联状态
typedef int (*RobotCtrl_QueryRobotStatus)(RobotCtrl*, char*, char*, char*, char*, char*, char*);


struct RobotCtrl_t{
	RobotConn							roboConn;
    unsigned char                       isRemoteControl;        //是否为实时控制标志 1--远程控制 0--近场控制
    
    char                                account[32];            //用户登陆后的账号
    char                                token[64];              //登陆服务器后返回的TOKEN
    char                                robotSN[33];                //控制的机器人的SN号

    RobotCtrl_Study                     study;                  //学习
    RobotCtrl_ConnRobot                 connRobot;              //连接机器人
    RobotCtrl_Forward					forward;				//前进
	RobotCtrl_Fallback					fallback;				//后退
	RobotCtrl_Turn						turn;					//左转右转
	RobotCtrl_Nod						nod;					//点头
	RobotCtrl_Shake						shake;					//摇头
	RobotCtrl_LookUp					lookUp;					//向上看
	RobotCtrl_LookDown					lookDown;				//向下看
	RobotCtrl_LookLeft					lookLeft;				//向左看
	RobotCtrl_LookRight					lookRight;				//向右看
	RobotCtrl_LookForward				lookForward;			//向前看
	RobotCtrl_StopRun					stopRun;				//停止运动
	RobotCtrl_ClockwiseWhirl			clockwiseWhirl;			//顺时针旋转
	RobotCtrl_CounterclockwiseWhirl		counterClockwiseWhirl;	//逆时针旋转
	RobotCtrl_SST						sst;					//控制机器人播放合成音
	RobotCtrl_SetRunMode				setRunMode;				//设置机器人运动模式
	RobotCtrl_SetRobotEye				setRobotEye;			//设置机器人眼睛情绪
	RobotCtrl_SetRobotEar				setRobotEar;			//设置机器人耳朵效果
	RobotCtrl_MusicCtrl					musicCtrl;				//音乐播放
	RobotCtrl_StoryCtrl					storyCtrl;				//讲故事
	RobotCtrl_StopAudioPlay				stopAudioPlay;			//停止音频内容的播放
	RobotCtrl_QueryRobotMusicList		queryRobotMusicList;	//请求查看Robot本地音乐列表
	RobotCtrl_PlayRobotMusicByIndex		playRobotMusicByIndex;	//请求播放Robot本地音乐列表中指定的音乐
    
    RobotCtrl_QueryRobotWifiList        queryRobotWifiList;      //请求查看Robot扫描Wifi列表
    RobotCtrl_ConnectSpecifiedWifi      connectSpecifiedWifi;    //连接指定的wifi
    RobotCtrl_ReSetWifiConfig           reSetWifiConfig;         //还原网络设置
    
	RobotCtrl_TickRequest				tickRequest;			//心跳包请求
	RobotCtrl_execCombActions			execCombActions;		//执行组合动作
	RobotCtrl_Cute						cute;					//随机卖萌
	RobotCtrl_VolumeCtrl				volumeCtrl;				//音量控制+-
    RobotCtrl_SetAlarm                  setAlarm;               //设置闹铃
    RobotCtrl_HandUp                    handUp;                 //手臂抬起
    RobotCtrl_HandBack                  handBack;               //手臂放后摆
    RobotCtrl_HandShake                 handShake;              //手臂摆动
    RobotCtrl_HandBothShake             handBothShake;          //手臂左右交叉摆动
    RobotCtrl_GetAlarmList              getAlarmList;           //获取闹铃列表
    RobotCtrl_UpdateAlarmItem           updateAlarmItem;        //更新闹铃
    RobotCtrl_DeleteAlarmItem           deleteAlarmItem;        //删除闹铃
    RobotCtrl_SetVolume                 setVolume;              //设置音量
    RobotCtrl_SleepCtrl                 sleepCtrl;              //唤醒/休眠控制
    RobotCtrl_JokeCtrl                  jokeCtrl;               //讲笑话
    RobotCtrl_GetRobotAttr              getRobotAttr;           //获取机器人属性
    RobotCtrl_ClockwiseWhirlByTime      clockwiseWhirlByTime;   //顺时针旋转指定速度时间
    RobotCtrl_CounterclockwiseWhirlByTime counterclockwiseWhirlByTime; //逆时针旋转指定速度时间
    RobotCtrl_SetRobotAttr              setRobotAttr;           //设置机器人属性
    RobotCtrl_PushScript                pushScript;             //推送脚本
    RobotCtrl_QueryScript               queryScript;            //查询脚本
    RobotCtrl_ExecScript                execScript;             //执行脚本
    RobotCtrl_DeleteScriptMulti         deleteScriptMulti;      //批量删除脚本
    RobotCtrl_PlayUrl                   playUrl;                //播放URL
    //----------------------// 新添加接口------------------------------
	RobotCtrl_Player_GetAlbumList		playerGetAlbumList;		//获取歌单音乐列表
    RobotCtrl_Player_Start              playerStart;			//播放器播放音乐
	RobotCtrl_Player_Ctrl				playerCtrl;				//音乐播放控制
    RobotCtrl_Player_QueryDirecMusicList playerQueryDirecMusicList;	//查询指定目录下的文件列表


    RobotCtrl_GetMobileCode             getMobileCode;          //获取短信验证码
	RobotCtrl_UserRegister				userRegister;			//用户注册 
	RobotCtrl_UserLogon					userLogon;				//用户登录
	RobotCtrl_UserLogonOut				userLogonOut;			//用户登出
	RobotCtrl_UserBind					userBind;				//用户绑定
	RobotCtrl_UnBind					unBind;					//解除用户绑定
	RobotCtrl_QueryRobotList			queryRobotList;			//查询用户关联的机器人列表
    RobotCtrl_QueryUserList             queryUserList;          //查询机器人关联的用户列表
    RobotCtrl_ResetPass                 resetPass;              //重置密码
    RobotCtrl_ChangePass                changePass;             //修改密码
    RobotCtrl_UserFeedback              userFeedback;           //用户反馈
    RobotCtrl_GetUserInfo               getUserInfo;            //获取用户信息
    RobotCtrl_SetUserInfo               setUserInfo;            //设置用户信息
    RobotCtrl_GetQA                     getQA;                  //获取常见问题
    
    RobotCtrl_RobotWifiSetup            robotWifiSetup;         //配置网络--发送路由器的SSID和PASS给机器人
    RobotCtrl_QueryRobotStatus          queryRobotStatus;       //查询配置的机器人联状态
};

//初始化
extern void RobotCtrl_Initial(RobotCtrl **ppThis);

//获取单例
extern void RobotCtrl_GetRobotCtrl(RobotCtrl **ppThis);

//设置IP端口
extern void RobotCtrl_SetIpPort(RobotCtrl *pThis, char *ip, int port);

//设置机器人的控制模式--当mode为REMOTE_CONTROL_MODE远程控制时需要设置APP登陆服务器账号、token、控制机器人的SN号, 如果为近场控制模式后三个参数为空
extern void RobotCtrl_SetRobotContrlMode(RobotCtrl *pThis, int mode, char *account, char *token, char *robotSN);

        int str2hex(char *str, char *hex, short wStrLen);
	
#ifdef __cplusplus
	}
#endif

#endif
