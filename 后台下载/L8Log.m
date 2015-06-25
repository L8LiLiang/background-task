//
//  L8Log.m
//  后台下载
//
//  Created by 李亮 on 15/6/25.
//  Copyright (c) 2015年 李亮. All rights reserved.
//

#import "L8Log.h"


@implementation L8Log

static NSOutputStream *stream;

/*
 * 丑陋的log处理类，用于写日志到log.log文件，参数只能传oc对象，不能传c变量（比如int），
 * 并且参数必需以nil结尾
 * 因为，系统重新启动我们的应用程序之后，会把程序置为background状态，
 * 此时在控制台看不到日志信息，所有需要写到log文件中，便于调试
 */

+(void)log:(NSString *)format, ...
{
    [self openStream];
    if (format) {
        va_list start;
        va_start(start, format);
        NSMutableString *result = [NSMutableString string];
        while (1) {
            
            id obj = va_arg(start, id);
            if (obj == nil) {
                break;
            }
            [result appendFormat:@"%@\n",obj];
        }
        va_end(start);
        
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        
        [stream write:data.bytes maxLength:data.length];
    }
}


+(void)openStream
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stream = [NSOutputStream outputStreamToFileAtPath:[self logDir] append:YES];
        [stream open];
    });
}

+(void)closeStream
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [stream close];
    });
}


+(NSString *)logDir
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"log.log"];
    NSLog(@"%@",path);
    return path;
}


@end
