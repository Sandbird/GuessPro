//
//  SuccessLayer.m
//  Brazil
//
//  Created by zhaozilong on 13-11-2.
//
//

#import "SuccessLayer.h"
#import "GuessScene.h"
#import "UIImage+MostColor.h"
#import "ZZAcquirePath.h"

#import "RootViewController.h"
#import "InformationBorad.h"

#import "GPDatabase.h"
#import "TrophyLayer.h"

@interface SuccessLayer() {

    CCSprite *_nextSprite;
    
    BOOL _isBeginTouched;
    
    CCLayerColor *_successColor;
    
    CCLabelTTF *_posLabel;
    
    CCMenu *_menu;
    
    ccColor4B _layerColor;
}

//@property (nonatomic, retain) GADBannerView *adView;
//@property (nonatomic, retain) RootViewController *controller;
@property (nonatomic, retain) NSString *curInfo;

@end

@implementation SuccessLayer

- (void)dealloc {
    CCLOG(@"Success release");
    
//    [_adView release];
//    [_controller.view removeFromSuperview];
//    [_controller release];
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        
        CCSprite *shareSprite = [CCSprite spriteWithSpriteFrameName:@"shareBtn.png"];
        CCSprite *shareHLSprite = [CCSprite spriteWithSpriteFrameName:@"shareBtn_HL.png"];
        CCMenuItem *shareItem = [CCMenuItemImage itemFromNormalSprite:shareSprite selectedSprite:shareHLSprite target:self selector:@selector(shareToSocial)];
        
        
        CCSprite *infoSprite = [CCSprite spriteWithSpriteFrameName:@"infoBtn.png"];
        CCSprite *infoHLSprite = [CCSprite spriteWithSpriteFrameName:@"infoBtn_HL.png"];
        CCMenuItem *infoItem = [CCMenuItemImage itemFromNormalSprite:infoSprite selectedSprite:infoHLSprite target:self selector:@selector(popInformation)];
        
        
        CCSprite *nextSprite = [CCSprite spriteWithSpriteFrameName:@"nextBtn.png"];
        CCSprite *nextHLSprite = [CCSprite spriteWithSpriteFrameName:@"nextBtn_HL.png"];
        CCMenuItem *nextItem = [CCMenuItemImage itemFromNormalSprite:nextSprite selectedSprite:nextHLSprite target:self selector:@selector(nextPicture)];
        
        
        if ([GPNavBar isiPad]) {
            shareItem.position = ccp(winSize.width / 2 - 200, 200);
            infoItem.position = ccp(winSize.width / 2, 200);
            nextItem.position = ccp(winSize.width / 2 + 200, 200);
        } else if ([GPNavBar isiPhone5]) {
            shareItem.position = ccp(winSize.width / 2 - 80, 100);
            infoItem.position = ccp(winSize.width / 2, 100);
            nextItem.position = ccp(winSize.width / 2 + 80, 100);
        } else {
            shareItem.position = ccp(winSize.width / 2 - 80, 100);
            infoItem.position = ccp(winSize.width / 2, 100);
            nextItem.position = ccp(winSize.width / 2 + 80, 100);
        }
        
        _menu = [CCMenu menuWithItems:shareItem, infoItem, nextItem, nil];
        [self addChild:_menu z:ZORDER_NAV_BAR];
        _menu.position = ccp(0, 0);
        
        
        //加一个UIViewController
//        _controller = [[RootViewController alloc] init];
//        _controller.view.frame = CGRectMake(0,0,winSize.width,winSize.height);
//        [[[CCDirector sharedDirector] openGLView]addSubview : _controller.view];
//        
//        [self addAdMob];
        
        
    }
    return self;
}

- (void)registerWithTouchDispatcher {
    //touch is enabled
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
}

- (void)showScoreDetailWithSingle:(int)singleP withDouble:(int)doubleP {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    ccColor3B LabelColor = ccc3(255 - _layerColor.r, 255 - _layerColor.g, 255 - _layerColor.b);
    
    
    //显示分数详情
    CCSprite *singlePoint = [CCSprite spriteWithSpriteFrameName:@"Block.png"];
    CCLabelTTF *singleLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"x%d=%d", singleP, singleP] fontName:FONTNAME_OF_TEXT fontSize:[GPNavBar isiPad] ? 30 : 15];
    singleLabel.color = LabelColor;
    singleLabel.anchorPoint = ccp(0, 0.5);
    
    CCSprite *doublePoint = [CCSprite spriteWithSpriteFrameName:@"Block_HL0.png"];
    CCLabelTTF *doubleLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"x%d=%d", doubleP, 2*doubleP] fontName:FONTNAME_OF_TEXT fontSize:[GPNavBar isiPad] ? 30 : 15];
    doubleLabel.color = LabelColor;
    doubleLabel.anchorPoint = ccp(0, 0.5);
    
    CGPoint singlePPos, singleLPos, doublePPos, doubleLPos;
    CGFloat centerX = winSize.width / 2;
    CGFloat heightY;
    if ([GPNavBar isiPad]) {
        heightY = winSize.height - 110;
        singlePPos = ccp(centerX - 110, heightY);
        singleLPos = ccp(centerX - 89, heightY);
        doublePPos = ccp(centerX + 40, heightY);
        doubleLPos = ccp(centerX + 62, heightY);
        
        singlePoint.scale = 0.3;
        doublePoint.scale = 0.3;
        
    } else if ([GPNavBar isiPhone5]) {
        heightY = winSize.height - 68;
        singlePPos = ccp(centerX - 60, heightY);
        singleLPos = ccp(centerX - 46, heightY);
        doublePPos = ccp(centerX + 20, heightY);
        doubleLPos = ccp(centerX + 34, heightY);
        
        singlePoint.scale = 0.4;
        doublePoint.scale = 0.4;
    } else {
        heightY = winSize.height - 58;
        singlePPos = ccp(centerX - 60, heightY);
        singleLPos = ccp(centerX - 46, heightY);
        doublePPos = ccp(centerX + 20, heightY);
        doubleLPos = ccp(centerX + 34, heightY);
        
        singlePoint.scale = 0.4;
        doublePoint.scale = 0.4;
    }
    
    
    singlePoint.position = singlePPos;
    singleLabel.position = singleLPos;
    [self addChild:singlePoint z:ZORDER_SUCCESS_LAYER+1];
    [self addChild:singleLabel z:ZORDER_SUCCESS_LAYER+1];
    
    
    doublePoint.position = doublePPos;
    doubleLabel.position = doubleLPos;
    [self addChild:doublePoint z:ZORDER_SUCCESS_LAYER+1];
    [self addChild:doubleLabel z:ZORDER_SUCCESS_LAYER+1];
    
}

