//
//  GuessScene.h
//  Brazil
//
//  Created by zhaozilong on 13-10-26.
//
//

#import "CCLayer.h"
#import "GPNavBar.h"
#import "RootViewController.h"

#import "GADBannerView.h"

@interface GuessScene : CCLayer <UIAlertViewDelegate, GADBannerViewDelegate> {
    CGPoint _defaultPosition;
	CGPoint _lastTouchLocation;
    
    BOOL _isTouchHandled;
}

@property (nonatomic, assign)GPNavBar *navBar;

@property (nonatomic, retain) RootViewController *controller;

//+ (CCScene *)scene;
+ (CCScene *)sceneWithPuzzleNum:(int)levelNum GPSceneType:(GPSceneType)type;

+ (GuessScene *)sharedGuessScene;

- (void)saveScene;

//- (void)startPuzzleWithLevelNum:(int)levelNum;

- (void)playBounsAnimation;

- (void)changeToNextPuzzle;

- (void)checkWinOrLose;


//返回下一个将要执行的问题序号
- (NSInteger)nextPuzzleIndex;

@end
