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

#include <sys/types.h>
#include <sys/sysctl.h>

//判断设备是IPHONE还是IPAD
#define IPAD_DEVICE [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define IPHONE5_DEVICE [[UIScreen mainScreen] bounds].size.height == 568.000000

#define EFFECT_GO @"goEffect.caf"
#define EFFECT_BACK @"backEffect.caf"
#define EFFECT_BARK @"bark.caf"

#import "GTMDefines.h"
#import "GTMBase64_New.h"



@interface GPNavBar() {
//    CCSprite *_backgroudSprite;
    CCLabelTTF *_totalScoreLabel;
    
//    CCLabelTTF *_tipsLabel;
    
//    CCSprite *_kayacSprite;
    
    CCMenuItem *_coinItem;
    
    
    ShareBorad *_shareBorad;
    CoinStore *_coinStore;
    
    CGRect _rect;
    
    CGSize _winSize;
}

@property (assign) int totalScore;
//@property (assign) BOOL isPlaying;

@property (assign) GPSceneType sceneType;

@end

@implementation GPNavBar

- (void)dealloc {
    
    CCLOG(@"navbar dealloc");
    [super dealloc];
}

- (id)initWithSceneType:(GPSceneType)sceneType {

    
    if (self = [super init]) {
        
        self.isTouchEnabled = YES;
    
        self.sceneType = sceneType;
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"GPNavBar.plist"]];
        
        _winSize = [[CCDirector sharedDirector] winSize];
        
        CGFloat heightOfNavbar = [GPNavBar isiPad] ? 88.0f : 44.0f;
        
        //第一页没有背景
//        if (self.sceneType != GPSceneTypeStartLayer) {
            CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255) width:_winSize.width height:heightOfNavbar];
            color.position = ccp(0, _winSize.height - color.boundingBox.size.height);
            [self addChild:color];
//        }
        
        _rect = CGRectMake(0, _winSize.height - heightOfNavbar, _winSize.width, heightOfNavbar);
        
        CGFloat centreOfHeight = _winSize.height - _rect.size.height / 2;
        
        //金币
        CCSprite *coinSprite = [CCSprite spriteWithSpriteFrameName:@"Coin.png"];
        CCSprite *coinHLSprite = [CCSprite spriteWithSpriteFrameName:@"Coin_HL.png"];
        _coinItem = [CCMenuItemImage itemFromNormalSprite:coinSprite selectedSprite:coinHLSprite target:self selector:@selector(showStoreLayer)];
        _coinItem.anchorPoint = ccp(0.5, 0.5);
        _coinItem.position = ccp(_winSize.width - _coinItem.boundingBox.size.width / 2 - 10, centreOfHeight);
        
        //分数
        self.totalScore = [self loadPlayerStatusTotalScore];
        _totalScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", self.totalScore] fontName:/*@"ArialRoundedMTBold"*/FONTNAME_OF_TEXT fontSize:([GPNavBar isiPad] ? 48 : 22)];
        _totalScoreLabel.color = ccc3(50, 50, 50);
        _totalScoreLabel.anchorPoint = ccp(1, 0.5);
        _totalScoreLabel.position = ccp(_coinItem.boundingBox.origin.x - _coinItem.boundingBox.size.width / 2 + ([GPNavBar isiPad] ? 20 : 15), centreOfHeight);
        [self addChild:_totalScoreLabel];
        [self resizeTotalLabel];
        
        CCMenu *mainMenu = nil;
        if (self.sceneType != GPSceneTypeStartLayer) {
            //返回键
            CCSprite *backSprite = [CCSprite spriteWithSpriteFrameName:@"Back.png"];
            CCSprite *backHLSprite = [CCSprite spriteWithSpriteFrameName:@"Back_HL.png"];
            CCMenuItem *backItem = [CCMenuItemImage itemFromNormalSprite:backSprite selectedSprite:backHLSprite target:self selector:@selector(popToMenu)];
            
            mainMenu = [CCMenu menuWithItems:backItem, _coinItem, nil];
            backItem.anchorPoint = ccp(0, 0.5);
            backItem.position = ccp(10, centreOfHeight);
            
        } else {
            mainMenu = [CCMenu menuWithItems:_coinItem, nil];
        }
        
        mainMenu.position = ccp(0, 0);
        [self addChild:mainMenu];
        
        
    }
    
    return self;
    
}

