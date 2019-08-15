//
//  FileUpload.h
//  RobotDemo
//
//  Created by andy.wang on 16/8/31.
//  Copyright © 2016年 andy.wang. All rights reserved.
//

#ifndef FileUpload_h
#define FileUpload_h

@protocol UploadFileDelegate <NSObject>

- (int)onUploadFileComplete:(int)status fileName:(NSString*)name fileId:(int)fileId;

@end


@interface FileUpload : NSObject {
    
}

//- (void)upload:(NSString *)name filename:(NSString *)filename data:(NSData *)data parmas:(NSDictionary *)params;
- (BOOL)uploadFile:(NSURL *)fileUrl fileName:(NSString*)fileName fromUser:(NSString*)fromUser toUser:(NSString*)toUser token:(NSString*)token;

@property (nonatomic, weak) id <UploadFileDelegate> uploadFileDelegate;

@end


#endif /* FileUpload_h */
