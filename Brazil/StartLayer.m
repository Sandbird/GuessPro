//
//  StartLayer.m
//  Brazil
//
//  Created by 赵子龙 on 13-11-5.
//
//

#import "StartLayer.h"
//#import "EggsScene.h"
#import "GuessScene.h"
#import "MapScene.h"
#import "GameManager.h"
#import "RootViewController.h"
#import "MoreLayer.h"
#import "TrophyLayer.h"

//所有的位置坐标
typedef struct StartPostion {
    
    CGPoint startItem;
    CGPoint selectItem;
    
    CGPoint feedbackItem;
    CGPoint rateItem;
    CGPoint soundItem;
    
    CGPoint infoItem;
    CGPoint dialogueSprite;
    
    //Logo
    CGPoint logoChinese;
    CGPoint logoEnglish;
    CGPoint logoCamera;
    
}StartPostionSet;

@interface StartLayer() {
    CCSprite *_logoSprite;
//    CCSprite *_startSprite;
//    CCSprite *_hajimaruSprite;
    
    CGPoint _currentTouchPoint;
    
    CGSize _screenSize;
    
    GPNavBar *_navBar;
    
    StartPostionSet _SPSet;

}
@property (nonatomic, retain) RootViewController *controller;
@end

@implementation StartLayer

- (void)dealloc {
    
    CCLOG(@"startlayer is dealloc");
    [_controller.view removeFromSuperview];
    [_controller release], _controller = nil;
    
    [super dealloc];
}

+ (CCScene *)scene {
    
    CCScene *scene = [CCScene node];
    
    StartLayer *layer = [StartLayer node];
    
    [scene addChild:layer];
    
    return scene;
    
}

