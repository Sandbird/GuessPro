//
//  GPNavBar.h
//  Brazil
//
//  Created by zhaozilong on 13-10-31.
//
//

//#import "CCLayer.h"
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

#import "ShareBorad.h"

// 是否模拟器
#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

#define ACTION_UP_SCORE_TAG 999

typedef enum {
    GPSceneTypeStartLayer,//从选关界面进入的Guess界面
    GPSceneTypeContinueLayer,//从开始按钮进入的Guess界面
    GPSceneTypeLevelLayer,
    GPSceneTypeGuessLayer,
    GPSceneTypeNone,
}GPSceneType;

@interface GPNavBar : CCLayer {
   
    //    CCMenuItem *homeItem;
    
    CCNode *worldScene;
    
//    CGFloat fontsize;
    
}

//@property (nonatomic, retain)CCSprite *backgroudSprite;

@property BOOL isEnglish;

//- (id)initWithIsFromPlaying:(BOOL)isPlaying;

- (id)initWithSceneType:(GPSceneType)sceneType;

- (int)scores;

- (void)setTipsLabelStr:(NSString *)str;

- (void)stopAnimationAndRefreshScore;

//- (void)setTotalLabelScore:(int)score;
- (void)refreshTotalScore;
- (void)changeTotalScore:(int)changeScore;

- (void)playScoreAnimationWithExtraScore:(int)extraScore;
- (void)playScoreAnimationNoPlusExtraScore:(int)extraScore;

- (void)savePlayerStatusTotalScore;

+ (BOOL)isiPad;

+ (BOOL)isiPhone5;

+ (BOOL)isRetina;

+ (void)playGoEffect;

+ (void)playBackEffect;

+ (CGPoint) locationFromTouch:(UITouch*)touch;

+ (NSInteger)continueLevel;
+ (BOOL)isNeedRestoreScene;
+ (void)setContinueLevel:(NSInteger)levelNum isNeedRestoreScene:(BOOL)isNeed;

- (void)showStoreLayer;
- (void)showShareBoradWithType:(ShareBoradShareType)SBSType;

+ (BOOL)isTodayFirstTimeComeIn;

+ (void)setTimesByUsingSOS:(NSInteger)times;
+ (void)setTimesByUsingShare:(NSInteger)times;
+ (BOOL)isTodayCanAddCoinWithSOS;
+ (BOOL)isTodayCanAddCoinWithShare;

+ (NSInteger)numOfCoinAdded;
+ (void)setNumOfCoinAdded:(NSInteger)num;

+ (BOOL)isThisVersionFirstTimeRun;
+ (void)setIsNeedRate:(BOOL)isRate;
+ (BOOL)isNeedRate;

@end
