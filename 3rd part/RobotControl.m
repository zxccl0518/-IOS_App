//
//  RobotControl.m
//  RobotDemo-Swift
//
//  Created by Cheer on 16/5/25.
//  Copyright © 2016年 Cheer. All rights reserved.
//

#import "RobotControl.h"

static RobotControl *instance = nil;

@implementation RobotControl

+ (RobotControl *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
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
        _isNeedPause = false;
    }
    return self;
}

//前进
- (void)didForward:(int)speed
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->forward(pRobotCtrl, speed, 0, 0);
}



//停止运动
- (void)didStop
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->stopRun(pRobotCtrl);
}

//左转
- (void)didTurnLeft:(int)speed otherSpeed:(int)angle
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->turn(pRobotCtrl, speed, angle);
}

//右转
- (void)didTurnRight:(int)speed otherSpeed:(int)angle
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->turn(pRobotCtrl, angle, speed);
}

//后退
- (void)didFallback:(int)speed
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->fallback(pRobotCtrl, speed, 0, 0);
}

//顺时针旋转(运动)
- (void)didClosewise
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->clockwiseWhirl(pRobotCtrl, 1, 360);
}

//逆时针旋转(运动)
- (void)didCounterClosewise
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->counterClockwiseWhirl(pRobotCtrl, 1, 360);
    
}
//顺时针旋转(编程)
- (void)didClosewise:(int)speed time:(int)time
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->clockwiseWhirlByTime(pRobotCtrl, speed, time);
}
//逆时针旋转(编程)
- (void)didCounterClosewise:(int)speed time:(int)time
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->counterclockwiseWhirlByTime(pRobotCtrl, speed, time);
}

//摇头
- (void)didShake:(int)speed times:(int)times
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->shake(pRobotCtrl, speed, times, 40);
}

//点头 int speed, int times
- (void)didNod:(int)speed times:(int)times
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->nod(pRobotCtrl, speed, times, 8);
}

//向上看
- (void)didLookUp
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->lookUp(pRobotCtrl);
}

//向前看
- (void)didLookForward
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->lookForward(pRobotCtrl);
}

//向右看
- (void)didLookRight
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->lookRight(pRobotCtrl);
}

//向下看
- (void)didLookDown
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->lookDown(pRobotCtrl);
}

//向左看
- (void)didLookLeft
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->lookLeft(pRobotCtrl);
}

//播放合成音
- (void)didPlaySST:(NSString*)text
{
    if(text.length == 0)
    {
        return;
    }
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->sst(pRobotCtrl, [text UTF8String]);
}

//播放录音
- (void)didPlayRecord:(NSString*)filePath name:(NSString*)fileName num:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId
{
    FileUpload *fileUpload = [[FileUpload alloc] init];
    
    [fileUpload uploadFile:[[NSURL alloc] initFileURLWithPath:filePath] fileName:fileName fromUser:num toUser:robotId token:token];
    dispatch_semaphore_signal(_semaphoreMain);
}
//播放音频
- (void)didPlayAudio:(NSString*)filePath name:(NSString*)fileName num:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId
{
    FileUpload *fileUpload = [[FileUpload alloc] init];
    
    [fileUpload uploadFile:[[NSURL alloc] initFileURLWithPath:filePath] fileName:fileName fromUser:num toUser:robotId token:token];
    dispatch_semaphore_signal(_semaphoreMain);
    
}