- (id)init {
    
    if (self = [super init]) {
        
        //这个版本的第一次运行
        if ([GPNavBar isThisVersionFirstTimeRun]) {
            //这个版本是否需要评价
            [GPNavBar setIsNeedRate:YES];
            
            
            //计算目前一共有多少关，是否这个版本有新加入的关卡
            NSInteger currentNum = [GPNavBar numOfPuzzlesAtCurrentVersion];
            NSInteger lastNum = [GPNavBar numOfPuzzlesAtLastVersion];
            
            if (currentNum > lastNum) {//有新加入的关卡
                //先更新用户目录下的GameData.plist
                [GPNavBar mergePuzzlesFromCurrentToLast];
                
                //更新lastPuzzlesNum
                [GPNavBar setNumOfPuzzlesAtLastVersion:currentNum];
                
            }
            
        }
        
        //touch event
//        isTouchEnabled_ = YES;
        
        //screen size
        _screenSize = [[CCDirector sharedDirector] winSize];
        
        //add texture to momery
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"StartPage.plist"]];
        
        CCLayerColor *whiteBack = [CCLayerColor layerWithColor:ccc4(40, 40, 40, 255)];
        [self addChild:whiteBack];
        
        //界面
        [self initalPostion];
        
        //LOGO
        CCSprite *ChineseSprite = [CCSprite spriteWithSpriteFrameName:@"LogoChinese.png"];
        ChineseSprite.position = _SPSet.logoChinese;
        [self addChild:ChineseSprite];
        
        CCSprite *EnglishSprite = [CCSprite spriteWithSpriteFrameName:@"LogoEnglish.png"];
        EnglishSprite.position = _SPSet.logoEnglish;
        [self addChild:EnglishSprite];
        
        CCSprite *cameraSprite = [CCSprite spriteWithSpriteFrameName:@"LogoCamera.png"];
        cameraSprite.position = _SPSet.logoCamera;
        [self addChild:cameraSprite];
        
        //开始
        NSString *spriteName = nil;
        NSString *spriteNameHL = nil;
        NSInteger numOfPuzzles = [GPNavBar numOfPuzzlesAtCurrentVersion];
        NSInteger currContinueLevel = [GPNavBar continueLevel];
        if (currContinueLevel < numOfPuzzles && (currContinueLevel > 0 || [GPNavBar isNeedRestoreScene])) {
            spriteName = @"ContinueBtn.png";
            spriteNameHL = @"ContinueBtn_HL.png";
        } else if (currContinueLevel >= numOfPuzzles){
            spriteName = @"WaitingUpdateBtn.png";
            spriteNameHL = @"WaitingUpdateBtn_HL.png";
        } else {
            spriteName = @"StartBtn.png";
            spriteNameHL = @"StartBtn_HL.png";
        }
        CCSprite *startSprite = [CCSprite spriteWithSpriteFrameName:spriteName];
        CCSprite *startHLSprite = [CCSprite spriteWithSpriteFrameName:spriteNameHL];
        CCMenuItem *startItem = [CCMenuItemSprite itemFromNormalSprite:startSprite selectedSprite:startHLSprite target:self selector:@selector(startBtnPressed)];
        startItem.anchorPoint = ccp(0.5, 0.5);
        
        //选择关卡
        CCSprite *selectSprite = [CCSprite spriteWithSpriteFrameName:@"SelectBtn.png"];
        CCSprite *selectHLSprite = [CCSprite spriteWithSpriteFrameName:@"SelectBtn_HL.png"];
        CCMenuItem *selectItem = [CCMenuItemSprite itemFromNormalSprite:selectSprite selectedSprite:selectHLSprite target:self selector:@selector(selectBtnPressed)];
        selectItem.anchorPoint = ccp(0.5, 0.5);
        
        //反馈
        CCSprite *feedbackSprite = [CCSprite spriteWithSpriteFrameName:@"SettingFeedback.png"];
        CCSprite *feedbackHLSprite = [CCSprite spriteWithSpriteFrameName:@"SettingFeedback_HL.png"];
        CCMenuItem *feedbackItem = [CCMenuItemSprite itemFromNormalSprite:feedbackSprite selectedSprite:feedbackHLSprite target:self selector:@selector(feedback)];
        feedbackItem.anchorPoint = ccp(0.5, 0.5);
        
        //声音开启关闭
        CCSprite *soundOnSprite = [CCSprite spriteWithSpriteFrameName:@"SettingSoundOn.png"];
        CCSprite *soundOnHLSprite = [CCSprite spriteWithSpriteFrameName:@"SettingSoundOn_HL.png"];
        CCMenuItem *soundOnItem = [CCMenuItemSprite itemFromNormalSprite:soundOnSprite selectedSprite:soundOnHLSprite];
        
        CCSprite *soundOffSprite = [CCSprite spriteWithSpriteFrameName:@"SettingSoundOff.png"];
        CCSprite *soundOffHLSprite = [CCSprite spriteWithSpriteFrameName:@"SettingSoundOff_HL.png"];
        CCMenuItem *soundOffItem = [CCMenuItemSprite itemFromNormalSprite:soundOffSprite selectedSprite:soundOffHLSprite];
        
        CCMenuItemToggle *soundToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(soundOn) items:soundOnItem, soundOffItem, nil];
        soundToggle.anchorPoint = ccp(0.5, 0.5);
        
        if ([GPNavBar isEnabledSoundEffect]) {
            [soundToggle setSelectedIndex:0];
            CCLOG(@"开启音频");
        } else {
            [soundToggle setSelectedIndex:1];
            CCLOG(@"关闭音频");
        }
        
        
        //评价
        CCSprite *rateSprite = [CCSprite spriteWithSpriteFrameName:@"SettingRate.png"];
        CCSprite *rateHLSprite = [CCSprite spriteWithSpriteFrameName:@"SettingRate_HL.png"];
        CCMenuItem *rateItem = [CCMenuItemSprite itemFromNormalSprite:rateSprite selectedSprite:rateHLSprite target:self selector:@selector(rateThisApp)];
        rateItem.anchorPoint = ccp(0.5, 0.5);
        
        if ([GPNavBar isNeedRate]) {
            //鼓励评价的dialogue
            CCSprite *dialogue = [CCSprite spriteWithSpriteFrameName:@"SettingDialogue.png"];
            dialogue.position = _SPSet.dialogueSprite;
            [self addChild:dialogue];
            
            CCLabelTTF *label = [CCLabelTTF labelWithString:NSLocalizedString(@"RATE", nil) fontName:FONTNAME_OF_TEXT fontSize:[GPNavBar isiPad] ? 30 : 15];
            [dialogue addChild:label];
            label.color = ccc3(40, 40, 40);
            label.position = ccp(dialogue.boundingBox.size.width / 2, dialogue.boundingBox.size.height / 2);
            
            //dialogue的动画
            CCMoveTo *moveL = [CCMoveTo actionWithDuration:0.5 position:ccp(_SPSet.dialogueSprite.x - 5, _SPSet.dialogueSprite.y)];
            CCMoveTo *moveR = [CCMoveTo actionWithDuration:0.5 position:ccp(_SPSet.dialogueSprite.x + 5, _SPSet.dialogueSprite.y)];
            CCSequence *moveLR = [CCSequence actionOne:moveL two:moveR];
            CCRepeatForever *repeat = [CCRepeatForever actionWithAction:moveLR];
            [dialogue runAction:repeat];
        }
        
        //信息
        CCSprite *infoSprite = [CCSprite spriteWithSpriteFrameName:@"SettingInfo.png"];
        CCSprite *infoHLSprite = [CCSprite spriteWithSpriteFrameName:@"SettingInfo_HL.png"];
        CCMenuItem *infoItem = [CCMenuItemSprite itemFromNormalSprite:infoSprite selectedSprite:infoHLSprite target:self selector:@selector(showInfo)];
        infoItem.anchorPoint = ccp(0.5, 0.5);
        
        CCMenu *menu = [CCMenu menuWithItems:startItem, selectItem, feedbackItem, soundToggle, rateItem, infoItem, nil];
        menu.anchorPoint = ccp(0, 0);
        menu.position = ccp(0, 0);
        [self addChild:menu];
        
        
        startItem.position = _SPSet.startItem;
        selectItem.position = _SPSet.selectItem;
        feedbackItem.position = _SPSet.feedbackItem;
        soundToggle.position = _SPSet.soundItem;
        rateItem.position = _SPSet.rateItem;
        infoItem.position = _SPSet.infoItem;
        
        
        _navBar = [[[GPNavBar alloc] initWithSceneType:GPSceneTypeStartLayer] autorelease];
        [self addChild:_navBar z:ZORDER_NAV_BAR];
        
        
        if ([GPNavBar isTodayFirstTimeComeIn]) {
            //加金币
            NSInteger numOfCoin = [GPNavBar numOfCoinAdded];
            [_navBar changeTotalScore:numOfCoin];
            [_navBar refreshTotalScore];
            
            if (numOfCoin > 0) {
                NSString *msg = [NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"TITLE_WELCOME_GIVE_YOU", nil), numOfCoin, NSLocalizedString(@"TITLE_WELCOME_COIN", nil)];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TITLE_WELCOME", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            
            
            [GPNavBar setTimesByUsingShare:0];
            [GPNavBar setTimesByUsingSOS:0];
            
            
        }
        
        [StartLayer cancelLocalNotification];
        [StartLayer createLocalNotification];
        
        
    }
    
    return self;
}

