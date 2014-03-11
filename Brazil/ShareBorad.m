//
//  ShareBorad.m
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-11.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "ShareBorad.h"
#import <ShareSDK/ShareSDK.h>
#import "ZZAcquirePath.h"

#define CONTENT NSLocalizedString(@"我正在玩电影海报猜猜猜，遇到了一个难猜的海报，快来帮我看看是什么电影啊。详情见官网http://sharesdk.cn @TAD", @"分享内容")

//所有的位置坐标
typedef struct ItemSharePostion {
    
    CGPoint ItemShareWeixin;
    CGPoint ItemSharePYQ;
    CGPoint ItemShareQQ;
    CGPoint ItemShareQQWeiBo;
    CGPoint ItemShareQQZone;
    CGPoint ItemShareSinaWeiBo;
    CGPoint ItemShareRenRen;
    CGPoint ItemShareDouban;
    
    CGPoint ItemClose;
    CGPoint ItemBackground;
}ItemSharePostionSet;

@interface ShareBorad() {
    ItemSharePostionSet _ISPSet;
    CCMenu *_menu;
}

@end


@implementation ShareBorad

- (void)dealloc {
    
    CCLOG(@"ShareBorad is dealloc");
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:[AssetHelper getDeviceSpecificFileNameFor:@"Share.plist"]];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        self.isTouchEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 100)];
        [self addChild:color z:0];
        
        //加载帧到缓存
        CCSpriteFrameCache *framCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [framCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"Share.plist"]];
        
        //设置初始位置
        [self setItemInitalPostion];
        
        CCSprite *backgroud = [CCSprite spriteWithSpriteFrameName:@"shareBanner.png"];
        [self addChild:backgroud z:0];
        CGFloat scaleX = winSize.width / backgroud.boundingBox.size.width;
        CGFloat scaleY = ([GPNavBar isiPad] ? backgroud.boundingBox.size.height : 120.0f) / backgroud.boundingBox.size.height;
        [backgroud setScaleX:scaleX];
        [backgroud setScaleY:scaleY];
        backgroud.position = ccp(winSize.width / 2, backgroud.boundingBox.size.height / 2);
        
        CCSprite *closeSprite = [CCSprite spriteWithSpriteFrameName:@"close.png"];
        CCSprite *closeHLSprite = [CCSprite spriteWithSpriteFrameName:@"close_HL.png"];
        CCMenuItem *closeItem = [CCMenuItemImage itemFromNormalSprite:closeSprite selectedSprite:closeHLSprite target:self selector:@selector(closeShareBorad)];
        closeItem.anchorPoint = ccp(1, 0);
        closeItem.position = ccp(winSize.width / 2 + backgroud.boundingBox.size.width / 2, /*winSize.height / 2 + backgroud.boundingBox.size.height / 2*/0);
        
        NSArray *selectorNameArray = [NSArray arrayWithObjects:@"shareToQQ", @"shareToQQZone", @"shareToQQWeibo", @"shareToWeiXin", @"shareToPYQ", @"shareToRenRen", @"shareToSinaWeiBo", @"shareToDouban", nil];
        
        NSArray *frameNameArray = [NSArray arrayWithObjects:@"share_qq", @"share_qqzone", @"share_qqweibo", @"share_weixin", @"share_pyq", @"share_renren", @"share_weibo", @"share_douban", nil];
        
        NSArray *pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:_ISPSet.ItemShareQQ], [NSValue valueWithCGPoint:_ISPSet.ItemShareQQZone], [NSValue valueWithCGPoint:_ISPSet.ItemShareQQWeiBo], [NSValue valueWithCGPoint:_ISPSet.ItemShareWeixin], [NSValue valueWithCGPoint:_ISPSet.ItemSharePYQ], [NSValue valueWithCGPoint:_ISPSet.ItemShareRenRen], [NSValue valueWithCGPoint:_ISPSet.ItemShareSinaWeiBo], [NSValue valueWithCGPoint:_ISPSet.ItemShareDouban], nil];
        
        CCArray *menuArray = [CCArray array];
        
        int count = [frameNameArray count];
        for (int i = 0; i < count; i++) {
            NSString *frameName = [frameNameArray objectAtIndex:i];
            NSString *itemName = [NSString stringWithFormat:@"%@.png", frameName];
            NSString *itemNameHL = [NSString stringWithFormat:@"%@_HL.png", frameName];
            
            CCSprite *item = [CCSprite spriteWithSpriteFrame:[framCache spriteFrameByName:itemName]];
            CCSprite *itemHL = [CCSprite spriteWithSpriteFrame:[framCache spriteFrameByName:itemNameHL]];
            
            NSString *selectorName = [selectorNameArray objectAtIndex:i];
            SEL shareToSocial = NSSelectorFromString(selectorName);
            
            CCMenuItem *shareItem = [CCMenuItemImage itemFromNormalSprite:item selectedSprite:itemHL target:self selector:shareToSocial];
            
            NSValue *positionValue = [pointArray objectAtIndex:i];
            CGPoint point = [positionValue CGPointValue];
            shareItem.position = point;
            shareItem.anchorPoint = ccp(0, 1);
            
            [menuArray addObject:shareItem];
            
        }
        
        _menu = [CCMenu menuWithItems:[menuArray objectAtIndex:0], [menuArray objectAtIndex:1], [menuArray objectAtIndex:2], [menuArray objectAtIndex:3], [menuArray objectAtIndex:4], [menuArray objectAtIndex:5], [menuArray objectAtIndex:6], [menuArray objectAtIndex:7], closeItem, nil];
        _menu.position = ccp(0, 0);
        [self addChild:_menu];
        
    }
    return self;
}

