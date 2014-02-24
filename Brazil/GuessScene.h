//
//  GuessScene.h
//  Brazil
//
//  Created by zhaozilong on 13-10-26.
//
//

#import "CCLayer.h"
#import "GPNavBar.h"

@interface GuessScene : CCLayer {
    CGPoint _defaultPosition;
	CGPoint _lastTouchLocation;
    
    BOOL _isTouchHandled;
}

+ (CCScene *)scene;

+ (GuessScene *)sharedGuessScene;

- (void)playBounsAnimation;

- (void)changeToNextPuzzle;

@end