//转换成mp3
- (BOOL) convertToMp3: (NSURL*)url fileName:(NSString*)fileName num:(NSString*)num token:(NSString*)token robotId:(NSString*)robotId
{
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    
    NSLog (@"compatible presets for songAsset: %@",[AVAssetExportSession exportPresetsCompatibleWithAsset:songAsset]);
    
    NSArray *ar = [AVAssetExportSession exportPresetsCompatibleWithAsset: songAsset];
    NSLog(@"%@", ar);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: songAsset
                                      presetName: AVAssetExportPresetAppleM4A];
    
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    
    exporter.outputFileType = @"com.apple.m4a-audio";
    
    NSString *exportFile = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",fileName]];
    
    NSError *error1;
    
    if([fileManager fileExistsAtPath:exportFile])
    {
        [fileManager removeItemAtPath:exportFile error:&error1];
    }
    
    NSURL* exportURL = [NSURL fileURLWithPath:exportFile];
    
    
    
    exporter.outputURL = exportURL;
    __block BOOL isSuccess = false;
    
    _semaphore = dispatch_semaphore_create(0);
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         int exportStatus = exporter.status;
         
         switch (exportStatus) {
                 
             case AVAssetExportSessionStatusFailed: {
                 
                 // log error to text view
                 NSError *exportError = exporter.error;
                 
                 NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                 
                 break;
             }
                 
             case AVAssetExportSessionStatusCompleted: {
                 
                 NSLog (@"AVAssetExportSessionStatusCompleted");
                 FileUpload *fileUpload = [[FileUpload alloc] init];
                 isSuccess = [fileUpload uploadFile:exportURL fileName:[fileName stringByAppendingString:@".m4a"] fromUser:num toUser:robotId token:token];
                 dispatch_semaphore_signal(_semaphore);
                 break;
             }
                 
             case AVAssetExportSessionStatusUnknown: {
                 NSLog (@"AVAssetExportSessionStatusUnknown");
                 break;
             }
             case AVAssetExportSessionStatusExporting: {
                 NSLog (@"AVAssetExportSessionStatusExporting");
                 break;
             }
                 
             case AVAssetExportSessionStatusCancelled: {
                 NSLog (@"AVAssetExportSessionStatusCancelled");
                 break;
             }
                 
             case AVAssetExportSessionStatusWaiting: {
                 NSLog (@"AVAssetExportSessionStatusWaiting");
                 break;
             }
                 
             default:
             { NSLog (@"didn't get export status");
                 break;
             }
         }
     }];
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    return isSuccess;
}

-(int)onUploadFileComplete:(int)status fileName:(NSString*)name fileId:(int)fileId
{
    //    _isNeedPause = false;
    //
    //    NSDictionary *dict  = [self didPushScript:name audioId:fileId];
    //
    //    _buf =  [_buf stringByAppendingString: dict[@"audioInfoBuf"]];
    //    _length = _length + (NSInteger)dict[@"audioInfoLength"];
    //
    //    dispatch_semaphore_signal(_semaphore);
    
    return fileId;
}



//眼睛表情
- (void)didEye:(int)eyeNum
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->setRobotEye(pRobotCtrl, eyeNum);
}

//耳朵效果
- (void)didEar:(int)earNum
{
    //    NSString *earNumStr = [[self editEar] text];
    //    int earNum = [earNumStr intValue];
    //
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->setRobotEar(pRobotCtrl, earNum);
}

//音乐播放
- (void)didMusicPlay{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->musicCtrl(pRobotCtrl, 0);
}

//音乐播放停止
- (void)didMusicStop{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->musicCtrl(pRobotCtrl, 3);
    
    
}
//故事播放
- (void)didStoryPlay
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->storyCtrl(pRobotCtrl, 0, "");
    
}

//故事播放停止
- (void)didStoryStop
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->storyCtrl(pRobotCtrl, 3, "");
}

//停止媒体播放
- (void)didMediaStop
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->stopAudioPlay(pRobotCtrl);
}


//查询Wifi列表
- (NSDictionary *)didQueryWifiList{
    
    char wifiStr[10*1024] = {0};
    
    //获取单例
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    int ret = pRobotCtrl->queryRobotWifiList(pRobotCtrl, wifiStr);
    
    
    if (ret < 0) {
        
        return nil;
    }
    
        NSString *str = [NSString stringWithCString:wifiStr encoding:NSUTF8StringEncoding];
    
        NSLog(@"-----------------------------------\n %@",str);
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
//        NSLog(@"%@",data);
    
        NSError *error;
    
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
        if(error != nil){
            
//            NSLog(@"%@",error);
            
            return nil;
        }
    else{
        
        NSLog(@"+++++++++++++++++++++++++++++++++++\n %@",dict);
        return dict;
    }
    
    
    
}

//连接指定 wifi
- (void)didSetSpecifiedSSID:(NSString *)ssid passWord:(NSString *)passWord{
    
    NSMutableDictionary *MDic = [[NSMutableDictionary alloc]init];
    MDic[@"SSID"] = ssid;
    MDic[@"Password"] = passWord;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:MDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    const char *a = [dataString UTF8String];
    
    NSLog(@"************** %s",a);
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    pRobotCtrl->connectSpecifiedWifi(pRobotCtrl,a,(int)[dataString length]);
}

