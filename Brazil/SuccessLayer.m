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

@interface SuccessLayer() {

    CCSprite *_nextSprite;
    
    BOOL _isBeginTouched;
    
    CCLayerColor *_successColor;
    
    CCLabelTTF *_posLabel;
}

@property (nonatomic, retain) GADBannerView *adView;
@property (nonatomic, retain) RootViewController *controller;

@end

@implementation SuccessLayer

- (void)dealloc {
    NSLog(@"Success release");
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        _isBeginTouched = NO;
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //touch is enabled
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-97 swallowsTouches:YES];
        
        _nextSprite = [CCSprite spriteWithSpriteFrameName:@"nextButton.png"];
        _nextSprite.anchorPoint = ccp(0.5, 0.5);
        _nextSprite.position = ccp(size.width / 2, 150);
        [self addChild:_nextSprite z:ZORDER_SUCCESS_LAYER + 1];
        
        CGSize fontSize = CGSizeMake(768, 80);
        _posLabel = [CCLabelTTF labelWithString:@"" dimensions:fontSize alignment:NSTextAlignmentCenter fontName:@"HiraKakuProN-W6" fontSize:50];
        _posLabel.color = ccBLACK;
        _posLabel.anchorPoint = ccp(0.5, 0.5);
        _posLabel.position = ccp(size.width / 2, 240);
        [self addChild:_posLabel z:ZORDER_SUCCESS_LAYER + 3];
        
        
//        _successColor = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
//        [self addChild:_successColor z:ZORDER_SUCCESS_LAYER];
        
        //加NavBar
//        ZZNavBar *navBar = [ZZNavBar node];
//        [self addChild:navBar z:5];
//        [navBar setKayacSceneTag:KayacSceneGuessProTag];
        
        [self addAdMob];
    }
    return self;
}

- (void)setPositionLabel:(NSString *)posString {
    [_posLabel setString:posString];
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

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    _lastTouchLocation = [SuccessLayer locationFromTouch:touch];
    
    _isTouchHandled = YES;
    
    
    if (_isTouchHandled) {
        if (CGRectContainsPoint([_nextSprite boundingBox], _lastTouchLocation)) {
            [_nextSprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.1]];
            _isBeginTouched = YES;
        }
    }
    
    return _isTouchHandled;
    
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [SuccessLayer locationFromTouch:touch];
    
    if (_isTouchHandled && _isBeginTouched) {
        
        if (CGRectContainsPoint(_nextSprite.boundingBox, touchLocation)) {
            [_nextSprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.1]];
        } else {
            [_nextSprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        }
        
        
//        [[GuessScene sharedGuessScene] playBounsAnimation];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [SuccessLayer locationFromTouch:touch];
    
    if (CGRectContainsPoint(_nextSprite.boundingBox, touchLocation) && _isBeginTouched) {
        [_nextSprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        [[GuessScene sharedGuessScene] changeToNextPuzzle];
    }
    
    _isBeginTouched = NO;
}
- (void)onExitTransitionDidStart {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

#pragma mark-
#pragma mark admob
- (void)addAdMob {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
//    RootViewController *controller;
    _controller = [[RootViewController alloc] init];
    _controller.view.frame = CGRectMake(0,0,winSize.width,winSize.height);
    
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
    
    _adView.rootViewController = _controller;
    
//    RootViewController *rootVC = (RootViewController *)[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController];
//    _adView.rootViewController = rootVC;
    
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
    _adView.delegate = self;
    //    [self.view insertSubview:_adView belowSubview:self.mainTableView];
    [_adView loadRequest:[GADRequest request]];
    
    [_controller.view addSubview:_adView];
    [[[CCDirector sharedDirector] openGLView]addSubview : _controller.view];
    
    
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



@end
