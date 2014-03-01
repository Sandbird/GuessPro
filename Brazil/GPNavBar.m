//
//  GPNavBar.m
//  Brazil
//
//  Created by zhaozilong on 13-10-31.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "GPNavBar.h"
//#import "SmileScene.h"
#import "MapScene.h"
#import "GuessScene.h"

//判断设备是IPHONE还是IPAD
#define IPAD_DEVICE [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define IPHONE5_DEVICE [[UIScreen mainScreen] bounds].size.height == 568.000000

#define EFFECT_GO @"goEffect.caf"
#define EFFECT_BACK @"backEffect.caf"
#define EFFECT_BARK @"bark.caf"

@interface GPNavBar() {
    CCSprite *_backgroudSprite;
    CCLabelTTF *_totalScoreLabel;
    
    CCLabelTTF *_tipsLabel;
    
    CCSprite *_kayacSprite;
}

@property (assign) int totalScore;
@property (assign) BOOL isPlaying;

@end

@implementation GPNavBar

- (void)dealloc {
    
    CCLOG(@"navbar dealloc");
    [super dealloc];
}

- (id)initWithIsFromPlaying:(BOOL)isPlaying {
    
    if (self = [super init]) {
        self.isPlaying = isPlaying;
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"GPNavBar-ipad.plist"];
        CCSpriteFrame *frame;
        
        CGPoint homePoint, helpPoint, titleSpritePoint, titleLabelUpPoint, titleLabelDownPoint;
        if ([GPNavBar isiPad]) {
            fontsize = 44;
            homePoint = ccp(0 + 40, size.height - 23);
            helpPoint = ccp(size.width - 40, size.height - 23);
            titleSpritePoint = ccp(size.width / 2, size.height);
            titleLabelUpPoint = ccp(size.width / 2, size.height - 15);
            titleLabelDownPoint = ccp(size.width / 2, size.height - 70);
        } else {
            fontsize = 22;
            homePoint = ccp(0 + 10, size.height - 15);
            helpPoint = ccp(size.width - 10, size.height - 15);
            titleSpritePoint = ccp(size.width / 2, size.height - 10);
            titleLabelUpPoint = ccp(size.width / 2, size.height - 15);
            titleLabelDownPoint = ccp(size.width / 2, size.height - 40);
        }
        
        frame = [frameCache spriteFrameByName:@"GPNavBar.png"];
        _backgroudSprite = [CCSprite spriteWithSpriteFrame:frame];
        _backgroudSprite.anchorPoint = ccp(0.5, 1);
        _backgroudSprite.position = titleSpritePoint;
        [self addChild:_backgroudSprite];
        
        _kayacSprite = [CCSprite spriteWithSpriteFrameName:@"scoreKayac.png"];
        _kayacSprite.anchorPoint = ccp(0.5, 0.5);
        _kayacSprite.position = ccp(40, 975);
        [self addChild:_kayacSprite];
        
        
        CGSize fontSize = CGSizeMake(200, 80);
        _totalScoreLabel = [CCLabelTTF labelWithString:@"x 0" dimensions:fontSize alignment:NSTextAlignmentLeft fontName:@"MarkerFelt-Thin" fontSize:fontsize];
        _totalScoreLabel.color = ccBLACK;
        _totalScoreLabel.anchorPoint = ccp(0.5, 0.5);
        _totalScoreLabel.position = ccp(190, 960);
        [self addChild:_totalScoreLabel];
        
        if (IS_KAYAC) {
        fontSize = CGSizeMake(400, 80);
        _tipsLabel = [CCLabelTTF labelWithString:@"" dimensions:fontSize alignment:NSTextAlignmentCenter fontName:@"MarkerFelt-Thin" fontSize:fontsize];
        _tipsLabel.color = ccBLACK;
        _tipsLabel.anchorPoint = ccp(0.5, 0.5);
        _tipsLabel.position = ccp(size.width / 2, 960);
        [self addChild:_tipsLabel];
        }
        
        
        CCSprite *pauseSprite = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
        CCSprite *pauseHLSprite = [CCSprite spriteWithSpriteFrameName:@"pause_HL.png"];
        CCMenuItem *pauseItem = [CCMenuItemImage itemFromNormalSprite:pauseSprite selectedSprite:pauseHLSprite];
        
        CCSprite *playSprite = [CCSprite spriteWithSpriteFrameName:@"play.png"];
        CCSprite *playHLSprite = [CCSprite spriteWithSpriteFrameName:@"play_HL.png"];
        CCMenuItem *playItem = [CCMenuItemImage itemFromNormalSprite:playSprite selectedSprite:playHLSprite];
        
        CCMenuItemToggle *playOrPauseToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(popToMenu) items:pauseItem, playItem, nil];
        
        CCMenu *mainMenu = [CCMenu menuWithItems:playOrPauseToggle, nil];
        playOrPauseToggle.anchorPoint = ccp(0.5, 0.5);
        playOrPauseToggle.position = ccp(715, 986);
        mainMenu.position = ccp(0, 0);
        [self addChild:mainMenu];
        
        //显示分数
        self.totalScore = [self loadPlayerStatusTotalScore];
        [self refreshTotalScore];
    }
    
    return self;
    
}

- (void)popToMenu {
    
    if (self.isPlaying) {
        [[GuessScene sharedGuessScene] saveScene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5 scene:[MapScene scene]]];
    } else {
   
    }
    
    
}

- (int)scores {
    return _totalScore;
}

- (void)setTipsLabelStr:(NSString *)str {
    [_tipsLabel setString:str];
}