//还原网络设置
- (void)reSetWifiConfig{
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    pRobotCtrl->reSetWifiConfig(pRobotCtrl);
    
}

// 获取指定歌单的音乐列表
-(NSMutableArray*)didGetAlbumList:(int)musicId page:(int)page {
    
    MusicItem musiclist[100] = {0};
    MusicItem *ppMusicList[100] = {0};
    
    for(int i = 0;i < 100;i++)
    {
        ppMusicList[i] = &musiclist[i];
    }
    
    
    //获取单例
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    int ret = pRobotCtrl->playerGetAlbumList(pRobotCtrl, musicId, page, ppMusicList);
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    if (ret == 0)
    {
        for (int i = 0;i<100;i++)
        {
            if (musiclist[i].name != 0) {
                
                NSString *tempString = [NSString stringWithCString:musiclist[i].name encoding:NSUTF8StringEncoding];
                
                [array addObject:tempString];
            }
            
        }
        
    }
    return array;
    
}
// 指定歌单列表--历史列表的歌曲id
-(NSMutableArray*)didGetMusicIdList:(int)musicId page:(int)page {
    
    MusicItem musiclist[100] = {0};
    MusicItem *ppMusicList[100] = {0};
    
    for(int i = 0;i < 100;i++)
    {
        ppMusicList[i] = &musiclist[i];
    }
    
    
    //获取单例
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    int ret = pRobotCtrl->playerGetAlbumList(pRobotCtrl, musicId, page, ppMusicList);
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    if (ret == 0)
    {
        for (int i = 0;i<100;i++)
        {
            if (musiclist[i].musicid != 0) {
                
                //                NSString *tempString = [NSString stringWithCString:musiclist[i].musicid encoding:NSUTF8StringEncoding];
                NSString *tempString = [NSString stringWithFormat:@"%d",musiclist[i].musicid];
                //                NSInteger tempString = musiclist[i].musicid;
//                NSLog(@"%@",tempString);
                [array addObject:tempString];
            }
            
        }
        
    }
    return array;
    
}



// 查询指定目录下的文件列表
-(NSMutableArray*)didQueryDirecMusicList:(int)page path:(NSString *)path{
    
    DirecItem musiclist[100] = {0};
    DirecItem *ppMusicList[100] = {0};
    char pathC[300] = {0};
    
    strcpy(pathC,[path UTF8String]);
    
    for(int i = 0;i < 100;i++)
    {
        ppMusicList[i] = &musiclist[i];
    }
    
    //获取单例
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    int ret = pRobotCtrl->playerQueryDirecMusicList(pRobotCtrl, page,pathC,ppMusicList);
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    if (ret == 0) {
        
        for (int i =0; i<100; i++) {
            
            if (musiclist[i].name != nil) {
                
                NSString *tempString = [NSString stringWithCString:musiclist[i].name encoding:NSUTF8StringEncoding];
                
                [array addObject:tempString];
                
            }
        }
        
        
    }
    
    
    return array;
}

// 播放音乐NEW  本地那么其路径和文件名之间用四个*号进行分割
- (void)didPlayerStart:(int)musicSouce path:(NSString*)path musicName:(NSString *)musicName{
    
    char buf[1024] = {0};
    
    sprintf(buf, "%s****%s", [path UTF8String], [musicName UTF8String]);
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->playerStart(pRobotCtrl, musicSouce, buf, (int)strlen(buf));
    
}

// 播放历史ID
- (void)didPlayerStartHistory:(int)musicSouce audioId:(int)audioId{
    
    char buf[5] = {0};
    
    buf[0] = (unsigned char)((audioId&0xFF000000)>>24);
    buf[1] = (unsigned char)((audioId&0x00FF0000)>>16);
    buf[2] = (unsigned char)((audioId&0x0000FF00)>>8);
    buf[3] = (unsigned char)((audioId&0x000000FF));
    
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->playerStart(pRobotCtrl, musicSouce, buf, 4);
    
}


// 音乐播放控制
- (void)didPlayerCtrl:(int)ctrl type:(int)type {
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    pRobotCtrl->playerCtrl(pRobotCtrl, ctrl, type);
    
}