//-(void) registerWithTouchDispatcher
//{
//	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
//}

- (void)initalPostion {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    if ([GPNavBar isiPad]) {
        _SPSet.startItem = ccp(winSize.width / 2, winSize.height / 2 - 50);
        _SPSet.selectItem = ccp(winSize.width / 2, winSize.height / 2 - 220);
        
        _SPSet.feedbackItem = ccp(70, 70);
        _SPSet.soundItem = ccp(180, 70);
        _SPSet.rateItem = ccp(290, 70);
        _SPSet.dialogueSprite = ccp(450, 70);
        _SPSet.infoItem = ccp(winSize.width - 70, 70);
        
        _SPSet.logoChinese = ccp(winSize.width / 2 - 63, winSize.height - 88 - 160);
        _SPSet.logoEnglish = ccp(winSize.width / 2, winSize.height - 88 - 235);
        _SPSet.logoCamera = ccp(winSize.width / 2 + 248, _SPSet.logoChinese.y + 3);
    } else if ([GPNavBar isiPhone5]) {
        _SPSet.startItem = ccp(winSize.width / 2, winSize.height / 2 - 40);
        _SPSet.selectItem = ccp(winSize.width / 2, winSize.height / 2 - 120);
        
        _SPSet.feedbackItem     = ccp(30, 30);
        _SPSet.soundItem        = ccp(80, 30);
        _SPSet.rateItem         = ccp(130, 30);
        _SPSet.dialogueSprite = ccp(200, 30);
        _SPSet.infoItem         = ccp(winSize.width - 30, 30);
        
        _SPSet.logoChinese = ccp(winSize.width / 2 - 31, winSize.height - 44 - 102);
        _SPSet.logoEnglish = ccp(winSize.width / 2, winSize.height - 44 - 140);
        _SPSet.logoCamera = ccp(winSize.width / 2 + 123, _SPSet.logoChinese.y + 1);
        
    } else {
        _SPSet.startItem = ccp(winSize.width / 2, winSize.height / 2 - 10);
        _SPSet.selectItem = ccp(winSize.width / 2, winSize.height / 2 - 90);
        
        _SPSet.feedbackItem     = ccp(30, 30);
        _SPSet.soundItem        = ccp(80, 30);
        _SPSet.rateItem         = ccp(130, 30);
        _SPSet.dialogueSprite = ccp(200, 30);
        _SPSet.infoItem         = ccp(winSize.width - 30, 30);
        
        _SPSet.logoChinese = ccp(winSize.width / 2 - 31, winSize.height - 44 - 62);
        _SPSet.logoEnglish = ccp(winSize.width / 2, winSize.height - 44 - 100);
        _SPSet.logoCamera = ccp(winSize.width / 2 + 123, _SPSet.logoChinese.y + 1);
    }
}

