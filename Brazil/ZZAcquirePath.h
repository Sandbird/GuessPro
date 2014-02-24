//
//  ZZAcquirePath.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-9.
//
//

#import <Foundation/Foundation.h>

@interface ZZAcquirePath : NSObject

+ (NSString *)getBundleDirectoryWithFileName:(NSString *)fileName;
+ (NSString *)getDocDirectoryWithFileName:(NSString *)fileName;

@end
