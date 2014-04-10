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
            wordSize = CGSizeMake(600, 800);
            deltaY = 200;
            textFontSize = 30;
        } else if ([GPNavBar isiPhone5]) {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(280, 400);
            deltaY = 120;
            textFontSize = 20;
        } else {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(250, 350);
            deltaY = 80;
            textFontSize = 20;
        }
        
        NSString *title = @"应用信息";
        
        CCLabelTTF *labelTitle = [CCLabelTTF labelWithString:title fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TITLE];
        labelTitle.color = ccWHITE;
        labelTitle.anchorPoint = ccp(0.5, 0.5);
        labelTitle.position = ccp(winSize.width / 2, posY);
        [self addChild:labelTitle];
        
        NSString *words = [NSString stringWithFormat:@"本游戏中的电影名称依照中国大陆翻译版本为准。\n\n开发、美术、音效、数据：赵子龙\n\n版本：%@", [GPNavBar applicationVersion]];
        
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