- (void)setItemInitalPostion {
    CGFloat spaceX, spaceY, width;
    if ([GPNavBar isiPad]) {
        spaceX = 15.0f;
        spaceY = 20.0f;
        width = 80.0f;
        
        _ISPSet.ItemSharePYQ        = ccp(0, 0);
        _ISPSet.ItemShareWeixin     = ccp(0, 0);
        _ISPSet.ItemShareSinaWeiBo  = ccp(0, 0);
        _ISPSet.ItemShareQQ         = ccp(0, 0);
        _ISPSet.ItemShareQQZone     = ccp(0, 0);
        _ISPSet.ItemShareQQWeiBo    = ccp(0, 0);
        _ISPSet.ItemShareRenRen     = ccp(0, 0);
        _ISPSet.ItemShareDouban     = ccp(0, 0);
        
        _ISPSet.ItemClose           = ccp(0, 0);
    } else if ([GPNavBar isiPhone5]) {
        spaceX = 5.0f;
        spaceY = 4.0f;
        width = 40.0f;
        
        _ISPSet.ItemSharePYQ        = ccp(0, 0);
        _ISPSet.ItemShareWeixin     = ccp(0, 0);
        _ISPSet.ItemShareSinaWeiBo  = ccp(0, 0);
        _ISPSet.ItemShareQQ         = ccp(0, 0);
        _ISPSet.ItemShareQQZone     = ccp(0, 0);
        _ISPSet.ItemShareQQWeiBo    = ccp(0, 0);
        _ISPSet.ItemShareRenRen     = ccp(0, 0);
        _ISPSet.ItemShareDouban     = ccp(0, 0);
        
        _ISPSet.ItemClose           = ccp(0, 0);
    } else {
        spaceX = 15.0f;
        spaceY = 15.0f;
        width = 40.0f;
        
        _ISPSet.ItemSharePYQ        = ccp(spaceX,               spaceY*2 + width*2);
        _ISPSet.ItemShareWeixin     = ccp(spaceX*2 + width,     spaceY*2 + width*2);
        _ISPSet.ItemShareSinaWeiBo  = ccp(spaceX*3 + width*2,   spaceY*2 + width*2);
        _ISPSet.ItemShareQQ         = ccp(spaceX*4 + width*3,   spaceY*2 + width*2);
        _ISPSet.ItemShareQQZone     = ccp(spaceX,               width+spaceY);
        _ISPSet.ItemShareQQWeiBo    = ccp(spaceX*2 + width,     width+spaceY);
        _ISPSet.ItemShareRenRen     = ccp(spaceX*3 + width*2,   width+spaceY);
        _ISPSet.ItemShareDouban     = ccp(spaceX*4 + width*3,   width+spaceY);
        
        _ISPSet.ItemClose           = ccp(0, 0);
    }
    
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
}

+ (CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [ShareBorad locationFromTouch:touch];
    BOOL isTouchHandled = YES;
    for (CCMenuItem *item in _menu.children) {
        if (CGRectContainsPoint(item.boundingBox, point)) {
            isTouchHandled = NO;
        }
    }
    
    return isTouchHandled;
}

- (void)closeShareBorad {
    GPNavBar *navBar = (GPNavBar *)[self parent];
    [navBar showShareBorad];
}

- (void)shareToQQ {
    [self shareWithShareType:ShareTypeQQ];
}

- (void)shareToQQZone {
    [self shareWithShareType:ShareTypeQQSpace];
}

- (void)shareToQQWeibo {
    [self shareWithShareType:ShareTypeTencentWeibo];
}

- (void)shareToWeiXin {
    [self shareWithShareType:ShareTypeWeixiSession];
}

- (void)shareToPYQ {
    [self shareWithShareType:ShareTypeWeixiTimeline];
}

- (void)shareToRenRen {
    [self shareWithShareType:ShareTypeRenren];
}

- (void)shareToSinaWeiBo {
    [self shareWithShareType:ShareTypeSinaWeibo];
}

- (void)shareToDouban {
    [self shareWithShareType:ShareTypeDouBan];
}

- (void)shareWithShareType:(ShareType)type {
    NSString *imagePath = [ZZAcquirePath getDocDirectoryWithFileName:@"sharePic.png"];
    
    id<ISSContent> publishContent = [ShareSDK content:CONTENT defaultContent:@"" image:[ShareSDK imageWithPath:imagePath] title:nil url:nil description:nil mediaType:SSPublishContentMediaTypeText];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:type
                          container:nil
                            content:publishContent
                      statusBarTips:NO
                        authOptions:nil
                       shareOptions:nil
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                     CCLOG(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
}


@end
