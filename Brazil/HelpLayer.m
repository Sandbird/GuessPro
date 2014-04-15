//
//  HelpLayer.m
//  GuessProMovie
//
//  Created by zhaozilong on 14-4-14.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "HelpLayer.h"
#import "GuessScene.h"

@interface HelpLayer() {
    CCMenu *_menu;
    
    HelpType _helpType;
}

@end


@implementation HelpLayer

- (void)dealloc {
    
    
    CCLOG(@"HelpLayer is dealloc");
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"Help.png"];
    
    [super dealloc];
}

- (id)initWithHelpType:(HelpType)type {
    self = [super init];
    if (self) {
        
        self.isTouchEnabled = YES;
        
        _helpType = type;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        NSString *name = nil;
        
        if (_helpType == HelpTypeItemIntro) {
            name =[AssetHelper getDeviceSpecificFileNameFor:@"Help.png"];
        } else if (_helpType == HelpTypeBounsIntro) {
            name =[AssetHelper getDeviceSpecificFileNameFor:@"HelpWin.png"];
        }
        
        CCTexture2D *helpTexture = [[CCTextureCache sharedTextureCache] addImage:name];

        CCSprite *helpBack = [CCSprite spriteWithTexture:helpTexture];
        [self addChild:helpBack];
        
        helpBack.position = ccp(winSize.width / 2, winSize.height / 2);
        
        
        //Close Item
        CCSprite *closeSprite = [CCSprite spriteWithSpriteFrameName:@"KnowButton.png"];
        CCSprite *closeHLSprite = [CCSprite spriteWithSpriteFrameName:@"KnowButton_HL.png"];
        CCMenuItem *closeItem = [CCMenuItemImage itemFromNormalSprite:closeSprite selectedSprite:closeHLSprite target:self selector:@selector(closeWordBorad)];
        closeItem.anchorPoint = ccp(0.5, 0.5);
        closeItem.position = ccp(winSize.width / 2, HEIGHT_OF_CLOSE_ITEM);
        
        _menu = [CCMenu menuWithItems:closeItem, nil];
        _menu.position = ccp(0, 0);
        [self addChild:_menu];
    }
    return self;
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
}

- (void)closeWordBorad {
    
    if (_helpType == HelpTypeBounsIntro) {
        [[GuessScene sharedGuessScene] alreadyWin];
        
        [GPNavBar setIsShowHelpBouns:NO];
    } else if (_helpType == HelpTypeItemIntro) {
        [GPNavBar setIsShowHelpItem:NO];
    }
    
    //关闭
    [GPNavBar playBtnPressedEffect];
    
    [self removeFromParentAndCleanup:YES];
    
}

+ (CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [HelpLayer locationFromTouch:touch];
    BOOL isTouchHandled = YES;
    for (CCMenuItem *item in _menu.children) {
        if (CGRectContainsPoint(item.boundingBox, point)) {
            isTouchHandled = NO;
        }
    }
    
    return isTouchHandled;
}

@end
