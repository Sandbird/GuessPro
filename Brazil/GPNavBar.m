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
#import "StartLayer.h"

#import "CoinStore.h"
#import "ZZAcquirePath.h"

//判断设备是IPHONE还是IPAD
#define IPAD_DEVICE [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define IPHONE5_DEVICE [[UIScreen mainScreen] bounds].size.height == 568.000000

#define EFFECT_GO @"goEffect.caf"
#define EFFECT_BACK @"backEffect.caf"
#define EFFECT_BARK @"bark.caf"

@interface GPNavBar() {
//    CCSprite *_backgroudSprite;
    CCLabelTTF *_totalScoreLabel;
    
//    CCLabelTTF *_tipsLabel;
    
//    CCSprite *_kayacSprite;
    
    CCMenuItem *_coinItem;
    
    
    ShareBorad *_shareBorad;
    CoinStore *_coinStore;
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
        
        self.isTouchEnabled = YES;
    
        self.isPlaying = isPlaying;
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"GPNavBar.plist"]];
        CCSpriteFrame *frame;
        
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        if ([GPNavBar isiPad]) {
            fontsize = 48;
        } else {
            fontsize = 22;
        }
        
        frame = [frameCache spriteFrameByName:@"GPNavBar.png"];
        _backgroudSprite = [CCSprite spriteWithSpriteFrame:frame];
        _backgroudSprite.anchorPoint = ccp(0.5, 1);
        _backgroudSprite.position = ccp(winSize.width / 2, winSize.height);
        [self addChild:_backgroudSprite];
        
        CGFloat centreOfHeight = winSize.height - _backgroudSprite.boundingBox.size.height / 2;
        
        //金币
        CCSprite *coinSprite = [CCSprite spriteWithSpriteFrameName:@"Coin.png"];
        CCSprite *coinHLSprite = [CCSprite spriteWithSpriteFrameName:@"Coin_HL.png"];
        _coinItem = [CCMenuItemImage itemFromNormalSprite:coinSprite selectedSprite:coinHLSprite target:self selector:@selector(showStoreLayer)];
        _coinItem.anchorPoint = ccp(0.5, 0.5);
        _coinItem.position = ccp(winSize.width - _coinItem.boundingBox.size.width / 2 - 20, centreOfHeight);
        
        //分数
        self.totalScore = [self loadPlayerStatusTotalScore];
        _totalScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", self.totalScore] fontName:@"ArialRoundedMTBold" fontSize:fontsize];
        _totalScoreLabel.color = ccc3(60, 60, 60);
        _totalScoreLabel.anchorPoint = ccp(1, 0.5);
        _totalScoreLabel.position = ccp(_coinItem.boundingBox.origin.x - _coinItem.boundingBox.size.width / 2, centreOfHeight);
        [self addChild:_totalScoreLabel];
        
        //返回键
        CCSprite *backSprite = [CCSprite spriteWithSpriteFrameName:@"Back.png"];
        CCSprite *backHLSprite = [CCSprite spriteWithSpriteFrameName:@"Back_HL.png"];
        CCMenuItem *backItem = [CCMenuItemImage itemFromNormalSprite:backSprite selectedSprite:backHLSprite target:self selector:@selector(popToMenu)];
        
        CCMenu *mainMenu = [CCMenu menuWithItems:backItem, _coinItem, nil];
        backItem.anchorPoint = ccp(0, 0.5);
        backItem.position = ccp(10, centreOfHeight);
        mainMenu.position = ccp(0, 0);
        [self addChild:mainMenu];
    }
    
    return self;
    
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-100 swallowsTouches:YES];
}

- (BOOL)isTouchForMe:(CGPoint)touchLocation {
    return CGRectContainsPoint(_backgroudSprite.boundingBox, touchLocation);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [GPNavBar locationFromTouch:touch];
    BOOL isTouchHandled = [self isTouchForMe:location];
    if (isTouchHandled) {
        
    }
    
    return isTouchHandled;
}

- (void)popToMenu {
    
    if (self.isPlaying) {
        [[GuessScene sharedGuessScene] saveScene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MapScene scene]]];
    } else {
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StartLayer scene]]];
   
    }
    
    
}

- (int)scores {
    return _totalScore;
}

- (void)setTipsLabelStr:(NSString *)str {
//    [_tipsLabel setString:str];
}

