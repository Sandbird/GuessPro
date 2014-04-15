//
//  MoreLayer.m
//  GuessProMovie
//
//  Created by zhaozilong on 14-4-7.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "MoreLayer.h"


@interface MoreLayer () {
    CCMenu *_menu;
}

@end


@implementation MoreLayer

- (void)dealloc {
    
    
    CCLOG(@"MoreLayer is dealloc");
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        self.isTouchEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
        [self addChild:color];
        
        CGFloat posY;
        CGSize wordSize;
        CGFloat deltaY;
        CGFloat textFontSize;
        if ([GPNavBar isiPad]) {
            posY = winSize.height - 88.0f;
            wordSize = CGSizeMake(700, 800);
            deltaY = 200;
            textFontSize = 35;
        } else if ([GPNavBar isiPhone5]) {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(280, 350);
            deltaY = 140;
            textFontSize = 15;
        } else {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(280, 350);
            deltaY = 120;
            textFontSize = 15;
        }
        
        NSString *title = NSLocalizedString(@"TITLE_MORE_INFO", @"更多信息");
        
        CCLabelTTF *labelTitle = [CCLabelTTF labelWithString:title fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TITLE];
        labelTitle.color = ccWHITE;
        labelTitle.anchorPoint = ccp(0.5, 0.5);
        labelTitle.position = ccp(winSize.width / 2, posY);
        [self addChild:labelTitle];
        
        NSString *intro0 = NSLocalizedString(@"INTRO_0", @"● 游戏中的电影名以大陆翻译版本为准");
        NSString *intro1 = NSLocalizedString(@"INTRO_1", @"● VOCEE GAMES 为你开发幸福游戏");
        NSString *intro2 = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"INTRO_2", @"● 游戏版本："), [GPNavBar applicationVersion]];
        
        
        NSString *words = [NSString stringWithFormat:@"%@\n\n\n%@\n\n\n%@", intro0, intro1, intro2];
        
        CCLabelTTF *labelWords = [CCLabelTTF labelWithString:words dimensions:wordSize alignment:NSTextAlignmentLeft vertAlignment:CCVerticalAlignmentTop lineBreakMode:NSLineBreakByCharWrapping fontName:FONTNAME_OF_TEXT fontSize:textFontSize];
        labelWords.color = ccWHITE;
        labelWords.anchorPoint = ccp(0.5, 1);
        labelWords.position = ccp(winSize.width / 2,  posY - labelTitle.boundingBox.size.height - deltaY);
        [self addChild:labelWords];
        
        
        //Close Item
        CCSprite *closeSprite = [CCSprite spriteWithSpriteFrameName:@"close.png"];
        CCSprite *closeHLSprite = [CCSprite spriteWithSpriteFrameName:@"close_HL.png"];
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
    
    [GPNavBar playBtnPressedEffect];
    
    [self removeFromParentAndCleanup:YES];
    
}

+ (CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [MoreLayer locationFromTouch:touch];
    BOOL isTouchHandled = YES;
    for (CCMenuItem *item in _menu.children) {
        if (CGRectContainsPoint(item.boundingBox, point)) {
            isTouchHandled = NO;
        }
    }
    
    return isTouchHandled;
}

@end