//查询音乐列表
- (NSMutableArray*)didQueryMusicList
{
    char musiclist[300][256] = {0};
    char *ppMusicList[300] = {0};
    
    for(int i = 0;i < 300;i++)
    {
        ppMusicList[i] = &musiclist[i][0];
    }
    
    RobotCtrl *pRobotCtrl = nil;
    
    //获取单例
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    int ret = pRobotCtrl->queryRobotMusicList(pRobotCtrl, ppMusicList);
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    if (ret == 0)
    {
        if (musiclist[0][0] != 0)
        {
            for (int i = 0;i<300;i++)
            {
                NSString *tempString = [NSString stringWithCString:&musiclist[i][256] encoding:NSUTF8StringEncoding];
                if([tempString hasSuffix:@"mp3"])
                {
                    [array addObject:tempString];
                }
            }
        }
    }
    return array;
}

//播放指定音乐
- (void)didPlayMusicByIndex:(int)index;
{
    int musicIndex = index;//[musicIndexStr intValue];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->playRobotMusicByIndex(pRobotCtrl, musicIndex);
}


//音量加减
- (void)didVolumeCtrl:(int)type
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->volumeCtrl(pRobotCtrl, type);
}
//运动模式
- (void)didRunMode:(int)mode
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->setRunMode(pRobotCtrl, mode);
}
//卖萌
- (void)didCute
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->cute(pRobotCtrl);
}

//左手抬起 0-1000,精确到0.1度
- (void)didHandLeftUp:(float)angle {
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->handUp(pRobotCtrl, 0, angle, 3);
}

//左手后摆
- (void)didHandLeftBack:(float)angle {
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->handBack(pRobotCtrl, 0, angle, 3);
}

//左手摆动
- (void)didLeftHandShake:(int)num type:(int)type{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    //上下
    if (type == 0 ){
        pRobotCtrl->handShake(pRobotCtrl, 0, num, 900, 0);
    }
    else{
        pRobotCtrl->handShake(pRobotCtrl, 0, num, 300, 300);
    }
}

//右手抬起
- (void)didHandRightUp:(float)angle{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->handUp(pRobotCtrl, 1, angle, 3);
}

//右手后摆
- (void)didHandRightBack:(float)angle {
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->handBack(pRobotCtrl, 1, angle, 3);
}

//右手摆动
- (void)didHandRightShake:(int)num type:(int)type{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    //上下
    if (type == 0 ){
        pRobotCtrl->handShake(pRobotCtrl, 1, num, 900, 0);
    }
    else{
        pRobotCtrl->handShake(pRobotCtrl, 1, num, 300, 300);
    }
}

//双手交叉摆动
- (void)didHandBothShake:(id)sender {
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->handBothShake(pRobotCtrl, 5, 1000, 300);
}



//获取闹铃列表
- (NSMutableArray*)didGetAlarmList
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    AlarmItem alalrmList[100] = {0};
    AlarmItem *pAlarmList[100] = {0};
    
    for(int i = 0;i < 100;i++)
    {
        pAlarmList[i] = &alalrmList[i];
    }
    
    pRobotCtrl->getAlarmList(pRobotCtrl,1,pAlarmList);
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(int i = 0;i < 100;i++)
    {
        if (alalrmList[i].id != 0 )
        {
            AlarmItem item = alalrmList[i];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:[NSString stringWithFormat:@"%d",item.id] forKey:@"id"];
            [dic setValue:[NSString stringWithCString:item.alarmContent encoding:NSUTF8StringEncoding] forKey:@"content"];
            
            NSMutableString *leftStr = [[[ NSMutableString stringWithFormat:@"%d",item.alarmJingleHMS] stringByReplacingOccurrencesOfString:@"00" withString:@"  "] mutableCopy];
            [leftStr insertString:@":" atIndex:2];
            
            NSMutableString *rightStr = [ NSMutableString stringWithFormat:@"%d",item.alarmJingleYMD];
            [rightStr insertString:@"." atIndex:6];
            [rightStr insertString:@"." atIndex:4];
            
            [dic setValue:[leftStr stringByAppendingString:rightStr] forKey:@"date"];
            
            [dic setValue:[[NSString stringWithFormat:@"%d",item.alarmPlanYMD] stringByAppendingString:[NSString stringWithFormat:@"%d",item.alarmPlanHM]] forKey:@"time"];
            //服务器传回来是反的。。
            [dic setValue:[NSString stringWithCString:item.alarmAdvance encoding:NSUTF8StringEncoding] forKey:@"repeat"];
            [dic setValue:[NSString stringWithCString:item.alarmRepeat encoding:NSUTF8StringEncoding] forKey:@"remind"];
            
            [array addObject:dic];
        }
    }
    
    return array;
}



