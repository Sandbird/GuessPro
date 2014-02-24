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

#define LOCALIZED_NAME @"localized"
#define LOCALIZED_ENGLISH @"en"
#define LOCALIZED_CHINESE @"cn"
#define LOCALIZED_JAPANESE @"jp"

#define ACTION_UP_SCORE_TAG 999

@interface GPNavBar : CCLayer {
   
    //    CCMenuItem *homeItem;
    
    CCNode *worldScene;
    
    CGFloat fontsize;
}

@property BOOL isEnglish;

- (void)setTipsLabelStr:(NSString *)str;

- (void)stopAnimationAndSetScore:(int)totalScore;

- (void)setTotalLabelScore:(int)score;

- (void)playScoreAnimationWithExtraScore:(int)extraScore totalScore:(int)score;

//- (void)transToMainScene;
//
//- (void)transToOtherLanguage;

//- (void)stopActionWithScene:(CCNode *)scene;

//- (void)playSoundByNameEn:(NSString *)soundEn Cn:(NSString *)soundCn Jp:(NSString *)soundJp;

+ (BOOL)isiPad;

+ (BOOL)isiPhone5;

//+ (BOOL)isiPhoneNormalScreen;

+ (BOOL)isRetina;

//+ (BOOL)isiPhone4Retina;

+ (void)playGoEffect;

+ (void)playBackEffect;

//+ (int)getLocalizedLanguage;

//+ (int)getLocalizedLanguageByStr:(NSString *)language;

//+ (int)getNumberEnCnJp;

//+ (NSString *)getStringEnCnJp;

+(CGPoint) locationFromTouch:(UITouch*)touch;

@end
