//
//  CCDirectorExtension.m
//  Brazil
//
//  Created by zhaozilong on 12-12-26.
//
//

#import "CCDirectorExtension.h"

@implementation CCDirector (Extension)

-(void) popSceneWithTransition: (Class)transitionClass duration:(ccTime)t;
{
    NSAssert( runningScene_ != nil, @"A running Scene is needed");
    
    [scenesStack_ removeLastObject];
    NSUInteger c = [scenesStack_ count];
    if( c == 0 ) {
        [self end];
    } else {
        CCScene* scene = [transitionClass transitionWithDuration:t scene:[scenesStack_ objectAtIndex:c-1]];
        [scenesStack_ replaceObjectAtIndex:c-1 withObject:scene];
        nextScene_ = scene;
    }
}

@end