- (void)refreshTotalScore {
     [_totalScoreLabel setString:[NSString stringWithFormat:@"%d", self.totalScore]];
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
            [_totalScoreLabel setString:[NSString stringWithFormat:@"%d", self.totalScore]];
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
            [_totalScoreLabel setString:[NSString stringWithFormat:@"%d", i]];
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

- (void)showStoreLayer {
    if (_coinStore) {
        [_coinStore removeFromParentAndCleanup:YES];
        _coinStore = nil;
    } else {
        _coinStore = [CoinStore node];
        [self addChild:_coinStore];
        
//        [_coinStore smallToBigAction];
        _coinStore.scale = 0;
        CCScaleTo *scaleToBig = [CCScaleTo actionWithDuration:0.2 scale:1];
//        CCScaleTo *scaleToSmall = [CCScaleTo actionWithDuration:0.1 scale:0.9];
//        CCScaleTo *scaleToNormal = [CCScaleTo actionWithDuration:0.1 scale:1];
        
        CCSequence *smallToBig = [CCSequence actions:scaleToBig,/* scaleToSmall, scaleToNormal,*/ nil];
        
        [_coinStore runAction:smallToBig];
    }
}

- (void)saveScreenshotToLocal {
    
    NSString *filePath = [ZZAcquirePath getDocDirectoryWithFileName:@"sharePic.png"];

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // 设定截图大小
    CCRenderTexture  *target = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    [target begin];
    
    // 添加需要截取的CCNode
    [[self parent] visit];
    
    [target end];
    [target saveBuffer:filePath format:kCCImageFormatPNG];
}

- (void)deleteScreenshotFromLocal {
    NSString *filePath = [ZZAcquirePath getDocDirectoryWithFileName:@"sharePic.png"];
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    BOOL result = [defaultManager removeItemAtPath:filePath error:&error];
    
    if (!result) {
        CCLOG(@"%@", error);
    }
}

- (void)showShareBoradWithType:(ShareBoradShareType)SBSType {
    if (_shareBorad) {
        //删除本地截图
        [self deleteScreenshotFromLocal];
        
        [_shareBorad removeFromParentAndCleanup:YES];
        _shareBorad = nil;
    } else {
        //保存截图到本地
        [self saveScreenshotToLocal];
        
        _shareBorad = [[[ShareBorad alloc] initWithShareType:SBSType] autorelease];
        [self addChild:_shareBorad];
        _shareBorad.scale = 0;
        CCScaleTo *scaleToBig = [CCScaleTo actionWithDuration:0.2 scale:1];
//        CCScaleTo *scaleToSmall = [CCScaleTo actionWithDuration:0.1 scale:0.9];
//        CCScaleTo *scaleToNormal = [CCScaleTo actionWithDuration:0.1 scale:1];
        
        CCSequence *smallToBig = [CCSequence actions:scaleToBig, /*scaleToSmall, scaleToNormal,*/ nil];
        
        [_shareBorad runAction:smallToBig];
    }
}

#pragma mark - push method

#define ADD_COIN_TIMES_SOS_TODAY    @"AddCoinTimesSOSToday"
#define ADD_COIN_TIMES_SHARE_TODAY  @"AddCoinTimesShareToday"
//#define ADD_COIN_TIMES_COMEIN_TODAY @"AddCoinTimesComeInToday"
#define LAST_DATE_STRING @"LastDateString"

+ (NSString *)todayDateString {
    NSString *dateString = [[NSDate date] description];
    NSArray *dateArray = [dateString componentsSeparatedByString:@" "];
    NSString *todayString = [dateArray objectAtIndex:0];
    
    return todayString;
}

+ (void)setLastDateString:(NSString *)dateString {
    [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:LAST_DATE_STRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)lastDateString {
    return [[NSUserDefaults standardUserDefaults] objectForKey:LAST_DATE_STRING];
}

+ (BOOL)isTodayFirstTimeComeIn {
    
    NSString *now = [GPNavBar todayDateString];
    NSString *last = [GPNavBar lastDateString];
    
    
    if ([now isEqualToString:last]) {//是同一天
        return NO;
    } else {//是新的一天
        [GPNavBar setLastDateString:now];
        return YES;
    }
    
}

+ (void)setTimesByUsingSOS:(NSInteger)times {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:times] forKey:ADD_COIN_TIMES_SOS_TODAY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setTimesByUsingShare:(NSInteger)times {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:times] forKey:ADD_COIN_TIMES_SHARE_TODAY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//今天求助是否还加分
+ (BOOL)isTodayCanAddCoinWithSOS {
    NSInteger times = [[[NSUserDefaults standardUserDefaults] objectForKey:ADD_COIN_TIMES_SOS_TODAY] integerValue];
    times++;
    if (times >= 5) {
        return NO;
    } else {
        [GPNavBar setTimesByUsingSOS:times];
        return YES;
    }
}

//今天分享是否还加分
+ (BOOL)isTodayCanAddCoinWithShare {
    NSInteger times = [[[NSUserDefaults standardUserDefaults] objectForKey:ADD_COIN_TIMES_SHARE_TODAY] integerValue];
    times++;
    if (times >= 5) {
        return NO;
    } else {
        [GPNavBar setTimesByUsingShare:times];
        return YES;
    }
}

#define NUM_OF_COIN_ADDED @"NumOfCoinToBeAdding"

//加金币的数量
+ (NSInteger)numOfCoinAdded {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NUM_OF_COIN_ADDED] integerValue];
}

+ (void)setNumOfCoinAdded:(NSInteger)num {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:num] forKey:NUM_OF_COIN_ADDED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
