//
//  ZZNavBar.m
//  Brazil
//
//  Created by zhaozilong on 12-11-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZZNavBar.h"
//#import "EggsScene.h"
//#import "TrafficScene.h"
//#import "SaiZiScene.h"
//#import "RailwayScene.h"
#import "GuessScene.h"
//#import "NoSmokingScene.h"
#import "StartLayer.h"
//#import "HeartScene.h"
//#import "SmileScene.h"
#import "WhoScene.h"

//判断设备是IPHONE还是IPAD
#define IPAD_DEVICE [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define IPHONE5_DEVICE [[UIScreen mainScreen] bounds].size.height == 568.000000

#define EFFECT_GO @"goEffect.caf"
#define EFFECT_BACK @"backEffect.caf"

@interface ZZNavBar(){
    KayacSceneTag _KSTag;
}

@end

@implementation ZZNavBar

- (void)dealloc {
    
    CCLOG(@"navbar dealloc");
    [super dealloc];
}

- (id)init {
    
    if (self = [super init]) {
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"NextPrev.plist"];
        
        
        //加返回按钮和主页按钮
        CCSprite *prevSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"PrevButton.png"]];
        CCSprite *prevHLSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"PrevButton_HL.png"]];
        CCMenuItem *prevItem = [CCMenuItemImage itemFromNormalSprite:prevSprite selectedSprite:prevHLSprite target:self selector:@selector(transToPrevScene)];
        
        CCSprite *nextSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"NextButton.png"]];
        CCSprite *nectHLSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"NextButton_HL.png"]];
        CCMenuItem *nextItem = [CCMenuItemImage itemFromNormalSprite:nextSprite selectedSprite:nectHLSprite target:self selector:@selector(transToNextScene)];
        
        CCMenu *nextPrevMenu = [CCMenu menuWithItems:prevItem, nextItem, nil];
        
        nextPrevMenu.position = ccp(0, 0);
        prevItem.anchorPoint = ccp(0, 0);
        prevItem.position = ccp(0, 0);
        nextItem.anchorPoint = ccp(1, 0);
        nextItem.position = ccp(size.width, 0);
        [self addChild:nextPrevMenu];
    }
    
    return self;
}

- (void)setKayacSceneTag:(KayacSceneTag)KST {
    _KSTag = KST;
}

- (void)transToNextScene {
    
    CCScene *nextScene = nil;
    switch (_KSTag) {
        case KayacSceneStartTag:
//            nextScene = [EggsScene scene];
            break;
            
        case KayacSceneMyNameTag:
//            nextScene = [HeartScene scene];
//            nextScene = [SmileScene scene];
            break;
            
        case KayacSceneHeartTag:
//            nextScene = [TrafficScene scene];
            break;
            
        case KayacSceneTravelTag:
//            nextScene = [SaiZiScene scene];
            break;
            
        case KayacSceneSaiziTag:
//            nextScene = [NoSmokingScene scene];
            break;
            
        case KayacSceneNoSmokingTag:
//            nextScene = [RailwayScene scene];
            break;
            
        case KayacSceneMetroTag:
            nextScene = [WhoScene scene];
            break;
            
        case KayacSceneWhoTag:
            nextScene = [GuessScene scene];
            break;
            
        case KayacSceneGuessProTag:
//            nextScene = [SmileScene scene];
            break;
            
        case KayacSceneSmileTag:
            nextScene = [StartLayer scene];
            break;
            
        case KayacSceneFinalTag:
//            <#statements#>
            break;
            
        default:
            break;
    }

    [ZZNavBar playBackEffect];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5 scene:nextScene]];

}


- (void)transToPrevScene {
    
    CCScene *prevScene = nil;
    switch (_KSTag) {
        case KayacSceneStartTag:
//            prevScene = [EggsScene scene];
            break;
            
        case KayacSceneMyNameTag:
            prevScene = [StartLayer scene];
            break;
            
        case KayacSceneHeartTag:
//            prevScene = [EggsScene scene];
            break;
            
        case KayacSceneTravelTag:
//            prevScene = [HeartScene scene];
            break;
            
        case KayacSceneSaiziTag:
//            prevScene = [TrafficScene scene];
            break;
            
        case KayacSceneNoSmokingTag:
//            prevScene = [SaiZiScene scene];
            break;
            
        case KayacSceneMetroTag:
//            prevScene = [NoSmokingScene scene];
            break;
            
        case KayacSceneWhoTag:
//            prevScene = [RailwayScene scene];
            break;
            
        case KayacSceneGuessProTag:
            prevScene = [WhoScene scene];
            break;
            
        case KayacSceneSmileTag:
            prevScene = [GuessScene scene];
            break;
            
        case KayacSceneFinalTag:
            //            <#statements#>
            break;
            
        default:
            break;
    }
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5 scene:prevScene]];
}

+ (BOOL)isiPad {
    
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+ (BOOL)isiPhone5 {
    return ([[UIScreen mainScreen] bounds].size.height == 568.000000);
}

+ (BOOL)isiPhoneNormalScreen {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size) : NO);
}

+ (BOOL)isiPadRetina {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1536, 2048), [[UIScreen mainScreen] currentMode].size) : NO);
}

+ (BOOL)isiPhone4Retina {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO);
}

+ (void)playGoEffect {
    [[SimpleAudioEngine sharedEngine] playEffect:EFFECT_GO];
}

+ (void)playBackEffect {
    [[SimpleAudioEngine sharedEngine] playEffect:EFFECT_BACK];
}
@end
