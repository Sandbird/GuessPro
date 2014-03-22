//
//  GuessScene.h
//  Brazil
//
//  Created by zhaozilong on 13-10-26.
//
//

#import "CCLayer.h"
#import "GPNavBar.h"

@interface GuessScene : CCLayer <UIAlertViewDelegate> {
    CGPoint _defaultPosition;
	CGPoint _lastTouchLocation;
    
    BOOL _isTouchHandled;
}

@property (nonatomic, assign)GPNavBar *navBar;

//+ (CCScene *)scene;
+ (CCScene *)sceneWithPuzzleNum:(int)levelNum GPSceneType:(GPSceneType)type;

+ (GuessScene *)sharedGuessScene;

- (void)saveScene;

//- (void)startPuzzleWithLevelNum:(int)levelNum;

- (void)playBounsAnimation;

- (void)changeToNextPuzzle;

- (void)checkWinOrLose;

@end
