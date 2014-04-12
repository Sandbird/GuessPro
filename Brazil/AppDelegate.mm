//
//  AppDelegate.m
//  Brazil
//
//  Created by zhaozilong on 12-11-26.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
//#import "HelloWorldLayer.h"
#import "RootViewController.h"

//#import "FlurryAnalytics.h"
//#import "ChooseBallLayer.h"
//#import "MainScene.h"
#import "StartLayer.h"

#import <ShareSDK/ShareSDK.h>
#import "WeiboApi.h"
//#import <TencentOpenAPI/QQApi.h>
//#import <TencentOpenAPI/QQApiInterface.h>
//#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import <RennSDK/RennClient.h>

#import "Flurry/Flurry.h"

#define FLURRY_ID @"VH6PVWTVZQ6X3BZNZBKQ"
#define SHARESDK_APPID @"15337169bd28"

@implementation AppDelegate

@synthesize window;

//Flurry捕获异常
//void uncaughtExceptionHandler(NSException *exception) {
//	[FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception];
//}

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSLog(@"%f", [[UIScreen mainScreen] bounds].size.height);
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
    //Required in iOS6, recommended in 4 and 5
    [window setRootViewController:viewController];
    
	// make the View Controller a child of the main window, needed for iOS 4 and 5
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
    
    //初始化一些设置
    if ([GPNavBar isFirstTimeInstallApplication]) {
        [GPNavBar setIsEnabledSoundEffect:YES];
        CCLOG(@"默认开启音频");
        
        //第一次装应用，送100金币
        [GPNavBar giveScoreForFirstTimeInstallApp];
        
        //第一次安装，记录关卡数目
        NSInteger num = [GPNavBar numOfPuzzlesAtCurrentVersion];
        [GPNavBar setNumOfPuzzlesAtLastVersion:num];
    }
    
    if ([GPNavBar isEnabledSoundEffect]) {
        CCLOG(@"加载音频");
        [GPNavBar preloadSoundEffect];
    }
	
	// Run the intro Scene
//	[[CCDirector sharedDirector] runWithScene:[GuessScene scene]];
    
    [[CCDirector sharedDirector] runWithScene:[StartLayer scene]];
    
    //FlurryAnalytics:begin receiving basic metric data
//	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
//	[FlurryAnalytics startSession:FLURRY_ID];
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //设置ShareSDK
    [ShareSDK registerApp:SHARESDK_APPID];
    [self initializePlat];
    
    //FlurryAnalytics:begin receiving basic metric data
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[Flurry startSession:FLURRY_ID];
}

//Flurry捕获异常
void uncaughtExceptionHandler(NSException *exception) {
	[Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void)initializePlat
{
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:@"2548419608"
                               appSecret:@"d38f8cfea142e5f4e6ef8c4a2cca7493"
                             redirectUri:@"https://itunes.apple.com/app/id832491981"];
    
    /**
     连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
     http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
     **/
    [ShareSDK connectTencentWeiboWithAppKey:@"801494477"
                                  appSecret:@"7e1b4c01734886876125d96dc4c0f71b"
                                redirectUri:@"https://itunes.apple.com/app/id832491981"
                                   wbApiCls:[WeiboApi class]];
    
    //连接短信分享
//    [ShareSDK connectSMS];
    
    /**
     连接QQ空间应用以使用相关功能，此应用需要引用QZoneConnection.framework
     http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
     **/
//    [ShareSDK connectQZoneWithAppKey:@"100371282"
//                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"
//                   qqApiInterfaceCls:[QQApiInterface class]
//                     tencentOAuthCls:[TencentOAuth class]];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wx253392da3cf9a6c1" wechatCls:[WXApi class]];
    
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
    //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
    
//    [ShareSDK connectQQWithQZoneAppKey:@"100371282"
//                     qqApiInterfaceCls:[QQApiInterface class]
//                       tencentOAuthCls:[TencentOAuth class]];
    
    
    /**
     连接人人网应用以使用相关功能，此应用需要引用RenRenConnection.framework
     http://dev.renren.com上注册人人网开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectRenRenWithAppId:@"266607"
                              appKey:@"c8b7e01a21054d1b933f2c416310ec79"
                           appSecret:@"ec1e8d14b4734cfe9e0f21ab741cfd87"
                   renrenClientClass:[RennClient class]];
    
    
    //连接邮件
//    [ShareSDK connectMail];
    
    
    /**
     连接豆瓣应用以使用相关功能，此应用需要引用DouBanConnection.framework
     http://developers.douban.com上注册豆瓣社区应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectDoubanWithAppKey:@"05cff85093f254c6116fe8f1bbd6fe52"
                            appSecret:@"49e3c438b4c5f8bf"
                          redirectUri:@"https://itunes.apple.com/app/id832491981"];
}



- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

/*
- (void)userInfoUpdateHandler:(NSNotification *)notif
{
    NSMutableArray *authList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
    if (authList == nil)
    {
        authList = [NSMutableArray array];
    }
    
    NSString *platName = nil;
    NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
    switch (plat)
    {
        case ShareTypeSinaWeibo:
            platName = NSLocalizedString(@"TEXT_SINA_WEIBO", @"新浪微博");
            break;
        case ShareType163Weibo:
            platName = NSLocalizedString(@"TEXT_NETEASE_WEIBO", @"网易微博");
            break;
        case ShareTypeDouBan:
            platName = NSLocalizedString(@"TEXT_DOUBAN", @"豆瓣");
            break;
        case ShareTypeFacebook:
            platName = @"Facebook";
            break;
        case ShareTypeKaixin:
            platName = NSLocalizedString(@"TEXT_KAIXIN", @"开心网");
            break;
        case ShareTypeQQSpace:
            platName = NSLocalizedString(@"TEXT_QZONE", @"QQ空间");
            break;
        case ShareTypeRenren:
            platName = NSLocalizedString(@"TEXT_RENREN", @"人人网");
            break;
        case ShareTypeSohuWeibo:
            platName = NSLocalizedString(@"TEXT_SOHO_WEIBO", @"搜狐微博");
            break;
        case ShareTypeTencentWeibo:
            platName = NSLocalizedString(@"TEXT_TENCENT_WEIBO", @"腾讯微博");
            break;
        case ShareTypeTwitter:
            platName = @"Twitter";
            break;
        case ShareTypeInstapaper:
            platName = @"Instapaper";
            break;
        case ShareTypeYouDaoNote:
            platName = NSLocalizedString(@"TEXT_YOUDAO_NOTE", @"有道云笔记");
            break;
        case ShareTypeGooglePlus:
            platName = @"Google+";
            break;
        case ShareTypeLinkedIn:
            platName = @"LinkedIn";
            break;
        default:
            platName = NSLocalizedString(@"TEXT_UNKNOWN", @"未知");
    }
    
    id<ISSPlatformUser> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
    BOOL hasExists = NO;
    for (int i = 0; i < [authList count]; i++)
    {
        NSMutableDictionary *item = [authList objectAtIndex:i];
        ShareType type;//[[item objectForKey:@"type"] integerValue];
        if (type == plat)
        {
            [item setObject:[userInfo nickname] forKey:@"username"];
            hasExists = YES;
            break;
        }
    }
    
    if (!hasExists)
    {
        NSDictionary *newItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 platName,
                                 @"title",
                                 [NSNumber numberWithInteger:plat],
                                 @"type",
                                 [userInfo nickname],
                                 @"username",
                                 nil];
        [authList addObject:newItem];
    }
    
    [authList writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
}
 */


@end
