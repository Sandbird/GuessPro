//
//  GuessScene.h
//  Brazil
//
//  Created by zhaozilong on 13-10-26.
//
//

#import "CCLayer.h"
#import "GPNavBar.h"
#import <ShareSDK/ShareSDK.h>

@interface GuessScene : CCLayer <UIAlertViewDelegate> {
    CGPoint _defaultPosition;
	CGPoint _lastTouchLocation;
    
    BOOL _isTouchHandled;
}

//+ (CCScene *)scene;
+ (CCScene *)sceneWithPuzzleNum:(int)puzzleNum;

+ (GuessScene *)sharedGuessScene;

- (void)saveScene;

//- (void)startPuzzleWithLevelNum:(int)levelNum;

- (void)playBounsAnimation;

- (void)changeToNextPuzzle;

@end
