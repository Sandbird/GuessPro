//
//  InformationBorad.m
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-12.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "InformationBorad.h"

@interface InformationBorad () {
    CCMenu *_menu;
}

@property (nonatomic, retain)UITextView *infoTextView;

@end


@implementation InformationBorad

- (void)dealloc {
    
    
    CCLOG(@"information is dealloc");
    
    [_infoTextView removeFromSuperview];
    _infoTextView = nil;
    
    [super dealloc];
}

+ (InformationBorad *)nodeWithInformation:(NSString *)info parentView:(UIView *)parentView {
    return [[[self alloc] initWithInformation:info parentView:parentView] autorelease];
}

- (id)initWithInformation:(NSString *)info parentView:(UIView *)parentView {
    self = [super init];
    if (self) {
        
        self.isTouchEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
        [self addChild:color];
        
        CGFloat posY;
        CGSize wordSize;
        CGFloat fontSize;
        if ([GPNavBar isiPad]) {
            posY = winSize.height - 88.0f;
            wordSize = CGSizeMake(600, 200);
            fontSize = 37;
        } else if ([GPNavBar isiPhone5]) {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(250, 100);
            fontSize = 18;
        } else {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(250, 100);
            fontSize = 18;
        }
        
        NSString *title = NSLocalizedString(@"TITLE_BACK_OF_PIC", @"花絮");
        
        CCLabelTTF *labelTitle = [CCLabelTTF labelWithString:title fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TITLE];
        labelTitle.color = ccWHITE;
        labelTitle.anchorPoint = ccp(0.5, 0.5);
        labelTitle.position = ccp(winSize.width / 2, posY);
        [self addChild:labelTitle];
        
        CGRect infoFrame;
        if ([GPNavBar isiPad]) {
            infoFrame = CGRectMake(0, 130, winSize.width, 720);
        } else if ([GPNavBar isiPhone5]) {
            infoFrame = CGRectMake(0, 60, winSize.width, 420);
        } else {
            infoFrame = CGRectMake(0, 60, winSize.width, 330);
        }
        
        _infoTextView = [[UITextView alloc] initWithFrame:infoFrame];
        [parentView addSubview:_infoTextView];
        [_infoTextView release];
        
        [_infoTextView setBackgroundColor:[UIColor clearColor]];
        [_infoTextView setEditable:NO];
        [_infoTextView setSelectable:NO];
        [_infoTextView setShowsVerticalScrollIndicator:NO];
        
        [_infoTextView setText:info];
        [_infoTextView setTextColor:[UIColor whiteColor]];
//        [_infoTextView setTextAlignment:NSTextAlignmentCenter];
        [_infoTextView setFont:[UIFont fontWithName:@"Heiti TC" size:FONTSIZE_OF_BORAD_TEXT]];
        
        
        //Close Item
        CCSprite *closeSprite = [CCSprite spriteWithSpriteFrameName:@"close.png"];
        CCSprite *closeHLSprite = [CCSprite spriteWithSpriteFrameName:@"close_HL.png"];
        CCMenuItem *closeItem = [CCMenuItemImage itemFromNormalSprite:closeSprite selectedSprite:closeHLSprite target:self selector:@selector(closeInformation)];
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

- (void)closeInformation {
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
    CGPoint point = [InformationBorad locationFromTouch:touch];
    BOOL isTouchHandled = YES;
    for (CCMenuItem *item in _menu.children) {
        if (CGRectContainsPoint(item.boundingBox, point)) {
            isTouchHandled = NO;
        }
    }
    
    return isTouchHandled;
}

@end
