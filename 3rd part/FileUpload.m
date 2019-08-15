//
//  FileUpload.m
//  RobotDemo
//
//  Created by andy.wang on 16/8/31.
//  Copyright © 2016年 andy.wang. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include "FileUpload.h"
#import "RobotControl.h"

#define StrEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]

@implementation FileUpload

- (BOOL)upload:(NSString *)name filename:(NSString *)filename data:(NSData *)data parmas:(NSDictionary *)params
{
    // 文件上传
    NSURL *url = [NSURL URLWithString:@"http://robosys.cc:6789/upload.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 设置请求体
    NSMutableData *body = [NSMutableData data];
    
    /***************文件参数***************/
    // 参数开始的标志
    [body appendData:StrEncode(@"--YY\r\n")];
    // name : 指定参数名(必须跟服务器端保持一致)
    // filename : 文件名
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename];
    [body appendData:StrEncode(disposition)];
    NSString *type = [NSString stringWithFormat:@"Content-Type: audio/mp4a-latm\r\n"];
    [body appendData:StrEncode(type)];

    [body appendData:StrEncode(@"\r\n")];
    [body appendData:data];
    [body appendData:StrEncode(@"\r\n")];
    
    /***************普通参数***************/
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // 参数开始的标志
        [body appendData:StrEncode(@"--YY\r\n")];
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key];
        [body appendData:StrEncode(disposition)];
        
        [body appendData:StrEncode(@"\r\n")];
        [body appendData:StrEncode(obj)];
        [body appendData:StrEncode(@"\r\n")];
    }];
    
    /***************参数结束***************/
    // YY--\r\n
    [body appendData:StrEncode(@"--YY--\r\n")];
    request.HTTPBody = body;
    
    // 设置请求头
    // 请求体的长度
    [request setValue:[NSString stringWithFormat:@"%zd", body.length] forHTTPHeaderField:@"Content-Length"];
    // 声明这个POST请求是个文件上传
    [request setValue:@"multipart/form-data; boundary=YY" forHTTPHeaderField:@"Content-Type"];
    
    __block int isSuccess = false;

    RobotControl* control = [RobotControl shareInstance];
    control.buf = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSData *res = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (res)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableLeaves error:nil];

        NSString *idStr = [dict objectForKey:@"id"];
        NSString *fileName = [dict objectForKey:@"file_name"];

        [control.buf addObject:[[idStr stringByAppendingString:@"@"] stringByAppendingString:fileName]];
        
        isSuccess = true;
    }
    return isSuccess;
}


- (BOOL)uploadFile:(NSURL *)fileUrl fileName:(NSString*)fileName fromUser:(NSString*)fromUser toUser:(NSString*)toUser token:(NSString*)token
{
    NSData *data = [NSData dataWithContentsOfURL:fileUrl];
    NSString *fromUserFormat = [NSString stringWithFormat:@"app_%@", fromUser];
    NSString *toUserFormat = [NSString stringWithFormat:@"rbt_%@", toUser];
    return [self upload:@"file" filename:fileName data:data parmas:@{
                                                                @"fromUser" : fromUserFormat,
                                                                @"toUser" : toUserFormat,
                                                                @"token" : token
                                                             }];
}
    
@end




