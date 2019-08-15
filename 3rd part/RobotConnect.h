//
//  RobotConnect.h
//  RobotDemo-Swift
//
//  Created by Cheer on 16/5/25.
//  Copyright © 2016年 Cheer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RobotConnect : NSObject

+ (RobotConnect *)shareInstance;
+ (id) allocWithZone:(struct _NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;


- (int)didGetVerifyCode:(NSString*)text type:(int)type;

- (int)didRegister:(NSString*)num psw:(NSString*)psw verifyCode:(NSString*)verifyCode;

- (NSDictionary *)didLogon:(NSString*)num psw:(NSString*)psw;

- (int)didBind:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId admin:(int)adminCount;

- (int)didUnBind:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId;

- (int)didLogout:(NSString*)num token:(NSString*)token;

- (NSDictionary *)didQueryUserList:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId;

- (NSMutableArray*)didQueryRobotList:(NSString*)num token:(NSString*)token robotId:(NSString*)Id;

- (NSString *)didWifiSetup:(NSString *)SSID pass:(NSString *)password;

- (NSMutableArray*)didReset:(NSString*)userName token:(NSString*)token robotId:(NSString*)Id isLogin:(BOOL)isLogin;

- (NSMutableArray*)didConnRobot:(NSString *)token userName:(NSString *)name robotId:(NSString *)Id;

- (int)didResetPass:(NSString *)newPsw userName:(NSString *)name verifyCode:(NSString *)code;

- (int)didConnOfflineRobot;

- (NSMutableArray*)didUserFeedback:(NSString *)userName token:(NSString *)tokenStr contentStr:(NSString *)contentStr;

- (NSMutableArray*)didGetUserInfo:(NSString *)userName token:(NSString *)tokenStr;
//设置昵称
- (void)didSetUserInfo:(NSString *)userName token:(NSString *)tokenStr nickName:(NSString *)nickNameStr;
//设置用户生日
- (void)didSetUserInfo:(NSString *)userName token:(NSString *)tokenStr birthday:(NSString *)birthdayStr;
//设置性别
- (void)didSetUserInfo:(NSString *)userName token:(NSString *)tokenStr sex:(int)sexValue;
//设置用户信息
- (void)didSetUserInfo:(NSString *)userName token:(NSString *)tokenStr nickName:(NSString *)nickNameStr birthday:(NSString *)birthdayStr sex:(int)sexValue;
-(int)didOnline:(NSString*)userName token:(NSString*)token robotId:(NSString*)Id;
@property(nonatomic,weak) NSTimer *timer;

@end
