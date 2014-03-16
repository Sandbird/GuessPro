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

@interface SuccessLayer() {

    CCSprite *_nextSprite;
    
    BOOL _isBeginTouched;
    
    CCLayerColor *_successColor;
    
    CCLabelTTF *_posLabel;
    
    CCMenu *_menu;
}

@property (nonatomic, retain) GADBannerView *adView;
@property (nonatomic, retain) RootViewController *controller;
@property (nonatomic, retain) NSString *curInfo;

@end

@implementation SuccessLayer

- (void)dealloc {
    NSLog(@"Success release");
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
//        _isBeginTouched = NO;
        
//        self.isTouchEnabled = YES;
        
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
        _controller = [[RootViewController alloc] init];
        _controller.view.frame = CGRectMake(0,0,winSize.width,winSize.height);
        [[[CCDirector sharedDirector] openGLView]addSubview : _controller.view];
        
//        [self addAdMob];
        
        
    }
    return self;
}

- (void)registerWithTouchDispatcher {
    //touch is enabled
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
}

- (void)setPositionLabel:(NSString *)posString {
    [_posLabel setString:posString];
}

- (void)setCurrentPuzzleInfo:(NSString *)info {
    self.curInfo = info;
}

- (void)setSuccessLayerColorWithImgName:(NSString *)imgName {
    
    NSString *path = [ZZAcquirePath getBundleDirectoryWithFileName:imgName];
    //计算图片颜色
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    ccColor4B color = [img mostColor];
    [img release];
    
//    [_successColor setColor:color];
    
    CCLayerColor *successColor = [CCLayerColor layerWithColor:color];
    [self addChild:successColor z:ZORDER_SUCCESS_LAYER];
}


+(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}


#pragma mark-
#pragma mark admob
- (void)addAdMob {
    
//    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
//    RootViewController *controller;
    
    //    //判断网络状态
    //	NetworkStatus NetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    //    //没有网的情况
    //	if (NetStatus == NotReachable) return;
    
    //有网络的情况下加载广告条
    if ([GPNavBar isiPad]) {
        _adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    } else {
        _adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
    }
    
    
    
//    _controller = (RootViewController *)[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController];
    
    _adView.rootViewController = _controller;
    
    _adView.adUnitID = ADMOB_ID;
    
    CGFloat height = 0;
    if ([GPNavBar isiPad]) {
        height = 0;
    } else if ([GPNavBar isiPhone5]) {
        height = 88;
    } else {
        height = 0;
    }
    
    //设置tableView的高度
    CGRect frame = self.boundingBox;
    frame.size.height -= self.adView.frame.size.height;
//    [self.mainTableView setFrame:frame];
    
    //设置广告条的位置
    CGPoint point = CGPointMake(160, 160);
    _adView.center = point;
//    _adView.delegate = self;
    //    [self.view insertSubview:_adView belowSubview:self.mainTableView];
    [_adView loadRequest:[GADRequest request]];
    
    [_controller.view addSubview:_adView];
//    [[[CCDirector sharedDirector] openGLView]addSubview : _controller.view];

    
    
    /**
     *Remove
     *[bannerView release];
     *[controller.view removeFromSuperview];
     *[controller release];
     */
    
    
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

#pragma mark-
#pragma mark Button Pressed

- (void)shareToSocial {
    [[[GuessScene sharedGuessScene] navBar] showShareBoradWithType:ShareTypeShare];
}

- (void)popInformation {
    InformationBorad *infoLayer = [InformationBorad nodeWithInformation:self.curInfo parentView:_controller.view];
    [[[GuessScene sharedGuessScene] navBar] addChild:infoLayer];
    
    infoLayer.scale = 0;
    CCScaleTo *scaleToBig = [CCScaleTo actionWithDuration:0.2 scale:1];
    CCSequence *smallToBig = [CCSequence actions:scaleToBig, nil];
    [infoLayer runAction:smallToBig];
}

- (void)nextPicture {
    [[GuessScene sharedGuessScene] changeToNextPuzzle];
}




@end