- (void)resizeTotalLabel {
    if (_totalScoreLabel.boundingBox.size.width > _winSize.width / 5) {
        _totalScoreLabel.scaleX = _winSize.width / 5 / _totalScoreLabel.boundingBox.size.width;
    } else {
        _totalScoreLabel.scaleX = 1.0;
    }
}

#define TAG_SPRITE_BACK 222
#define TAG_LABEL_NUMBER 333
- (void)setNavbarMissionWithNumber:(NSInteger)number {
    CCSprite *missionNumberSprite = (CCSprite *)[self getChildByTag:TAG_SPRITE_BACK];
    CCLabelTTF *labelNum = nil;
    if (missionNumberSprite != nil) {
        labelNum = (CCLabelTTF *)[missionNumberSprite getChildByTag:TAG_LABEL_NUMBER];
        [labelNum setString:[NSString stringWithFormat:@"-%d-", number]];
        
    } else {
        
        missionNumberSprite = [CCSprite spriteWithSpriteFrameName:@"MissionNumber.png"];
        missionNumberSprite.tag = TAG_SPRITE_BACK;
        [self addChild:missionNumberSprite];
        CGFloat centreOfHeight = _winSize.height - _rect.size.height / 2;
        missionNumberSprite.position = ccp(_winSize.width / 2, centreOfHeight);
        
        
        labelNum = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"-%d-", number] fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TEXT];
        labelNum.tag = TAG_LABEL_NUMBER;
        labelNum.color = ccWHITE;
        [missionNumberSprite addChild:labelNum];
        CGSize size = missionNumberSprite.boundingBox.size;
        labelNum.position = ccp(size.width / 2, size.height / 2);
        
    }
}

- (void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-100 swallowsTouches:YES];
}

- (BOOL)isTouchForMe:(CGPoint)touchLocation {
    return CGRectContainsPoint(_rect, touchLocation);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [GPNavBar locationFromTouch:touch];
    BOOL isTouchHandled = [self isTouchForMe:location];
    if (isTouchHandled) {
        
    }
    
    return isTouchHandled;
}

- (void)popToMenu {
    
    [GPNavBar playBtnPressedEffect];
    
    if (self.sceneType == GPSceneTypeGuessLayer) {
        [[GuessScene sharedGuessScene] saveScene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MapScene scene]]];
    } else if (self.sceneType == GPSceneTypeLevelLayer){
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StartLayer scene]]];
   
    } else if (self.sceneType == GPSceneTypeContinueLayer) {
        [[GuessScene sharedGuessScene] saveScene];
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
    [self resizeTotalLabel];
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
        CCScaleTo *big = [CCScaleTo actionWithDuration:0.08 scale:1.1];
        CCScaleTo *normal = [CCScaleTo actionWithDuration:0.02 scale:1.0];
        CCCallBlock *changeWord = [CCCallBlock actionWithBlock:^{
            [_totalScoreLabel setString:[NSString stringWithFormat:@"%d", self.totalScore]];
        }];
        CCSequence *seq = [CCSequence actions:changeWord, big, normal, nil];
        [actions addObject:seq];
        
    }
    
    CCSequence *seqs = [CCSequence actionsWithArray:actions];
    CCSequence *seq2 = [CCSequence actionOne:[CCDelayTime actionWithDuration:DELAY_OF_EXTRA_SCORE] two:seqs];
    seq2.tag = ACTION_UP_SCORE_TAG;
    [_totalScoreLabel runAction:seq2];
    
    //    [self changeTotalScore:extraScore];
}

- (void)playScoreAnimationWithExtraScore:(int)extraScore {
    
    NSMutableArray *actions = [NSMutableArray array];
//    NSMutableArray *kayacActions = [NSMutableArray array];
    for (int i = self.totalScore + 1; i <= self.totalScore + extraScore; i++) {
        CCScaleTo *big = [CCScaleTo actionWithDuration:0.08 scale:1.1];
        CCScaleTo *normal = [CCScaleTo actionWithDuration:0.02 scale:1.0];
        CCCallBlock *changeWord = [CCCallBlock actionWithBlock:^{
            [_totalScoreLabel setString:[NSString stringWithFormat:@"%d", i]];
            [self resizeTotalLabel];
        }];
        CCSequence *seq = [CCSequence actions:changeWord, big, normal, nil];
        [actions addObject:seq];
        
    }
    
    CCSequence *seqs = [CCSequence actionsWithArray:actions];
    CCSequence *seq2 = [CCSequence actionOne:[CCDelayTime actionWithDuration:DELAY_OF_EXTRA_SCORE] two:seqs];
    seq2.tag = ACTION_UP_SCORE_TAG;
    [_totalScoreLabel runAction:seq2];
    
//    [self changeTotalScore:extraScore];
}

