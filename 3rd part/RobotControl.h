//
//  RobotControl.h
//  RobotDemo-Swift
//
//  Created by Cheer on 16/5/25.
//  Copyright © 2016年 Cheer. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "RobotCtrl.h"
#import "FileUpload.h"
#import <MediaPlayer/MediaPlayer.h>

@interface RobotControl : NSObject <UploadFileDelegate>

@property(nonatomic, weak) UITextField *labelMsg;
@property(nonatomic, weak) UITextField *editEye;
@property(nonatomic, weak) UITextField *editEar;
@property(nonatomic, weak) UITextField *editPlayIndex;




@property(nonatomic, strong) NSMutableArray *buf;
@property(nonatomic, assign) NSInteger length;
@property(nonatomic, strong) dispatch_semaphore_t semaphore;
@property(nonatomic, strong) dispatch_semaphore_t semaphoreMain;
@property(nonatomic, assign) BOOL isNeedPause;


+ (RobotControl *)shareInstance;
//限制方法，类只能初始化一次
//alloc的时候调用
+ (id) allocWithZone:(struct _NSZone *)zone;
//拷贝方法
- (id)copyWithZone:(NSZone *)zone;

//前进
- (void)didForward:(int)speed;


//左转
- (void)didTurnLeft:(int)speed otherSpeed:(int)other;
//右转
- (void)didTurnRight:(int)speed otherSpeed:(int)other;
//后退
- (void)didFallback:(int)speed;
//顺时针旋转(运动)
- (void)didClosewise;
//逆时针旋转(运动)
- (void)didCounterClosewise;
//顺时针旋转(编程)
- (void)didClosewise:(int)speed time:(int)time;
//逆时针旋转(编程)
- (void)didCounterClosewise:(int)speed time:(int)time;

//摇头
- (void)didShake:(int)speed times:(int)times;
//点头
- (void)didNod:(int)speed times:(int)times;
//向上看
- (void)didLookUp;
//向前看
- (void)didLookForward;
//向右看
- (void)didLookRight;
//向下看
- (void)didLookDown;
//向左看
- (void)didLookLeft;


//播放合成音
- (void)didPlaySST:(NSString*)text;
//播放录音
- (void)didPlayRecord:(NSString*)filePath name:(NSString*)fileName num:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId;
//播放音频
- (void)didPlayAudio:(NSString*)filePath name:(NSString*)fileName num:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId;

//眼睛表情
- (void)didEye:(int)eyeNum;
//耳朵效果
- (void)didEar:(int)earNum;
//停止运动
- (void)didStop;
//音量加减,type = 0-,type = 1+
- (void)didVolumeCtrl:(int)type;

//查询wifi列表
- (NSDictionary *)didQueryWifiList;

//连接指定wifi  发送的是 json 字典
- (void)didSetSpecifiedSSID:(NSString *)ssid passWord:(NSString *)passWord;

//还原网络设置
- (void)reSetWifiConfig;

//------ 新添接口 ------
// 获取指定歌单的音乐列表0历史列表
-(NSMutableArray*)didGetAlbumList:(int)musicId page:(int) page;
-(NSMutableArray*)didGetMusicIdList:(int)musicId page:(int)page;
// 查询指定目录下文件列表
-(NSMutableArray*)didQueryDirecMusicList:(int)page path:(NSString*)path;
// 播放音乐NEW
- (void)didPlayerStart:(int)musicSouce path:(NSString*)path musicName:(NSString*)musicName;
- (void)didPlayerStartHistory:(int)musicSouce audioId:(int)audioId;
// 播放音乐控制
- (void)didPlayerCtrl:(int)ctrl type:(int)type;


//查询音乐列表
- (NSMutableArray*)didQueryMusicList;
//播放指定音乐
- (void)didPlayMusicByIndex:(int)index;
//音乐播放
- (void)didMusicPlay;
//音乐播放停止
- (void)didMusicStop;
//故事播放
- (void)didStoryPlay;
//故事播放停止
- (void)didStoryStop;
//停止媒体播放
- (void)didMediaStop;

//运动模式
- (void)didRunMode:(int)mode;
//卖萌
- (void)didCute;


//左手抬起
- (void)didHandLeftUp:(float)angle;
//左手后摆
- (void)didHandLeftBack:(float)angle;
//左手摆动
- (void)didLeftHandShake:(int)num type:(int)type;
//右手抬起
- (void)didHandRightUp:(float)angle;
//右手后摆
- (void)didHandRightBack:(float)angle;
//右手摆动
- (void)didHandRightShake:(int)num type:(int)type;
//双手交叉摆动
- (void)didHandBothShake:(id)sender;

;
//获取闹铃列表
- (NSMutableArray*)didGetAlarmList;
//设置闹铃
- (void)didSetAlarm:(NSString*)name timeString:(NSString*)time remind:(int)remind repeat:(int)repeat;
//更新闹铃
- (void)didUpdateAlarm:(NSString*)name timeString:(NSString*)time remind:(int)remind repeat:(int)repeat index:(int)index;
//删除闹铃
- (void)didDeleteAlarm:(int)index;


//设置音量
- (void)didSetVolume:(int)volume;
//唤醒or休眠 1唤醒 0休眠
- (void)didWakeup:(int)value;

//讲笑话 
- (void)didJoke:(int)value;
//电量
-(int)didBattery;

//获取机器人属性
- (NSMutableDictionary *)didGetRobotAttr;

//播放URL
- (int)didPlayUrl:(NSString*)str;
//批量删除脚本
-(int)deleteScriptMulti:(NSMutableArray<NSString*>*)scriptIdArry;

//设置机器人属性
- (int)didSetRobotAttr:(int)index name:(NSString*)str;

//- (NSDictionary*)didPushScript:(NSString*)name audioId:(int)audioId;

- (int)didPushScript:(NSString*)action audio:(NSArray*)audio;

- (void)didExecScript:(int)type Id:(int)Id;

- (NSMutableArray*)didQueryScript;

- (void)didStudy:(NSString*)courseid coursetitle:(NSString*)coursetitle coursepath:(NSString*)coursepath stop:(NSString*)stop;

@end
