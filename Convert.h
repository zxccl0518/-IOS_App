//
//  Convert.h
//  robosys
//
//  Created by Cheer on 16/9/20.
//  Copyright © 2016年 joekoe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

@interface Convert : NSObject

- (NSString*)audioToMp3:(NSString*)recordUrl;

@end
