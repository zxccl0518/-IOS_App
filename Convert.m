//
//  Convert.m
//  robosys
//
//  Created by Cheer on 16/9/20.
//  Copyright © 2016年 joekoe. All rights reserved.
//

#import "Convert.h"

@implementation Convert


- (NSString*)audioToMp3:(NSString*)recordUrl

{
    //去掉文件头
    recordUrl = [recordUrl stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    NSString *returnPath = [recordUrl substringToIndex: [recordUrl rangeOfString:@"/" options:NSBackwardsSearch].location];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *mp3FilePath = [[[returnPath stringByAppendingString:@"/"] stringByAppendingString: strDate] stringByAppendingString:@".mp3"];
    
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([recordUrl cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        
        
        const int PCM_SIZE = 8192;
        
        const int MP3_SIZE = 8192;
        
        short int pcm_buffer[PCM_SIZE*2];
        
        unsigned char mp3_buffer[MP3_SIZE];
        
        
        
        lame_t lame = lame_init();
        
        lame_set_in_samplerate(lame, 8000.0);
        
        lame_set_VBR(lame, vbr_default);
        
        lame_set_quality(lame, 2);
        
        lame_init_params(lame);
        
        
        do {
            
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            
            if (read == 0)
                
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            
            else
                
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            
            
            fwrite(mp3_buffer, write, 1, mp3);
            
            
            
        } while (read != 0);
        
        
        
        lame_close(lame);
        
        fclose(mp3);
        
        fclose(pcm);
        
    }
    
    @catch (NSException *exception) {
        
        NSLog(@"%@",[exception description]);
        
    }
    
    @finally {
        
        recordUrl = mp3FilePath;
        
        NSLog(@"MP3生成成功: %@",recordUrl);
 
        //[[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:recordUrl] error:nil];        // 生成文件移除原文件
        
        return recordUrl;
        
    }
    
}

@end