+ (void)giveScoreForFirstTimeInstallApp {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSNumber numberWithInteger:NUM_OF_FIRST_TIME_INSTALL_APP] forKey:PS_TOTAL_SCORE];
    if (![userDefaults synchronize]) {
        CCLOG(@"error saveGameState");
    }
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

+ (NSInteger)continueLevel {
    NSNumber *levelNumber = [[NSUserDefaults standardUserDefaults] objectForKey:PS_CONTINUE_LEVEL];
    if (levelNumber == nil) {
        levelNumber = [NSNumber numberWithInteger:0];
    }
    
    return levelNumber.integerValue;
}

+ (BOOL)isNeedRestoreScene {
    NSNumber *isNeed = [[NSUserDefaults standardUserDefaults] objectForKey:PS_IS_NEED_RESTORE_SCENE];
    
    return isNeed.boolValue;
}

+ (void)setContinueLevel:(NSInteger)levelNum isNeedRestoreScene:(BOOL)isNeed {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:levelNum] forKey:PS_CONTINUE_LEVEL];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isNeed] forKey:PS_IS_NEED_RESTORE_SCENE];
    if (![[NSUserDefaults standardUserDefaults] synchronize]) {
        CCLOG(@"存储用户进度错误");
    }
}

- (void)transToMainScene {
    
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


+ (CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (void)showStoreLayer {
    
    [GPNavBar playBtnPressedEffect];
    
    if (_coinStore) {
        
        [_coinStore removeFromParentAndCleanup:YES];
        _coinStore = nil;
    } else {
        _coinStore = [CoinStore node];
        [self addChild:_coinStore];
        
        _coinStore.scale = 0;
        CCScaleTo *scaleToBig = [CCScaleTo actionWithDuration:0.2 scale:1];
        CCSequence *smallToBig = [CCSequence actions:scaleToBig, nil];
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
    [GPNavBar playBtnPressedEffect];
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
    if (times > 3) {
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
    if (times > 1) {
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

#pragma mark - First Time Run

//程序是否第一次安装运行
#define kIsFirstTimeInstall @"kIsFirstTimeInstall"
+ (BOOL)isFirstTimeInstallApplication {
    BOOL  hasRunBefore = [[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstTimeInstall];
    if (!hasRunBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsFirstTimeInstall];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    return NO;
}

//此版本是否第一次运行
+ (BOOL)isThisVersionFirstTimeRun {
    NSString *version = [GPNavBar buildVersion];
    BOOL  hasRunBefore = [[NSUserDefaults standardUserDefaults] boolForKey:version];
    
    if (!hasRunBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:version];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    return NO;
}

+ (NSString *)buildVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow(infoDictionary);
    // app build版本
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    return app_build;
}

#define kIsNeedRate @"kIsNeedRate"
+ (void)setIsNeedRate:(BOOL)isRate {
    [[NSUserDefaults standardUserDefaults] setBool:isRate forKey:kIsNeedRate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isNeedRate {
    BOOL isRate = [[NSUserDefaults standardUserDefaults] boolForKey:kIsNeedRate];
    return isRate;
}

#define kIsEnabledSoundEffect @"kIsEnabledSoundEffect"
+ (BOOL)isEnabledSoundEffect {
    BOOL isEnabledSound = [[NSUserDefaults standardUserDefaults] boolForKey:kIsEnabledSoundEffect];
    return isEnabledSound;
}

+ (void)setIsEnabledSoundEffect:(BOOL)isEnabled {
    [[NSUserDefaults standardUserDefaults] setBool:isEnabled forKey:kIsEnabledSoundEffect];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)preloadSoundEffect {
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"BtnPressed.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"BlockBreak.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Success.mp3"];
}

+ (void)unloadSoundEffect {
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"BtnPressed.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"BlockBreak.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"Success.mp3"];
}

+ (ALint)playSuccessEffect {
    ALint soundInt = 0;
    if ([GPNavBar isEnabledSoundEffect]) {
        soundInt = [[SimpleAudioEngine sharedEngine] playEffect:@"Success.mp3"];
    }
    
    return soundInt;
}

+ (void)stopSuccessEffectBy:(ALint)soundInt {
    if ([GPNavBar isEnabledSoundEffect]) {
        [[SimpleAudioEngine sharedEngine] stopEffect:soundInt];
    }
}

+ (void)playBtnPressedEffect {
    if ([GPNavBar isEnabledSoundEffect]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"BtnPressed.caf"];
    }
    
}

+ (void)playBlockBreakEffect {
    if ([GPNavBar isEnabledSoundEffect]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"BlockBreak.caf"];
    }
}

+ (void)playWordPressedEffect {
    if ([GPNavBar isEnabledSoundEffect]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"WordPressedEffect.caf"];
    }
}

+ (void)playWordBackEffect {
    if ([GPNavBar isEnabledSoundEffect]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"WordBackEffect.caf"];
    }
}

+ (void)playFlyItemEffect {
    if ([GPNavBar isEnabledSoundEffect]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"FlyItemSoundEffect.mp3"];
    }
}

#pragma mark - Device Info

+ (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (NSString *)applicationDisplayName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow(infoDictionary);
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
//    NSString *appName = NSLocalizedStringFromTable(@"Bundle name", @"InfoPlist", @"应用名称");
    
    return appName;
}

+ (NSString *)applicationVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow(infoDictionary);
    // app名称
    //    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    return app_Version;
}

+ (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *) platformString{
    
    /*
     @"i386"      on the simulator
     @"iPod1,1"   on iPod Touch
     @"iPod2,1"   on iPod Touch Second Generation
     @"iPod3,1"   on iPod Touch Third Generation
     @"iPod4,1"   on iPod Touch Fourth Generation
     @"iPhone1,1" on iPhone
     @"iPhone1,2" on iPhone 3G
     @"iPhone2,1" on iPhone 3GS
     @"iPad1,1"   on iPad
     @"iPad2,1"   on iPad 2
     @"iPad3,1"   on 3rd Generation iPad
     @"iPhone3,1" on iPhone 4
     @"iPhone4,1" on iPhone 4S
     @"iPhone5,1" on iPhone 5 (model A1428, AT&T/Canada)
     @"iPhone5,2" on iPhone 5 (model A1429, everything else)
     @"iPad3,4" on 4th Generation iPad
     @"iPad2,5" on iPad Mini
     @"iPhone5,3" on iPhone 5c (model A1456, A1532 | GSM)
     @"iPhone5,4" on iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)
     @"iPhone6,1" on iPhone 5s (model A1433, A1533 | GSM)
     @"iPhone6,2" on iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)
     @"iPad4,1" on 5th Generation iPad (iPad Air) - Wifi
     @"iPad4,2" on 5th Generation iPad (iPad Air) - Cellular
     @"iPad4,4" on 2nd Generation iPad Mini - Wifi
     @"iPad4,5" on 2nd Generation iPad Mini - Cellular
     */
    NSString *platform = [GPNavBar platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air(Wifi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air(Cellular)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2(Wifi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2(Cellular)";
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])         return @"iOS Simulator";
    return platform;
}

// 加密函数
+(void)func_encodeFileWithImgName:(NSString *)picName
{
    //NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/test.png"];
    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/PuzzlePictures_jpg/%@.jpg", picName];
    
    //文件路径转换为NSData
    NSData *imageDataOrigin = [NSData dataWithContentsOfFile:filePath];
    
    // 对前1000位进行异或处理
    //    unsigned char * cByte = (unsigned char*)[imageDataOrigin bytes];
    //    for (int index = 0; (index < [imageDataOrigin length]) && (index < 1000); index++, cByte++)
    //    {
    //        *cByte = (*cByte) ^ arrayForEncode[index];
    //    }
    
    //对NSData进行base64编码
    NSData *imageDataEncode = [GTMBase64_New encodeData:imageDataOrigin];
    
    [imageDataEncode writeToFile:filePath atomically:YES];
}

// 解密函数
+(NSData *)func_decodeFile:(NSString *)picName
{
    //NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/test.png"];
    NSString *filePath = [ZZAcquirePath getBundleDirectoryWithFileName:picName];
    
    // 读取被加密文件对应的数据
    NSData *dataEncoded = [NSData dataWithContentsOfFile:filePath];
    
    // 对NSData进行base64解码
    NSData *dataDecode = [GTMBase64_New decodeData:dataEncoded];
    
    return dataDecode;
    
    // 对前1000位进行异或处理
    //    unsigned char * cByte = (unsigned char*)[dataDecode bytes];
    //    for (int index = 0; (index < [dataDecode length]) && (index < 10); index++, cByte++)
    //    {
    //        *cByte = (*cByte) ^ arrayForEncode[index];
    //    }
    
//    [dataDecode writeToFile:filePath atomically:YES];
}

+ (NSInteger)numOfPuzzlesAtCurrentVersion {
    NSString *path = [ZZAcquirePath getBundleDirectoryWithFileName:@"GameData.plist"];
    
    NSMutableDictionary *gameData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSMutableArray *puzzleArray = [gameData objectForKey:@"Levels"];
    
    return puzzleArray.count;
}

#define kNumOfPuzzlesAtLastVersion @"kNumOfPuzzlesAtLastVersion"
+ (NSInteger)numOfPuzzlesAtLastVersion {
    NSInteger numOfPuzzles = [[NSUserDefaults standardUserDefaults] integerForKey:kNumOfPuzzlesAtLastVersion];
    return numOfPuzzles;
}

+ (void)setNumOfPuzzlesAtLastVersion:(NSInteger)num {
    [[NSUserDefaults standardUserDefaults] setInteger:num forKey:kNumOfPuzzlesAtLastVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//将新老puzzle数据融合到用户目录下
+ (void)mergePuzzlesFromCurrentToLast {
    NSString *lastUserPath = [ZZAcquirePath getDocDirectoryWithFileName:@"GameData.plist"];
    NSMutableDictionary *lastGameData = [NSMutableDictionary dictionaryWithContentsOfFile:lastUserPath];
    NSMutableArray *lastPuzzleArray = [lastGameData objectForKey:@"Levels"];
    
    if (lastPuzzleArray.count == 0 || lastPuzzleArray == nil) {
        return;
    }
    
    NSString *currUserPath = [ZZAcquirePath getBundleDirectoryWithFileName:@"GameData.plist"];
    NSMutableDictionary *currGameData = [NSMutableDictionary dictionaryWithContentsOfFile:currUserPath];
    NSMutableArray *currPuzzleArray = [currGameData objectForKey:@"Levels"];
    
    NSRange range;
    range.location = 0;
    range.length = lastPuzzleArray.count;
    
    [currPuzzleArray removeObjectsInRange:range];
    [lastPuzzleArray addObjectsFromArray:currPuzzleArray];
    
    [lastPuzzleArray writeToFile:lastUserPath atomically:YES];
}

#pragma mark - help
#define kIsShowHelpItem @"kIsShowHelpItem"
#define kIsShowHelpBouns @"kIsShowHelpBouns"
+ (void)setIsShowHelpItem:(BOOL)isShow {
    [[NSUserDefaults standardUserDefaults] setBool:isShow forKey:kIsShowHelpItem];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isShowHelpItem {
    BOOL isShow = [[NSUserDefaults standardUserDefaults] boolForKey:kIsShowHelpItem];
    return isShow;
}

+ (void)setIsShowHelpBouns:(BOOL)isShow {
    [[NSUserDefaults standardUserDefaults] setBool:isShow forKey:kIsShowHelpBouns];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isShowHelpBouns {
    BOOL isShow = [[NSUserDefaults standardUserDefaults] boolForKey:kIsShowHelpBouns];
    return isShow;
}

#define kIsShowSmallIntro @"kIsShowSmallIntro"
#define kIsShowBombIntro @"kIsShowBombIntro"
#define kIsShowFlyIntro @"kIsShowFlyIntro"
+ (BOOL)isShowSmallIntro {
    BOOL  hasRunBefore = [[NSUserDefaults standardUserDefaults] boolForKey:kIsShowSmallIntro];
    if (!hasRunBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsShowSmallIntro];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    return NO;
}

+ (BOOL)isShowBombIntro {
    BOOL  hasRunBefore = [[NSUserDefaults standardUserDefaults] boolForKey:kIsShowBombIntro];
    if (!hasRunBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsShowBombIntro];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    return NO;
}

+ (BOOL)isShowFlyIntro {
    BOOL  hasRunBefore = [[NSUserDefaults standardUserDefaults] boolForKey:kIsShowFlyIntro];
    if (!hasRunBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsShowFlyIntro];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    return NO;
}



@end
