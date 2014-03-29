//
//  WordBorad.m
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-13.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "WordBorad.h"

@interface WordBorad () {
    CCMenu *_menu;
}

@end


@implementation WordBorad

- (void)dealloc {
    
    
    CCLOG(@"WordBorad is dealloc");
    
    [super dealloc];
}

+ (WordBorad *)nodeWithWords:(NSString *)words wordBoradType:(WordBoradType)WBType {
    return [[[self alloc] initWithInformation:words wordBoradType:WBType] autorelease];
}

- (id)initWithInformation:(NSString *)words wordBoradType:(WordBoradType)WBType {
    self = [super init];
    if (self) {
        
        self.isTouchEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
        [self addChild:color];
        
        CGFloat posY;
        CGSize wordSize;
        if ([GPNavBar isiPad]) {
            posY = winSize.height - 76.0f;
            wordSize = CGSizeMake(600, 800);
        } else if ([GPNavBar isiPhone5]) {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(250, 400);
        } else {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(250, 350);
        }
        
        NSString *title = nil;
        NSTextAlignment TA;
        CCVerticalAlignment VA;
        if (WBType == WordBoradTypeTips) {
            title = @"提示";
            TA = NSTextAlignmentCenter;
            VA = CCVerticalAlignmentTop;
        } else if (WBType == WordBoradTypeAnswer) {
            title = @"答案";
            TA = NSTextAlignmentCenter;
            VA = CCVerticalAlignmentCenter;
        } else {
            title = @"道具";
            TA = NSTextAlignmentNatural;
            VA = CCVerticalAlignmentTop;
        }
        
        CCLabelTTF *labelTitle = [CCLabelTTF labelWithString:title fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TITLE];
        labelTitle.color = ccWHITE;
        labelTitle.anchorPoint = ccp(0.5, 0.5);
        labelTitle.position = ccp(winSize.width / 2, posY);
        [self addChild:labelTitle];
        
        CCLabelTTF *labelWords = [CCLabelTTF labelWithString:words dimensions:wordSize alignment:TA vertAlignment:VA lineBreakMode:NSLineBreakByCharWrapping fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TEXT];
        labelWords.color = ccWHITE;
        labelWords.anchorPoint = ccp(0.5, 1);
        labelWords.position = ccp(winSize.width / 2,  posY - labelTitle.boundingBox.size.height);
        [self addChild:labelWords];
        
        
        //Close Item
        CCSprite *closeSprite = [CCSprite spriteWithSpriteFrameName:@"close.png"];
        CCSprite *closeHLSprite = [CCSprite spriteWithSpriteFrameName:@"close_HL.png"];
        CCMenuItem *closeItem = [CCMenuItemImage itemFromNormalSprite:closeSprite selectedSprite:closeHLSprite target:self selector:@selector(closeWordBorad)];
        closeItem.anchorPoint = ccp(0.5, 0.5);
        closeItem.position = ccp(winSize.width / 2, 50);
        
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
    
//    CCScaleTo *scaleToSmall = [CCScaleTo actionWithDuration:0.2 scale:0];
//    CCSequence *bigToSmall = [CCSequence actions:scaleToSmall, nil];
//    
//    CCCallBlock *cleanUp = [CCCallBlock actionWithBlock:^{
//        [self removeFromParentAndCleanup:YES];
//    }];
//    
//    CCSequence *seq = [CCSequence actionOne:bigToSmall two:cleanUp];
//    
//    [self runAction:seq];
    
    [GPNavBar playBtnPressedEffect];
    
    [self removeFromParentAndCleanup:YES];
    
}

+ (CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [WordBorad locationFromTouch:touch];
    BOOL isTouchHandled = YES;
    for (CCMenuItem *item in _menu.children) {
        if (CGRectContainsPoint(item.boundingBox, point)) {
            isTouchHandled = NO;
        }
    }
    
    return isTouchHandled;
}

@end