- (void)startBtnPressed {
    [GPNavBar playBtnPressedEffect];
    NSInteger continueLevelNum = [GPNavBar continueLevel];
    NSInteger numOfPuzzles = [GPNavBar numOfPuzzlesAtCurrentVersion];
    if (continueLevelNum >= numOfPuzzles) {
        //本版本已经通关，跳出成就界面
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:[TrophyLayer scene]]];
    } else {
        [[GameManager sharedGameManager] loadLevelWithIndex:(int)continueLevelNum GPSceneType:GPSceneTypeContinueLayer];
    }
    
}

- (void)selectBtnPressed {
    [GPNavBar playBtnPressedEffect];
    [[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFade transitionWithDuration:0.5f scene:[MapScene scene]]];
}

- (void)soundOff {
    
    
}

- (void)soundOn {
    if ([GPNavBar isEnabledSoundEffect]) {
        [GPNavBar setIsEnabledSoundEffect:NO];
        [GPNavBar unloadSoundEffect];
    } else {
        [GPNavBar setIsEnabledSoundEffect:YES];
        [GPNavBar preloadSoundEffect];
        [GPNavBar playBtnPressedEffect];
    }
    
    
}

- (void)mailData:(NSData *)data {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops!", @"")
                                                        message:NSLocalizedString(@"Your device cannot send mail.", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
	// Start up mail picker
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	
//	UINavigationBar *bar = picker.navigationBar;
	picker.mailComposeDelegate = self;
	
	[picker setSubject:NSLocalizedString(@"PLAYER_FEEDBACK", nil)];
//	[picker addAttachmentData:data mimeType:@"image/jpg" fileName:@"wallpaper.jpg"];
	
	// Set up the recipients.
	NSArray *toRecipients = [NSArray arrayWithObjects:@"FeedbackTAD@gmail.com", nil];
	[picker setToRecipients:toRecipients];
	
	// Fill out the email body text.
    NSString *appName = [GPNavBar applicationDisplayName];
    NSString *appVersion = [GPNavBar applicationVersion];
    NSString *systemVersion = [GPNavBar systemVersion];
    NSString *deviceName = [GPNavBar platformString];
    NSString *emailBody = [NSString stringWithFormat:@"(请您把对本游戏的反馈写在下面，感谢您对我们的支持！)\n\n\n\n\n-----------------------\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n-----------------------", NSLocalizedString(@"APP_NAME", @"名称"), appName, NSLocalizedString(@"APP_VERSION", @"软件版本"), appVersion, NSLocalizedString(@"SYSTEM_VERSION", @"系统版本"), systemVersion, NSLocalizedString(@"DEVICE_NAME", @"设备"), deviceName];
	[picker setMessageBody:emailBody isHTML:NO];
	
	// Present the mail composition interface.
    [_controller presentViewController:picker animated:YES completion:^{}];
//	[_controller presentModalViewController:picker animated:YES];
	
//	bar.topItem.title = @"Email Wallpaper";
	
	[picker release]; // Can safely release the controller now.
}


- (void)feedback {
    
    [GPNavBar playBtnPressedEffect];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (_controller == nil) {
        //加一个UIViewController
        _controller = [[RootViewController alloc] init];
        _controller.view.frame = CGRectMake(0,0,winSize.width,winSize.height);
        [[[CCDirector sharedDirector] openGLView]addSubview : _controller.view];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        NSData *data = UIImageJPEGRepresentation(curImage, 0.8);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self mailData:nil];
        });
    });

}

