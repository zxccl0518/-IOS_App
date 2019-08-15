//
//  RobotConnect.m
//  RobotDemo-Swift
//
//  Created by Cheer on 16/5/25.
//  Copyright © 2016年 Cheer. All rights reserved.
//

#import "RobotConnect.h"
#import "RobotCtrl.h"
#import "Reachability.h"

static RobotConnect *instance = nil;

@implementation RobotConnect

+ (RobotConnect *)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (id) allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        RobotCtrl *pRobotCtrl = nil;
        RobotCtrl_Initial(&pRobotCtrl);
        RobotCtrl_SetIpPort(pRobotCtrl, "192.168.8.8", 9948);
    }
    return self;
}


//获取手机验证码
- (int)didGetVerifyCode:(NSString*)text type:(int)type
{
    //手机号
    NSString *mobileNoStr = text;
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    char *mobileNo = (char*)[mobileNoStr UTF8String];
    
    return pRobotCtrl->getMobileCode(pRobotCtrl, mobileNo,type);
}
//用户注册
- (int)didRegister:(NSString*)num psw:(NSString*)psw verifyCode:(NSString*)verifyCode
{
    NSString *mobileNoStr = num;//[[self editMobileNo] text];
    NSString *passStr = psw;//[[self editPass] text];
    NSString *verifyCodeStr = verifyCode;//[[self editVerifyCode] text];
    char *pMobileNo  = (char*)[mobileNoStr UTF8String];
    char *pPass  = (char*)[passStr UTF8String];
    char *pVerifyCode  = (char*)[verifyCodeStr UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    return pRobotCtrl->userRegister(pRobotCtrl, pMobileNo, pPass, pVerifyCode);
}
//用户登陆
- (NSDictionary *)didLogon:(NSString*)num psw:(NSString*)psw
{
    NSString *mobileNoStr = num;//[[self editMobileNo] text];
    NSString *passStr = psw;//[[self editPass] text];
    char *pMobileNo  = (char*)[mobileNoStr UTF8String];
    char *pPass  = (char*)[passStr UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    char token[64] = {0};
    
//    char pShowDemo[1] = {0};
    char pShowDemo[4] = {0};
    
    int robotCount = 0;
    
    char robotId[200][32] = {0};
    char *pRobotId[200] = {0};
    int admin[200] = {0};
    int *pAdmin[200] = {0};
    int online[200] = {0};
    int *pOnline[200] = {0};
    
    for(int i = 0;i < 200;i++)
    {
        pRobotId[i] = robotId[i];
        pAdmin[i] = &admin[i];
        pOnline[i] = &online[i];
    }
    
    /*
     (RobotCtrl *pThis, char *mobileNo, char *pass, char *pToken,char *pShowDemo, int *robotCount, char **robotId, int **admin, int **online)
     */
    
//    int res = pRobotCtrl->userLogon(pRobotCtrl, pMobileNo, pPass, token, &robotCount, pRobotId, pAdmin, pOnline);

    int res = pRobotCtrl->userLogon(pRobotCtrl, pMobileNo, pPass, token, pShowDemo, &robotCount, pRobotId, pAdmin, pOnline);

    
    NSLog(@"%s",pShowDemo);
    NSString *tokenStr = @"";
    NSString *showDemoStr = @"";
    
    if  (0 == res)
    {
       tokenStr = [[NSString alloc] initWithCString:(const char*)token encoding:NSASCIIStringEncoding];
    }
    
//    if (strlen(pShowDemo) == 0) {
//        
//        NSArray *key = [NSArray arrayWithObjects:@"res",@"token",@"count", nil];
//        NSArray *value = [NSArray arrayWithObjects:@(res),tokenStr,@(robotCount), nil];
//        NSDictionary *dict = [[NSDictionary alloc]initWithObjects:value forKeys:key];
//        
//        return dict;
//
//    }
    
    
//    showDemoStr = [[NSString alloc]initWithCString:pShowDemo encoding:NSUTF8StringEncoding];
//    
//    NSArray *key = [NSArray arrayWithObjects:@"res",@"token",@"count",@"showdemo", nil];
//    NSArray *value = [NSArray arrayWithObjects:@(res),tokenStr,@(robotCount),showDemoStr, nil];
//    
////    NSDictionary *dict = [[NSDictionary alloc]init];
//    NSDictionary *dict = [[NSDictionary alloc]initWithObjects:value forKeys:key];
//    
//    
//    
//    return dict;
    
    
      return [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@(res),tokenStr,@(robotCount),nil] forKeys:[NSArray arrayWithObjects:@"res",@"token",@"count",nil]];
//    return [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:showDemoStr,@(res),tokenStr,@(robotCount),nil] forKeys:[NSArray arrayWithObjects:@"showdemo",@"res",@"token",@"count",nil]];
}

//用户登出
- (int)didLogout:(NSString*)num token:(NSString*)token
{
    NSString *mobileNoStr = num;//[[self editMobileNo] text];
    NSString *tokenStr = token;//[[self editToken] text];
    char *pMobileNo  = (char*)[mobileNoStr UTF8String];
    char *pToken  = (char*)[tokenStr UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    return pRobotCtrl->userLogonOut(pRobotCtrl, pMobileNo, pToken);
}


 //用户绑定
- (int)didBind:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId admin:(int)adminCount
 {
     NSString *mobileNoStr = num;//[[self editMobileNo] text];
     NSString *tokenStr = token;//[[self editToken] text];
     NSString *robotIdStr = robotId;//[[self editRobotId] text];
     char *pMobileNo  = (char*)[mobileNoStr UTF8String];
     char *pToken  = (char*)[tokenStr UTF8String];
     char *pRobotId  = (char*)[robotIdStr UTF8String];
     
     RobotCtrl *pRobotCtrl = nil;
     RobotCtrl_GetRobotCtrl(&pRobotCtrl);
     
     int code = pRobotCtrl->userBind(pRobotCtrl, pMobileNo, pRobotId, pToken, adminCount);
     return code;
 }

//用户解绑
- (int)didUnBind:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId {
//    NSString *mobileNoStr = [[self editMobileNo] text];
//    NSString *tokenStr = [[self editToken] text];
//    NSString *robotIdStr = [[self editRobotId] text];
    char *pMobileNo  = (char*)[num UTF8String];
    char *pToken  = (char*)[token UTF8String];
    char *pRobotId  = (char*)[robotId UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    return pRobotCtrl->unBind(pRobotCtrl, pMobileNo, pRobotId, pToken);
}

//查找用户绑定的机器人列表
- (NSMutableArray*)didQueryRobotList:(NSString*)num token:(NSString*)token robotId:(NSString*)Id
{
    NSString *mobileNoStr = num;//[[self editMobileNo] text];
    NSString *tokenStr = token;//[[self editToken] text];
    char *pMobileNo  = (char*)[mobileNoStr UTF8String];
    char *pToken  = (char*)[tokenStr UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    int robotCount = 0;
    char robotId[200][32] = {0};
    char *pRobotId[200] = {0};
    int admin[200] = {0};
    int *pAdmin[200] = {0};
    int online[200] = {0};
    int *pOnline[200] = {0};
    
    for(int i = 0;i < 200;i++)
    {
        pRobotId[i] = robotId[i];
        pAdmin[i] = &admin[i];
        pOnline[i] = &online[i];
    }
    
    int ret = pRobotCtrl->queryRobotList(pRobotCtrl, pMobileNo, pToken, &robotCount, pRobotId, pAdmin, pOnline);
    
    BOOL isBind = false;
    BOOL isAdmin = false;

    for(int i = 0;i < 200;i++)
    {
        //有我
        if (Id && strcmp(pRobotId[i],(char*)[Id UTF8String]) == 0)
        {
            isBind = true;
        }
        //有管理员
        if(admin[i] != 0)
        {
            isAdmin = true;
        }
    }
    
    return [NSMutableArray arrayWithObjects: @(ret), @(robotCount),@(isBind),@(isAdmin),nil];
}

//查找机器人绑定的用户列表
- (NSDictionary *)didQueryUserList:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId
{
    NSString *mobileNoStr = num;//[[self editMobileNo] text];
    NSString *tokenStr = token;//[[self editToken] text];
    NSString *robotIdStr = robotId;//[[self editRobotId] text];
    char *pMobileNo  = (char*)[mobileNoStr UTF8String];
    char *pToken  = (char*)[tokenStr UTF8String];
    char *pRobotId  = (char*)[robotIdStr UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    int userCount = -1;
    int adminCount = -1;
    char userList[200][32] = {0};
    int admin[200] = {0};
    int *pAdmin[200] = {0};
    char *pUserList[200] = {0};

    for(int i = 0;i < 200;i++)
    {
        pUserList[i] = userList[i];
        pAdmin[i] = &admin[i];
    }
    int ret = pRobotCtrl->queryUserList(pRobotCtrl, pMobileNo, pToken, pRobotId, &userCount, &adminCount, pUserList, pAdmin);
    
    NSMutableArray *userArray = [[NSMutableArray alloc] init];
    
    for (int i = 0;i < 200;i++)
    {
        NSString *temp = [[NSString alloc] initWithCString:userList[i] encoding:NSUTF8StringEncoding];
        [userArray addObject:temp];
    }
    
    NSMutableArray *adminArray = [[NSMutableArray alloc] init];
    
    for (int i = 0;i < 200;i++)
    {
        NSString *temp = [NSString stringWithFormat:@"%d",*pAdmin[i]];
        [adminArray addObject:temp];
    }
    
    return [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@(ret),userArray,adminArray,@(userCount),@(adminCount), nil] forKeys:[NSArray arrayWithObjects:@"ret",@"userArray",@"adminArray",@"userCount",@"adminCount", nil]];
}


char rotbotSN[33] = {0};

//发送路由器的SSID&PASS至机器人，需要先连接机器人的热点
- (NSString *)didWifiSetup:(NSString *)SSID pass:(NSString *)password {
    NSString *ssidStr = SSID;//[[self editSSID] text];
    NSString *passStr = password;//[[self editPASS] text];
    char *pSSID  = (char*)[ssidStr UTF8String];
    char *pPASS  = (char*)[passStr UTF8String];
    
    
    //向机器人发送SSID和PASS, 需要先连接机器人的热点
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);

    pRobotCtrl->robotWifiSetup(pRobotCtrl, pSSID, pPASS, rotbotSN);
    
    NSString * str = [NSString stringWithUTF8String:rotbotSN];

    return str;
}




- (NSMutableArray*)didReset:(NSString*)userName token:(NSString*)token robotId:(NSString*)Id isLogin:(BOOL)isLogin
 {
    char robotLanIp[33] = {0};
    char robotConnSSID[33] = {0};
    char robotMac[33] = {0};
    char *pToken = (char*)[token UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    int ret = -1;
     //每隔1s向服务器查询下机器人是否在线的状态, 超时时间60S
     for(int i = 0;i < 15;i++)
     {
         ret = pRobotCtrl->queryRobotStatus(pRobotCtrl, (char*)[userName UTF8String], pToken, (char*)[Id UTF8String], robotLanIp, robotConnSSID, robotMac);
         
         //判断lanIP, connSSID, robotMac是否为空， 确定机器人是否在线
         if (strlen(robotLanIp) != 0)
         {
             return [[NSMutableArray alloc] initWithObjects:@(ret),@(robotLanIp),@(robotConnSSID), nil];
         }
         
         if (isLogin)
         {
             return [[NSMutableArray alloc] initWithObjects:@(ret),@(robotLanIp),@(robotConnSSID), nil];
         }
         
         sleep(2);
     }
     return [[NSMutableArray alloc] initWithObjects:@(ret),@(robotLanIp),@(robotConnSSID), nil];
 }

//查询在线
-(int)didOnline:(NSString*)userName token:(NSString*)token robotId:(NSString*)Id
{
    char robotLanIp[33] = {0};
    char robotConnSSID[33] = {0};
    char robotMac[33] = {0};
    char *pToken = (char*)[token UTF8String];
    int ret = -1;
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    for(int i = 0;i < 2;i++)
    {
        ret = pRobotCtrl->queryRobotStatus(pRobotCtrl, (char*)[userName UTF8String], pToken, (char*)[Id UTF8String], robotLanIp, robotConnSSID, robotMac);
        
        //判断lanIP, connSSID, robotMac是否为空， 确定机器人是否在线
        if(strlen(robotLanIp) != 0)
        {
            return ret;
        }
        ret = -1;
    }
    return ret;
}

//连接在线机器人--先查询机器人是否在线，然后发起连接指令
- (NSMutableArray*)didConnRobot:(NSString *)token userName:(NSString *)name robotId:(NSString *)Id
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    RobotCtrl_SetRobotContrlMode(pRobotCtrl, REMOTE_CONTROL_MODE, (char*)[name UTF8String], (char*)[token UTF8String], (char*)[Id UTF8String]);
    
    //连接机器人
    int ret = pRobotCtrl->connRobot(pRobotCtrl);
    
    return [[NSMutableArray alloc] initWithObjects:@(ret), nil];
    
}

//连接离线机器人
- (int)didConnOfflineRobot
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    RobotCtrl_SetRobotContrlMode(pRobotCtrl, NEAR_CONTROL_MODE, nil, nil, nil);
    
    //连接机器人
    return pRobotCtrl->connRobot(pRobotCtrl);
}

- (int)didResetPass:(NSString *)newPsw userName:(NSString *)name verifyCode:(NSString *)code
{
    NSString *mobileNoStr = name;//[[self editMobileNo] text];
    NSString *newPassStr = newPsw;//[[self editNewPass] text];
    NSString *verifyCodeStr = code;//[[self editVerifyCode] text];
    
    char *pMobileNo  = (char*)[mobileNoStr UTF8String];
    char *pNewPass  = (char*)[newPassStr UTF8String];
    char *pVerifyCode  = (char*)[verifyCodeStr UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    return pRobotCtrl->resetPass(pRobotCtrl, pMobileNo, pVerifyCode, pNewPass);
}
- (NSMutableArray*)didChangePass:(NSString *)token userName:(NSString *)name oldPsw:(NSString *)old newPsw:(NSString *)new {
    NSString *mobileNoStr = name;//[[self editMobileNo] text];
    NSString *tokenStr = token;//[[self editToken] text];           //登陆时服务器返回的，测试时这里直接输入
    NSString *oldPassStr = old;//[[self editPass] text];
    NSString *newPassStr = new;//[[self editNewPass] text];
    
    char *pMobileNo  = (char*)[mobileNoStr UTF8String];
    char *pToken  = (char*)[tokenStr UTF8String];
    char *pOldPass  = (char*)[oldPassStr UTF8String];
    char *pNewPass  = (char*)[newPassStr UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    int ret = pRobotCtrl->changePass(pRobotCtrl, pMobileNo, pToken, pOldPass, pNewPass);
    return [[NSMutableArray alloc] initWithObjects:@(ret), nil];
}
//提交用户反馈
- (NSMutableArray*)didUserFeedback:(NSString *)userName token:(NSString *)tokenStr contentStr:(NSString *)contentStr
{
    char *pFeedbackContent  = (char*)[contentStr UTF8String];
    char *pToken = (char*)[tokenStr UTF8String];
    char *pUserName = (char*)[userName UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    int ret = pRobotCtrl->userFeedback(pRobotCtrl,pUserName, pToken, pFeedbackContent);
    return  [[NSMutableArray alloc] initWithObjects:@(ret), nil];
}

//获取用户信息
- (NSMutableArray*)didGetUserInfo:(NSString *)userName token:(NSString *)tokenStr
{
    char *pToken = (char*)[tokenStr UTF8String];
    char *pUserName = (char*)[userName UTF8String];
    
    char nickName[256] = {0};
    int sex = 0;
    char registDate[32] = {0};
    char birthday[32] = {0};
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    int ret = pRobotCtrl->getUserInfo(pRobotCtrl, pUserName, pToken, nickName, &sex, registDate, birthday);
    
    if (ret == 0)
    {
        return [[NSMutableArray alloc] initWithObjects:@(nickName),@(sex),@(registDate),@(birthday), nil];
    }
    
    return [[NSMutableArray alloc] init];
}

//设置昵称
- (void)didSetUserInfo:(NSString *)userName token:(NSString *)tokenStr nickName:(NSString *)nickNameStr
{
    
    char *pUserName = (char*)[userName UTF8String];
    char *pToken = (char*)[tokenStr UTF8String];
    char *pNickName = (char*)[nickNameStr UTF8String];
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->setUserInfo(pRobotCtrl, pUserName, pToken, "nick_name", pNickName);
}

//设置用户生日
- (void)didSetUserInfo:(NSString *)userName token:(NSString *)tokenStr birthday:(NSString *)birthdayStr
{
    char *pUserName = (char*)[userName UTF8String];
    char *pToken = (char*)[tokenStr UTF8String];
    char *pBirthday = (char*)[birthdayStr UTF8String];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->setUserInfo(pRobotCtrl, pUserName, pToken, "birthday", pBirthday);
}

//设置性别
- (void)didSetUserInfo:(NSString *)userName token:(NSString *)tokenStr sex:(int)sexValue{
    
    char *pUserName = (char*)[userName UTF8String];
    char *pToken = (char*)[tokenStr UTF8String];
    char sexBuf[16] = {0};
    
    if(sexValue == 0)
    {
        strcpy(sexBuf, "man");
    }
    else
    {
        strcpy(sexBuf, "female");
    }
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->setUserInfo(pRobotCtrl, pUserName, pToken, "sex", sexBuf);
}

//设置用户信息
- (void)didSetUserInfo:(NSString *)userName token:(NSString *)tokenStr nickName:(NSString *)nickNameStr birthday:(NSString *)birthdayStr sex:(int)sexValue{
    
    char *pUserName = (char*)[userName UTF8String];
    char *pToken = (char*)[tokenStr UTF8String];
    char *pNickName = (char*)[nickNameStr UTF8String];
    char *pBirthday = (char*)[birthdayStr UTF8String];
    char sexBuf[16] = {0};
    
    
    if(sexValue == 0)
    {
        strcpy(sexBuf, "man");
    }
    else
    {
        strcpy(sexBuf, "female");
    }
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    pRobotCtrl->setUserInfo(pRobotCtrl, pUserName, pToken, "nick_name", pNickName);
    pRobotCtrl->setUserInfo(pRobotCtrl, pUserName, pToken, "sex", sexBuf);
    pRobotCtrl->setUserInfo(pRobotCtrl, pUserName, pToken, "birthday", pBirthday);
}


////获取常见总是
//- (IBAction)didGetQAList:(id)sender {
//    NSString *tokenStr = [[self editToken] text];
//    char *pToken = (char*)[tokenStr UTF8String];
//    
//    UIAlertController *alertController = nil;;
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
//    }];
//    
//    char *pQList[5] = {0};
//    char *pAList[5] = {0};
//    
//    for(int i = 0;i < 5;i++)
//    {
//        pQList[i] = (char*)malloc(512);
//        pAList[i] = (char*)malloc(512);
//    }
//    
//    RobotCtrl *pRobotCtrl = nil;
//    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
//    int ret = pRobotCtrl->getQA(pRobotCtrl, "15026691704", pToken, pQList, pAList);
//    
//    if(ret == 0)
//    {
//        alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"获取常见问题成功" preferredStyle:UIAlertControllerStyleAlert];
//    }
//    else if(ret == -1)
//    {
//        alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"获取常见问题失败" preferredStyle:UIAlertControllerStyleAlert];
//    }
//    else
//    {
//        NSString *msg = [NSString stringWithFormat:@"获取常见问题有误 status:%d",ret];
//        alertController = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
//    }
//    
//    for(int i = 0;i < 5;i++)
//    {
//        free(pQList[i]);
//        pQList[i] = NULL;
//        free(pAList[i]);
//        pAList[i] = NULL;
//    }
//}
    
@end
