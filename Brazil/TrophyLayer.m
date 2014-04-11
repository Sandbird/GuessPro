//
//  TrophyLayer.m
//  GuessProMovie
//
//  Created by zhaozilong on 14-4-11.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "TrophyLayer.h"


@interface TrophyLayer () {
    CCMenu *_menu;
    GPNavBar *_navBar;
}

@end


@implementation TrophyLayer

+(id)scene {
	CCScene *scene = [CCScene node];
	TrophyLayer *layer = [TrophyLayer node];
	[scene addChild: layer];
	return scene;
}

- (void)dealloc {
    
    
    CCLOG(@"TrophyLayer is dealloc");
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
//        self.isTouchEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
        [self addChild:color];
        
        CGFloat posY;
        CGSize wordSize;
        CGFloat textFontSize;
//        CGPoint trophyPos;
        CGFloat deltaY;
        if ([GPNavBar isiPad]) {
            posY = winSize.height - 160.0f;
            wordSize = CGSizeMake(600, 800);
            textFontSize = 70;
            deltaY = 650;
        } else if ([GPNavBar isiPhone5]) {
            posY = winSize.height - 80.0f;
            wordSize = CGSizeMake(280, 400);
            textFontSize = 30;
            deltaY = 350;
        } else {
            posY = winSize.height - 80.0f;
            wordSize = CGSizeMake(250, 350);
            textFontSize = 30;
            deltaY = 290;
        }
        
        NSString *title = @"更多关卡 即将发布";
        
        CCLabelTTF *labelTitle = [CCLabelTTF labelWithString:title fontName:FONTNAME_OF_TEXT fontSize:textFontSize];
        labelTitle.color = ccWHITE;
        labelTitle.anchorPoint = ccp(0.5, 0.5);
        labelTitle.position = ccp(winSize.width / 2, posY);
        [self addChild:labelTitle];
        
        CCSprite *trophySprite = [CCSprite spriteWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"Trophy.png"]];
        [self addChild:trophySprite];
        trophySprite.position = ccp(winSize.width / 2, winSize.height - deltaY);
        
        _navBar = [[[GPNavBar alloc] initWithSceneType:GPSceneTypeLevelLayer] autorelease];
        [self addChild:_navBar z:ZORDER_NAV_BAR];
        
        
    }
    return self;
}

//- (void)registerWithTouchDispatcher {
//    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
//}

//- (void)closeWordBorad {
//    
//    [GPNavBar playBtnPressedEffect];
//    
//    [self removeFromParentAndCleanup:YES];
//    
//}
//
//+ (CGPoint) locationFromTouch:(UITouch*)touch
//{
//	CGPoint touchLocation = [touch locationInView: [touch view]];
//	return [[CCDirector sharedDirector] convertToGL:touchLocation];
//}
//
//- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
////    CGPoint point = [TrophyLayer locationFromTouch:touch];
//    BOOL isTouchHandled = YES;
//    
//    return isTouchHandled;
//}

@end
