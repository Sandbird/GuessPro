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

/** Makes loading device-dependant resoures (assets) easier. By default it simply assumes all iPad resources to be suffixed
 by "-ipad" before the filename extension. On iPhone/iPod Touch it will simply return the given filename, so the overhead is minimal
 while the iPad has enough power to cope with modifying a resource strings on the fly. */
@interface AssetHelper : NSObject
{

}

/** Takes a string that is a filename (with or without path component) and returns the correct filename depending on the current device.
 On iPhone/iPod Touch it will simply return fileName. On iPad it will append "-ipad" to the filename and before the suffix and return that.
 By naming all corresponding iPad assets with the "-ipad" suffix and using this function you can avoid a lot of #ifdef and load different
 resource files with the same code. */
+(NSString*) getDeviceSpecificFileNameFor:(NSString*)fileName;

+(NSString *)filename:(NSString *)filename forDevice:(NSString *)device;
+(BOOL)isFilename:(NSString *)filename existForDevice:(NSString *)device;
@end