#define URL_RATE_IOS7 @"itms-apps://itunes.apple.com/app/id"
#define URL_RATE_IOS6 @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id="
- (void)rateThisApp {
    
    [GPNavBar playBtnPressedEffect];
    
    //评论之后，不需要再次闪现评论dialogue
    [GPNavBar setIsNeedRate:NO];
    
    NSString *rateMe = [NSString stringWithFormat:@"%@%@", (IOS_NEWER_OR_EQUAL_TO_7 ? URL_RATE_IOS7 : URL_RATE_IOS6), APP_ID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rateMe]];
    
}

- (void)showInfo {
    
    [GPNavBar playBtnPressedEffect];
    
    MoreLayer *moreLayer = [MoreLayer node];
    [self addChild:moreLayer z:ZORDER_NAV_BAR + 1];
    
    moreLayer.scale = 0;
    CCScaleTo *scaleToBig = [CCScaleTo actionWithDuration:0.2 scale:1];
    CCSequence *smallToBig = [CCSequence actions:scaleToBig, nil];
    [moreLayer runAction:smallToBig];
    
    
}


- (void)transToNext {
    
    [[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFade transitionWithDuration:0.5f scene:[MapScene scene]]];
}


+ (void)cancelLocalNotification {
    
    //删除badge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //删除所有通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

+ (void)createLocalNotification {
    
//    if (![UserSetting isPushDate]) {
//        return;
//    }
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        
        int hour = 10;
        int min = 0;
        
        NSString *tomorrow = [[NSDate dateWithTimeIntervalSinceNow:24*60*60*2] description];
        
        NSArray *dateArray = [tomorrow componentsSeparatedByString:@" "];
        NSString *tomorrowStr = [dateArray objectAtIndex:0];
        dateArray = [tomorrowStr componentsSeparatedByString:@"-"];
        
        NSInteger year = [[dateArray objectAtIndex:0] integerValue];
        NSInteger month = [[dateArray objectAtIndex:1] integerValue];
        NSInteger day = [[dateArray objectAtIndex:2] integerValue];
        
        NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
        [components setYear:year];
        [components setMonth:month];
        [components setDay:day];
        [components setHour:hour];
        [components setMinute:min];
        
        //本地化一下子
        NSCalendar *localCalendar = [NSCalendar currentCalendar];
        
        NSDate *date = [localCalendar dateFromComponents:components];
        
        localNotif.fireDate = date;
        
        CCLOG(@"hour is %d, min is %d\n下次推送时间是%@", hour, min, localNotif.fireDate);
        
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        localNotif.repeatInterval = NSDayCalendarUnit;
        
        //本地化一下子
        NSString *pushStr = nil;
        NSInteger numOfCoin;
        
        switch (arc4random() % 3) {
            case 0://大椰
                numOfCoin = 50;
                break;
                
            case 1://小桃
                numOfCoin = 20;
                break;
                
            case 2:
                numOfCoin = 30;
                break;
                
            default:
                numOfCoin = 50;
                break;
        }
        pushStr = [NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"TODAY_COME_TO_PLAY", @"今天之内来玩，就送"), numOfCoin, NSLocalizedString(@"TODAY_COME_GIVE_COIN", @"枚金币！")];
        
        [GPNavBar setNumOfCoinAdded:numOfCoin];
        
        localNotif.alertBody = pushStr;
        localNotif.alertAction = NSLocalizedString(@"来玩就送金币", @"alertAction");
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        
        localNotif.applicationIconBadgeNumber = 1;
        
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"name"forKey:@"key"];
        localNotif.userInfo = info;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
    [localNotif release];
    
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
    
    [_controller dismissViewControllerAnimated:YES completion:^{}];
}


@end
