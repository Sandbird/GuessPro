//
//  CCDirectorExtension.h
//  Brazil
//
//  Created by zhaozilong on 12-12-26.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCDirector(Extension)

/**Pops scene with transitions
 */
- (void) popSceneWithTransition: (Class)c duration:(ccTime)t;

@end
