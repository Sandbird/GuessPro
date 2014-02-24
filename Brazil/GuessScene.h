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

//+ (CCScene *)scene;
+ (CCScene *)sceneWithPuzzleNum:(int)puzzleNum;

+ (GuessScene *)sharedGuessScene;

//- (void)startPuzzleWithLevelNum:(int)levelNum;

- (void)playBounsAnimation;

- (void)changeToNextPuzzle;

@end