//设置闹铃
- (void)didSetAlarm:(NSString*)name timeString:(NSString*)time remind:(int)remind repeat:(int)repeat {
    char buf[512] = {0};
    
    sprintf(buf, "%s|%s|%d|%d", [name UTF8String], [time UTF8String], remind,repeat);
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->setAlarm(pRobotCtrl, buf);
}
//更新闹铃
- (void)didUpdateAlarm:(NSString*)name timeString:(NSString*)time remind:(int)remind repeat:(int)repeat index:(int)index
{
    char buf[512] = {0};
    
    sprintf(buf, "%s|%s|%d|%d", [name UTF8String], [time UTF8String],remind,repeat);
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->updateAlarmItem(pRobotCtrl, index, buf);
}

//删除闹铃
- (void)didDeleteAlarm:(int)index {
    RobotCtrl *pRobotCtrl = nil;
    //    int testUpdateId = 10;
    
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->deleteAlarmItem(pRobotCtrl, index);
}



//设置音量
- (void)didSetVolume:(int)volume {
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->setVolume(pRobotCtrl, volume);
}

//唤醒or休眠 1唤醒 0休眠
- (void)didWakeup:(int)value {
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->sleepCtrl(pRobotCtrl, value);
}

//讲笑话 0 开始 1 上一个 2 下一个 3 停止
- (void)didJoke:(int)value
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->jokeCtrl(pRobotCtrl, value, "");
}

//电量
-(int)didBattery
{
    int battery = 0;
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->tickRequest(pRobotCtrl,&battery);
    
    return battery;
}

//获取机器人属性
- (NSMutableDictionary *)didGetRobotAttr
{
    RobotAttr robotAttr = {0};
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->getRobotAttr(pRobotCtrl, &robotAttr);
    
    [dic setObject:[NSString stringWithUTF8String:robotAttr.robotName] forKey:@"robotName"];
    [dic setObject:[NSString stringWithUTF8String:robotAttr.masterName] forKey:@"masterName"];
    [dic setObject:[NSString stringWithUTF8String:robotAttr.mantra] forKey:@"mantra"];
    [dic setObject:[NSString stringWithUTF8String:robotAttr.birthday] forKey:@"birthday"];
    [dic setObject:@(robotAttr.constellation) forKey:@"constellation"];
    [dic setObject:@(robotAttr.sex) forKey:@"sex"];
    [dic setObject:@(robotAttr.speakSpeed) forKey:@"speakSpeed"];
    [dic setObject:@(robotAttr.speakType) forKey:@"speakType"];
    
    return dic;
}

//设置机器人属性 0--机器人名字 1--管理员姓名 2--性别 3--星座 4--生日 5--口头禅 6--音色 7--语速
- (int)didSetRobotAttr:(int)index name:(NSString*)str
{
    //设置机器人属性测试
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    int i = 0;
    char buf[128] = {0};
    
    /*
     while (i<=7)
     {
     memset(buf, 0x00, sizeof(buf));
     tempStr = arr[i];
     strcpy(buf,[tempStr UTF8String]);
     ret = pRobotCtrl->setRobotAttr(pRobotCtrl, i, buf);
     
     if (ret == 0){
     i += 1;
     }
     }*/
    memset(buf, 0x00, sizeof(buf));
    strcpy(buf,[str UTF8String]);
    return pRobotCtrl->setRobotAttr(pRobotCtrl, i, buf);
}

//- (NSDictionary*)didPushScript:(NSString*)name audioId:(int)audioId
//{
//    char audioInfoBuf[1024] = {0};
////    char scriptInfoBuf[1024] = {0};
//    char audioName[128] = {0};
//    char tmp[128] = {0};
//    int index = 0;
//
//    strcpy(audioName, [name UTF8String]);
//
//    //音频信息---【音频文件id+音频文件名长度+音频文件名+第二个文件id+第二个音频文件名长度+第二个文件名+。。。。。】
//    sprintf(tmp, "%08x%02x", audioId, (int)strlen(audioName));
//    str2hex(tmp, &audioInfoBuf[index], strlen(tmp));
//    index += strlen(tmp)/2;
//    memcpy(&audioInfoBuf[index], audioName, strlen(audioName));
//    index += strlen(audioName);
//
//    NSString* buf = [[NSString alloc] initWithCString:audioInfoBuf encoding:NSUTF8StringEncoding];
//
//    NSMutableArray *array;
//    for (int i = 0;i < index;i++)
//    {
//        [array addObject:[NSString stringWithFormat:@"%c", audioInfoBuf[i]]];
//    }
//
//    return [NSDictionary dictionaryWithObjectsAndKeys:buf,@"audioInfoBuf",@(index),@"audioInfoLength", nil];
//}

