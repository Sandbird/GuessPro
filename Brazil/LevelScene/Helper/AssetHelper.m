/*
 * cocos2d-project http://www.learn-cocos2d.com
 *
 * Copyright (c) 2010 Steffen Itterheim
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "AssetHelper.h"


@interface AssetHelper (Private)
@end

@implementation AssetHelper

+(NSString*) getDeviceSpecificFileNameFor:(NSString*)fileName
{    
	#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	BOOL deviceIsPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
	if (deviceIsPad) {
		if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
            return fileName;
        } else {
            if ([AssetHelper isFilename:fileName existForDevice:@"ipad"]) {
                return [AssetHelper filename:fileName forDevice:@"ipad"]; 
                
            } else if ([AssetHelper isFilename:fileName existForDevice:@"hd"]) {
                return [AssetHelper filename:fileName forDevice:@"hd"]; 
                
            } else {
                return fileName;
            }
        }
        
    } else {
        return fileName;
    }
 
	#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
   
    if ([AssetHelper isFilename:fileName existForDevice:@"mac"]) {
        return [AssetHelper filename:fileName forDevice:@"mac"];
        
    } else if ([AssetHelper isFilename:fileName existForDevice:@"ipad"]) {
       return [AssetHelper filename:fileName forDevice:@"ipad"]; 
        
    } else if ([AssetHelper isFilename:fileName existForDevice:@"hd"]) {
        return [AssetHelper filename:fileName forDevice:@"hd"]; 
    } else {
        return fileName;
    }

    return fileName;

	#endif

}
+(NSString *)filename:(NSString *)filename forDevice:(NSString *)device {
    NSString* justFileName = [filename stringByDeletingPathExtension];
    justFileName = [justFileName stringByAppendingString:[NSString stringWithFormat:@"-%@", device]];
    NSString* extension = [filename pathExtension];
    if ([extension length] > 0) {
        justFileName = [justFileName stringByAppendingPathExtension:extension];
    }
    return justFileName;
}

+(BOOL)isFilename:(NSString *)filename existForDevice:(NSString *)device {
    
    NSString* justFileName = [filename stringByDeletingPathExtension];
    justFileName = [justFileName stringByAppendingString:[NSString stringWithFormat:@"-%@", device]];
    NSString* extension = [filename pathExtension];
    
    NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:justFileName ofType:extension];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:pathAndFileName]) {
        return true;
    } else {
        return false;
    }
    
}



@end
