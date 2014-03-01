//
//  SuccessLayer.m
//  Brazil
//
//  Created by zhaozilong on 13-11-2.
//
//

#import "SuccessLayer.h"
#import "GuessScene.h"
#import "UIImage+MostColor.h"
#import "ZZAcquirePath.h"

@interface SuccessLayer() {

    CCSprite *_nextSprite;
    
    BOOL _isBeginTouched;
    
    CCLayerColor *_successColor;
    
    CCLabelTTF *_posLabel;
}

@end

@implementation SuccessLayer

- (void)dealloc {
    NSLog(@"Success release");
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        _isBeginTouched = NO;
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //touch is enabled
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-255 swallowsTouches:YES];
        
        _nextSprite = [CCSprite spriteWithSpriteFrameName:@"nextButton.png"];
        _nextSprite.anchorPoint = ccp(0.5, 0.5);
        _nextSprite.position = ccp(size.width / 2, 150);
        [self addChild:_nextSprite z:ZORDER_SUCCESS_LAYER + 1];
        
        CGSize fontSize = CGSizeMake(768, 80);
        _posLabel = [CCLabelTTF labelWithString:@"" dimensions:fontSize alignment:NSTextAlignmentCenter fontName:@"HiraKakuProN-W6" fontSize:50];
        _posLabel.color = ccBLACK;
        _posLabel.anchorPoint = ccp(0.5, 0.5);
        _posLabel.position = ccp(size.width / 2, 240);
        [self addChild:_posLabel z:ZORDER_SUCCESS_LAYER + 3];
        
        
//        _successColor = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
//        [self addChild:_successColor z:ZORDER_SUCCESS_LAYER];
        
        //加NavBar
//        ZZNavBar *navBar = [ZZNavBar node];
//        [self addChild:navBar z:5];
//        [navBar setKayacSceneTag:KayacSceneGuessProTag];
    }
    return self;
}

- (void)setPositionLabel:(NSString *)posString {
    [_posLabel setString:posString];
}

- (void)setSuccessLayerColorWithImgName:(NSString *)imgName {
    
    NSString *path = [ZZAcquirePath getBundleDirectoryWithFileName:imgName];
    //计算图片颜色
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    ccColor4B color = [img mostColor];
    [img release];
    
//    [_successColor setColor:color];
    
    CCLayerColor *successColor = [CCLayerColor layerWithColor:color];
    [self addChild:successColor z:ZORDER_SUCCESS_LAYER];
}


+(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    _lastTouchLocation = [SuccessLayer locationFromTouch:touch];
    
    _isTouchHandled = YES;
    
    
    if (_isTouchHandled) {
        if (CGRectContainsPoint([_nextSprite boundingBox], _lastTouchLocation)) {
            [_nextSprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.1]];
            _isBeginTouched = YES;
        }
    }
    
    return _isTouchHandled;
    
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [SuccessLayer locationFromTouch:touch];
    
    if (_isTouchHandled && _isBeginTouched) {
        
        if (CGRectContainsPoint(_nextSprite.boundingBox, touchLocation)) {
            [_nextSprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.1]];
        } else {
            [_nextSprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        }
        
        
//        [[GuessScene sharedGuessScene] playBounsAnimation];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [SuccessLayer locationFromTouch:touch];
    
    if (CGRectContainsPoint(_nextSprite.boundingBox, touchLocation) && _isBeginTouched) {
        [_nextSprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        [[GuessScene sharedGuessScene] changeToNextPuzzle];
    }
    
    _isBeginTouched = NO;
}
- (void)onExitTransitionDidStart {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}



@end
