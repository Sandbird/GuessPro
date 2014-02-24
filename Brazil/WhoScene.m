//
//  WhoScene.m
//  Brazil
//
//  Created by 赵子龙 on 13-11-6.
//
//

#import "WhoScene.h"

@interface WhoScene() {
//    CCSprite *Cloud0;
    CCSprite *startSprite;
    CCSprite *_hajimaruSprite;
    
    CGPoint _currentTouchPoint;
    
    CGSize _screenSize;
}

@end

@implementation WhoScene

- (void)dealloc {
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"Who.plist"];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [super dealloc];
}

+ (CCScene *)scene {
    
    CCScene *scene = [CCScene node];
    
    WhoScene *layer = [WhoScene node];
    
    [scene addChild:layer];
    
    return scene;
}

- (id)init {
    
    if (self = [super init]) {
        //touch event
        //        isTouchEnabled_ = YES;
        
        //screen size
        _screenSize = [[CCDirector sharedDirector] winSize];
        
        //add texture to momery
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"Who.plist"];
        
        CCLayerColor *whiteBack = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:whiteBack];
        
        //Cloud1
        CCSpriteFrame *frame = [frameCache spriteFrameByName:@"Cloud0.png"];
        CCSprite *Cloud0 = [CCSprite spriteWithSpriteFrame:frame];
        Cloud0.anchorPoint = ccp(0, 1);
        Cloud0.position = ccp(0, _screenSize.height);
        [self addChild:Cloud0];
        Cloud0.scale = 0;
        CCScaleTo *scaleCloud = [CCScaleTo actionWithDuration:0.4 scale:1.0];
        [Cloud0 runAction:scaleCloud];
        
        //Cloud2
        frame = [frameCache spriteFrameByName:@"Cloud1.png"];
        CCSprite *Cloud1 = [CCSprite spriteWithSpriteFrame:frame];
        Cloud1.anchorPoint = ccp(1, 0);
        Cloud1.position = ccp(_screenSize.width, 60);
        [self addChild:Cloud1];
        Cloud1.scale = 0;
        CCScaleTo *scaleCloud1 = [CCScaleTo actionWithDuration:0.7 scale:1.0];
        [Cloud1 runAction:scaleCloud1];
        
        
        
        //Start button
        frame = [frameCache spriteFrameByName:@"who0.png"];
        CCSprite *who0Sprite = [CCSprite spriteWithSpriteFrame:frame];
        who0Sprite.anchorPoint = ccp(0.5, 0.5);
        who0Sprite.position = ccp(_screenSize.width / 2, 750);
        [self addChild:who0Sprite];
        who0Sprite.scale = 0;
        //变大
        CCScaleTo *scale0 = [CCScaleTo actionWithDuration:0.5 scale:1.0];
        CCDelayTime *delay0 = [CCDelayTime actionWithDuration:0.3];
        CCRotateBy *rotate00 = [CCRotateBy actionWithDuration:0.5 angle:-10];
        CCRotateBy *rotate01 = [CCRotateBy actionWithDuration:0.5 angle:20];
        CCRotateBy *rotate02 = [CCRotateBy actionWithDuration:0.5 angle:-10];
        CCSequence *seq0 = [CCSequence actions:delay0, scale0, rotate00, rotate01, rotate02, nil];
        [who0Sprite runAction:seq0];
        
        //Start button
        frame = [frameCache spriteFrameByName:@"who1.png"];
        CCSprite *who1Sprite = [CCSprite spriteWithSpriteFrame:frame];
        who1Sprite.anchorPoint = ccp(0.5, 0.5);
        who1Sprite.position = ccp(_screenSize.width / 2, 550);
        [self addChild:who1Sprite];
        who1Sprite.scale = 0;
        //变大
        CCScaleTo *scale1 = [CCScaleTo actionWithDuration:1.0 scale:1.0];
        CCDelayTime *delay1 = [CCDelayTime actionWithDuration:0];
        CCRotateBy *rotate10 = [CCRotateBy actionWithDuration:1.5 angle:360];
//        CCRotateBy *rotate11 = [CCRotateBy actionWithDuration:0.5 angle:20];
//        CCRotateBy *rotate12 = [CCRotateBy actionWithDuration:0.5 angle:-10];
        CCSpawn *spwan = [CCSpawn actionOne:scale1 two:rotate10];
        CCSequence *seq1 = [CCSequence actions:delay1, spwan/*, rotate11, rotate12*/, nil];
        [who1Sprite runAction:seq1];
        
        //Start button
        frame = [frameCache spriteFrameByName:@"who2.png"];
        CCSprite *who2Sprite = [CCSprite spriteWithSpriteFrame:frame];
        who2Sprite.anchorPoint = ccp(0.5, 0.5);
        who2Sprite.position = ccp(_screenSize.width / 2, 350);
        [self addChild:who2Sprite];
        who2Sprite.scale = 0;
        //变大
        CCScaleTo *scale2 = [CCScaleTo actionWithDuration:0.7 scale:1.0];
        CCDelayTime *delay2 = [CCDelayTime actionWithDuration:0.5];
        CCRotateBy *rotate20 = [CCRotateBy actionWithDuration:0.5 angle:-15];
        CCRotateBy *rotate21 = [CCRotateBy actionWithDuration:0.5 angle:30];
        CCRotateBy *rotate22 = [CCRotateBy actionWithDuration:0.5 angle:-15];
        CCSequence *seq2 = [CCSequence actions:delay2, scale2, rotate20, rotate21, rotate22, nil];
        [who2Sprite runAction:seq2];
        
        
        //加NavBar
        ZZNavBar *navBar = [ZZNavBar node];
        [self addChild:navBar];
        [navBar setKayacSceneTag:KayacSceneWhoTag];
        
    }
    
    return self;
}

- (void)onExitTransitionDidStart {
   
}

@end
