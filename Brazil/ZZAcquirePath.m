//
//  ZZAcquirePath.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-9.
//
//

#import "ZZAcquirePath.h"

@implementation ZZAcquirePath

//获取bundle目录
+ (NSString *)getBundleDirectoryWithFileName:(NSString *)fileName {
    return [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
}

+ (NSString *)getDocDirectoryWithFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userDbDir = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
    return userDbDir;
}


@end
