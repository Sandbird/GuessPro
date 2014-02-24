//
//  StartLayer.m
//  Brazil
//
//  Created by 赵子龙 on 13-11-5.
//
//

#import "StartLayer.h"
//#import "EggsScene.h"
#import "GuessScene.h"
#import "MapScene.h"

@interface StartLayer() {
    CCSprite *_logoSprite;
    CCSprite *_startSprite;
    CCSprite *_hajimaruSprite;
    
    CGPoint _currentTouchPoint;
    
    CGSize _screenSize;

}
@end

@implementation StartLayer

- (void)dealloc {
    
    [super dealloc];
}

+ (CCScene *)scene {
    
    CCScene *scene = [CCScene node];
    
    StartLayer *layer = [StartLayer node];
    
    [scene addChild:layer];
    
    return scene;
}

- (id)init {
    
    if (self = [super init]) {
        //touch event
        isTouchEnabled_ = YES;
        
        //screen size
        _screenSize = [[CCDirector sharedDirector] winSize];
        
        //add texture to momery
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"StartPage.plist"];
        
        CCLayerColor *whiteBack = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:whiteBack];
        
        //Logo
        CCSpriteFrame *frame = [frameCache spriteFrameByName:@"KayacLogo.png"];
        _logoSprite = [CCSprite spriteWithSpriteFrame:frame];
        _logoSprite.position = ccp(_screenSize.width / 2, _screenSize.height / 2);
        CGPoint pointLogo = _logoSprite.position;
        [self addChild:_logoSprite];
        
        //上移
        CCDelayTime *delayMove = [CCDelayTime actionWithDuration:1.0];
        CCMoveTo *moveToUp = [CCMoveTo actionWithDuration:0.5 position:ccp(pointLogo.x, pointLogo.y + 250)];
        CCSequence *seqMove = [CCSequence actionOne:delayMove two:moveToUp];
        [_logoSprite runAction:seqMove];
        
        //Start button
        frame = [frameCache spriteFrameByName:@"StartButton.png"];
        _startSprite = [CCSprite spriteWithSpriteFrame:frame];
        _startSprite.anchorPoint = ccp(0.5, 0.5);
        _startSprite.position = ccp(_screenSize.width / 2, 0);
        CGPoint pointStart = ccp(_screenSize.width / 2, _startSprite.boundingBox.size.height / 2);
        [self addChild:_startSprite];
        _startSprite.scale = 0;
        
        //又小变大，移动
        CCScaleTo *scaleTo = [CCScaleTo actionWithDuration:1.0 scale:1.0];
        CCMoveTo *moveTo = [CCMoveTo actionWithDuration:0.7 position:ccp(_screenSize.width / 2, pointStart.y + 150)];
        CCSpawn *spawn = [CCSpawn actionOne:scaleTo two:moveTo];
        
        CCDelayTime *delayStart = [CCDelayTime actionWithDuration:1.0];
        
        //变大变小
        CCScaleTo *big = [CCScaleTo actionWithDuration:0.1 scale:1.1];
        CCScaleTo *small = [CCScaleTo actionWithDuration:0.1 scale:1];
        CCDelayTime *time = [CCDelayTime actionWithDuration:1.2];
        CCSequence *bigSmall = [CCSequence actions:big, small, time, nil];
        CCRepeat *repeat = [CCRepeat actionWithAction:bigSmall times:50];
        
        //开始执行动作
        CCSequence *seqStart = [CCSequence actions:delayStart, spawn, repeat, nil];
        [_startSprite runAction:seqStart];
        
        
        //settings button
        frame = [frameCache spriteFrameByName:@"Hajimaru1.png"];
        _hajimaruSprite = [CCSprite spriteWithSpriteFrame:frame];
        _hajimaruSprite.anchorPoint = ccp(1, 0.5);
        _hajimaruSprite.position = ccp(0, 80);
        [self addChild:_hajimaruSprite];
        _hajimaruSprite.visible = NO;
        
        CCDelayTime *delayHajimaru = [CCDelayTime actionWithDuration:1.0];
        CCMoveTo *moveToCenter = [CCMoveTo actionWithDuration:0.9 position:ccp((_screenSize.width + _hajimaruSprite.boundingBox.size.width) / 2, 80)];
        CCShow *show = [CCShow action];
        CCSpawn *hajimaruSpwan = [CCSpawn actionOne:moveToCenter two:show];
        CCSequence *seqHajimaru = [CCSequence actionOne:delayHajimaru two:hajimaruSpwan];
        [_hajimaruSprite runAction:seqHajimaru];
        
        
    }
    
    return self;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}


+(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    _currentTouchPoint = [StartLayer locationFromTouch:touch];
    
    isTouchEnabled_ = CGRectContainsPoint(_startSprite.boundingBox, _currentTouchPoint);
    
    if (isTouchEnabled_) {
        
    }
    
    return isTouchEnabled_;
    
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint endPoint = [StartLayer locationFromTouch:touch];
    
    if (CGRectContainsPoint(_startSprite.boundingBox, _currentTouchPoint)){
          _startSprite.scale = 1.0;
          
          if (CGRectContainsPoint(_startSprite.boundingBox, endPoint)) {
              [self transToNext];
          }
      }
    
}

- (void)transToNext {
    
    //跳转
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5 scene:[GuessScene scene]]];
    
    [[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFade transitionWithDuration:0.5f scene:[MapScene scene]]];
}

- (void)onExit {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}


@end