- (void)setPositionLabel:(NSString *)posString {
    [_posLabel setString:posString];
}

- (void)setCurrentPuzzleInfo:(NSString *)info {
    self.curInfo = info;
}

- (void)setSuccessLayerColorWithImgName:(NSString *)imgName {
    
    //方法一：计算图片颜色
    /*
    NSString *path = [ZZAcquirePath getBundleDirectoryWithFileName:imgName];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
     */
    
    //方法二：解密图片
    UIImage *img = nil;
    
    
    if (IS_DECRYPT_PICTRUE) {
        NSData *data = [GPNavBar func_decodeFile:imgName];
        //    UIImage *img = [UIImage imageWithData:data];
        img = [[UIImage alloc] initWithData:data];
    } else {
        img = [UIImage imageNamed:imgName];
    }
    
    
    //方法三：计算图片颜色，从数据库中取得
    /*
    GPDatabase *gpdb = [[GPDatabase alloc] init];
    [gpdb openBundleDatabaseWithName:NAME_OF_DATABASE];
    NSString *picNamePrefix = [imgName stringByDeletingPathExtension];
    NSData *picData = [gpdb LoadPictrueDataByName:picNamePrefix];
    [gpdb close];
    [gpdb release];
    UIImage *img = [UIImage imageWithData:picData];
    */
    
    ccColor4B color = [img mostColor];
    _layerColor = color;
    [img release];
    
    CCLayerColor *successColor = [CCLayerColor layerWithColor:color];
    successColor.opacity = 0.0f;
    
    
    [self addChild:successColor z:ZORDER_SUCCESS_LAYER];
    
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.3];
    [successColor runAction:fadeIn];
}


+(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

/*
#pragma mark-
#pragma mark admob
- (void)addAdMob {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //    //判断网络状态
    //	NetworkStatus NetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    //    //没有网的情况
    //	if (NetStatus == NotReachable) return;
    
    //有网络的情况下加载广告条
    if ([GPNavBar isiPad]) {
        _adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    } else {
        _adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    }
    
    _adView.rootViewController = _controller;
//    _adView.delegate = self;
    _adView.adUnitID = ADMOB_ID;
    
    //设置广告条的位置
    CGPoint point = CGPointMake(winSize.width / 2, winSize.height - _adView.frame.size.height / 2);
    _adView.center = point;
    
    [_adView loadRequest:[GADRequest request]];
    
    [_controller.view addSubview:_adView];
    
    
//    //在广告条没有加载出来之前，显示自己的广告条
//    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OfflineAds01.png"]] autorelease];
//    CGRect imgFrame = imgView.frame;
//    imgFrame.origin = CGPointMake(0, self.mainTableView.frame.origin.y + self.mainTableView.frame.size.height + height);
//    [imgView setFrame:imgFrame];
//    [self.view insertSubview:imgView belowSubview:self.mainTableView];
//    imgView.tag = TAG_OFFLINE_ADBANNER;
    
    
    
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    
    //先删除本地广告条
//    UIImageView *imgView = (UIImageView *)[self.view viewWithTag:TAG_OFFLINE_ADBANNER];
//    if (imgView) {
//        [imgView removeFromSuperview];
//    }
//    
//    [self.view insertSubview:view belowSubview:self.mainTableView];
}
*/
#pragma mark-
#pragma mark Button Pressed

- (void)shareToSocial {
    [[[GuessScene sharedGuessScene] navBar] showShareBoradWithType:ShareTypeShare];
}

- (void)popInformation {
    [GPNavBar playBtnPressedEffect];
    InformationBorad *infoLayer = [InformationBorad nodeWithInformation:self.curInfo parentView:[[[GuessScene sharedGuessScene] controller] view]];
    [[[GuessScene sharedGuessScene] navBar] addChild:infoLayer];
    
    infoLayer.scale = 0;
    CCScaleTo *scaleToBig = [CCScaleTo actionWithDuration:0.2 scale:1];
    CCSequence *smallToBig = [CCSequence actions:scaleToBig, nil];
    [infoLayer runAction:smallToBig];
}

- (void)nextPicture {
    [GPNavBar playBtnPressedEffect];
    
    NSInteger nextLevelNum = [[GuessScene sharedGuessScene] nextPuzzleIndex];
    NSInteger numOfPuzzles = [GPNavBar numOfPuzzlesAtCurrentVersion];
    if (nextLevelNum >= numOfPuzzles) {
        //本版本已经通关，跳出成就界面，并且记录下continueLevel
        [GPNavBar setContinueLevel:nextLevelNum isNeedRestoreScene:NO];
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:[TrophyLayer scene]]];
    } else {
        [[GuessScene sharedGuessScene] changeToNextPuzzle];
    }
    
}




@end