- (int)didPushScript:(NSString*)action audio:(NSArray*)audio
{
    char audioInfoBuf[1024] = {0};
    char scriptInfoBuf[1024] = {0};
    char tmp[128] = {0};
    int index = 0;
    char audioName[128] = {0};
    int audioId = 0;
    
    for (int i = 0; i < audio.count;i++)
    {
        NSString* item = audio[i];
        NSArray *temp = [item componentsSeparatedByString:@"@"];
        
        NSString *name = temp[1];
        NSString *tempId = temp[0];
        audioId = [tempId intValue];
        
        strcpy(audioName, [name UTF8String]);
        
        sprintf(tmp, "%08x%02x", audioId, (int)strlen(audioName));
        str2hex(tmp, &audioInfoBuf[index], strlen(tmp));
        index += strlen(tmp)/2;
        memcpy(&audioInfoBuf[index], audioName, strlen(audioName));
        index += strlen(audioName);
    }
    
    //脚本信息---【脚本名字，脚本内容，脚本时长】中间用逗号分割----脚本时长(分钟'秒数)
    strcpy(scriptInfoBuf,[action UTF8String]);
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    return pRobotCtrl->pushScript(pRobotCtrl, (int)audio.count, audioInfoBuf, index, scriptInfoBuf, (int)strlen(scriptInfoBuf));
}

- (void)didExecScript:(int)type Id:(int)Id
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->execScript(pRobotCtrl, type, Id);
}

//播放URL
- (int)didPlayUrl:(NSString*)str
{
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    char urlBuf[1024] = {0};
    strcpy(urlBuf, [str UTF8String]);
    return  pRobotCtrl->playUrl(pRobotCtrl,urlBuf);
}

//查询脚本
- (NSMutableArray*)didQueryScript
{
    RobotScript scriptList[1000] = {0};
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    pRobotCtrl->queryScript(pRobotCtrl, (RobotScript*)&scriptList);
    
    NSMutableArray* resultArr = [[NSMutableArray alloc] init];
    
    for (int i=0;i<1000;i++)
    {
        RobotScript script = scriptList[i];
        if (script.id)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@(script.id), @"ID",
                                  @(script.name), @"name",
                                  @(script.time), @"time",
                                  @(script.date), @"date",nil];
            [resultArr addObject:dict];
        }
    }
    return  resultArr;
}

//批量删除脚本
-(int)deleteScriptMulti:(NSMutableArray<NSString*>*)scriptIdArry
{
    int scriptIdBuf[1024] = {0};
    for (int i=0; i<scriptIdArry.count; i++) {
        scriptIdBuf[i] = [scriptIdArry objectAtIndex:i].intValue;
    }
    int count = (int)scriptIdArry.count;
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    return  pRobotCtrl->deleteScriptMulti(pRobotCtrl,count,scriptIdBuf);
}

//发送学习
- (void)didStudy:(NSString*)courseid coursetitle:(NSString*)coursetitle coursepath:(NSString*)coursepath stop:(NSString*)stop{
    
    RobotCtrl *pRobotCtrl = nil;
    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
    
    
    NSLog(@"courseid : %@,coursetitle:%@,coursepath:%@,stop:%@",courseid,coursetitle,coursepath,stop);
    
    pRobotCtrl->study(pRobotCtrl,[courseid UTF8String], [coursetitle UTF8String], [coursepath UTF8String],[stop UTF8String],0);
}

//- (void)didStudy:(NSDictionary *)dataDict{
//    
//    RobotCtrl *pRobotCtrl = nil;
//    RobotCtrl_GetRobotCtrl(&pRobotCtrl);
//    
//    char urlBuf[1024] = {0};
//    
////    strcpy(urlBuf, [dataString UTF8String]);
//    
//    pRobotCtrl->study(pRobotCtrl,urlBuf);
//}


@end