- (void)refreshTotalScore {
     [_totalScoreLabel setString:[NSString stringWithFormat:@"x %d", self.totalScore]];
}

- (void)changeTotalScore:(int)changeScore {
    self.totalScore += changeScore;
//    [self refreshTotalScore];
    
    //每次变更score的时候都保存
    [self savePlayerStatusTotalScore];
}

- (void)stopAnimationAndRefreshScore {
    [_totalScoreLabel stopActionByTag:ACTION_UP_SCORE_TAG];
    [self refreshTotalScore];
}

- (void)playScoreAnimationNoPlusExtraScore:(int)extraScore {
    
    NSMutableArray *actions = [NSMutableArray array];
    //    NSMutableArray *kayacActions = [NSMutableArray array];
    for (int i = self.totalScore + 1; i <= self.totalScore + extraScore; i++) {
        CCScaleTo *big = [CCScaleTo actionWithDuration:0.02 scale:1.1];
        CCScaleTo *normal = [CCScaleTo actionWithDuration:0.01 scale:1.0];
        CCCallBlock *changeWord = [CCCallBlock actionWithBlock:^{
            [_totalScoreLabel setString:[NSString stringWithFormat:@"x %d", self.totalScore]];
        }];
        CCSequence *seq = [CCSequence actions:changeWord, big, normal, nil];
        [actions addObject:seq];
        
    }
    
    CCSequence *seqs = [CCSequence actionsWithArray:actions];
    CCSequence *seq2 = [CCSequence actionOne:[CCDelayTime actionWithDuration:1.0] two:seqs];
    seq2.tag = ACTION_UP_SCORE_TAG;
    [_totalScoreLabel runAction:seq2];
    
    //    [self changeTotalScore:extraScore];
}

- (void)playScoreAnimationWithExtraScore:(int)extraScore {
    
    NSMutableArray *actions = [NSMutableArray array];
//    NSMutableArray *kayacActions = [NSMutableArray array];
    for (int i = self.totalScore + 1; i <= self.totalScore + extraScore; i++) {
        CCScaleTo *big = [CCScaleTo actionWithDuration:0.02 scale:1.1];
        CCScaleTo *normal = [CCScaleTo actionWithDuration:0.01 scale:1.0];
        CCCallBlock *changeWord = [CCCallBlock actionWithBlock:^{
            [_totalScoreLabel setString:[NSString stringWithFormat:@"x %d", i]];
        }];
        CCSequence *seq = [CCSequence actions:changeWord, big, normal, nil];
        [actions addObject:seq];
        
    }
    
    CCSequence *seqs = [CCSequence actionsWithArray:actions];
    CCSequence *seq2 = [CCSequence actionOne:[CCDelayTime actionWithDuration:1.0] two:seqs];
    seq2.tag = ACTION_UP_SCORE_TAG;
    [_totalScoreLabel runAction:seq2];
    
//    [self changeTotalScore:extraScore];
}

- (void)savePlayerStatusTotalScore {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSNumber numberWithInteger:self.totalScore] forKey:PS_TOTAL_SCORE];
    if (![userDefaults synchronize]) {
        CCLOG(@"error saveGameState");
    }
}

- (NSInteger)loadPlayerStatusTotalScore {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger score = [[userDefaults objectForKey:PS_TOTAL_SCORE] integerValue];
    
    return score;
}

- (NSInteger)continueLevel {
    NSNumber *levelNumber = [[NSUserDefaults standardUserDefaults] objectForKey:PS_CONTINUE_LEVEL];
    if (levelNumber == nil) {
        levelNumber = [NSNumber numberWithInteger:0];
    }
    
    return levelNumber.integerValue;
}

- (BOOL)isNeedRestoreScene {
    NSNumber *isNeed = [[NSUserDefaults standardUserDefaults] objectForKey:PS_IS_NEED_RESTORE_SCENE];
    
    return isNeed.boolValue;
}

- (void)setContinueLevel:(NSInteger)levelNum isNeedRestoreScene:(BOOL)isNeed {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:levelNum] forKey:PS_CONTINUE_LEVEL];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isNeed] forKey:PS_IS_NEED_RESTORE_SCENE];
    if (![[NSUserDefaults standardUserDefaults] synchronize]) {
        CCLOG(@"存储用户进度错误");
    }
}




- (void)transToMainScene {
    
    [GPNavBar playBackEffect];
    [GPNavBar resumeBackgroundMusicPlay];
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[ChooseBallLayer scene] withColor:ccWHITE]];
    
}

+ (BOOL)isiPad {
    
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+ (BOOL)isiPhone5 {
    return ([[UIScreen mainScreen] bounds].size.height == 568.000000);
}

+ (BOOL)isiPhoneNormalScreen {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size) : NO);
}

+ (BOOL)isRetina {
    
    return ([[CCDirector sharedDirector] contentScaleFactor] == 2);
}

+ (BOOL)isiPhone4Retina {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO);
}

+ (void)resumeBackgroundMusicPlay {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL isPauseMusic = [userDefaults boolForKey:IS_PAUSE_MUSIC];
//    if (isPauseMusic == NO) {
//        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:BACKGROUND_MUSIC];
//    }
}

+ (void)playGoEffect {
    [[SimpleAudioEngine sharedEngine] playEffect:EFFECT_GO];
}

+ (void)playBarkEffect {
    [[SimpleAudioEngine sharedEngine] playEffect:EFFECT_BARK];
}

+ (void)playBackEffect {
    [[SimpleAudioEngine sharedEngine] playEffect:EFFECT_BACK];
}


+ (CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}


@end
