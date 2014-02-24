//
//  ZZNavBar.h
//  Brazil
//
//  Created by zhaozilong on 12-11-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
//#import "ChooseBallLayer.h"
#import "SimpleAudioEngine.h"

#define isPadRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1536, 2048), [[UIScreen mainScreen] currentMode].size) : NO)

// 是否模拟器
#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

typedef enum {
    KayacSceneStartTag,
    KayacSceneMyNameTag,
    KayacSceneHeartTag,
    KayacSceneTravelTag,
    KayacSceneSaiziTag,
    KayacSceneNoSmokingTag,
    KayacSceneMetroTag,
    KayacSceneWhoTag,
    KayacSceneGuessProTag,
    KayacSceneSmileTag,
    KayacSceneFinalTag,
}KayacSceneTag;


@interface ZZNavBar : CCLayer 


- (void)setKayacSceneTag:(KayacSceneTag)KST;
- (void)transToPrevScene;
- (void)transToNextScene;

+ (BOOL)isiPad;

+ (BOOL)isiPhone5;

+ (BOOL)isiPhoneNormalScreen;

+ (BOOL)isiPadRetina;

+ (BOOL)isiPhone4Retina;

+ (void)playGoEffect;

+ (void)playBackEffect;

@end
