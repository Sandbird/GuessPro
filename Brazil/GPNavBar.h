//
//  GPNavBar.h
//  Brazil
//
//  Created by zhaozilong on 13-10-31.
//
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

// 是否模拟器
#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

#define ACTION_UP_SCORE_TAG 999

@interface GPNavBar : CCLayer {
   
    //    CCMenuItem *homeItem;
    
    CCNode *worldScene;
    
    CGFloat fontsize;
}

@property BOOL isEnglish;

- (id)initWithIsFromPlaying:(BOOL)isPlaying;

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

- (NSInteger)continueLevel;
- (BOOL)isNeedRestoreScene;
- (void)setContinueLevel:(NSInteger)levelNum isNeedRestoreScene:(BOOL)isNeed;

@end
