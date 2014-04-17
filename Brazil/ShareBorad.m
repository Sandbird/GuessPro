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
    
    CGPoint ItemLabelWeixin;
    CGPoint ItemLabelPYQ;
    CGPoint ItemLabelSinaWeiBo;
    CGPoint ItemLabelQQWeiBo;
    
    CGPoint ItemClose;
    CGPoint ItemBackground;
}ItemSharePostionSet;

@interface ShareBorad() {
    ItemSharePostionSet _ISPSet;
    CCMenu *_menu;
}

@property (assign)ShareBoradShareType SBStype;

@end


@implementation ShareBorad

- (void)dealloc {
    
    CCLOG(@"ShareBorad is dealloc");
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:[AssetHelper getDeviceSpecificFileNameFor:@"Share.plist"]];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [super dealloc];
}

- (id)initWithShareType:(ShareBoradShareType)SBSType {
    self = [super init];
    if (self) {
        
        self.SBStype = SBSType;
        
        self.isTouchEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
        [self addChild:color z:0];
        
        //加载帧到缓存
        CCSpriteFrameCache *framCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [framCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"Share.plist"]];
        
        //设置初始位置
        [self setItemInitalPostion];
        
        CGFloat posY;
        CGSize wordSize;
        CGFloat labelFontSize;
        if ([GPNavBar isiPad]) {
            posY = winSize.height - 88.0f;
            wordSize = CGSizeMake(600, 200);
            labelFontSize = 30;
        } else if ([GPNavBar isiPhone5]) {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(250, 100);
            labelFontSize = 13;
        } else {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(250, 100);
            labelFontSize = 13;
        }
        
        NSString *title = @"";
        NSString *text = @"";
        NSTextAlignment TA;
        if (self.SBStype == ShareTypeSOS) {
            title = NSLocalizedString(@"TITLE_HELP", @"求助");
            text = NSLocalizedString(@"HELP_INTRO", @"求助内容");
            TA = NSTextAlignmentLeft;
        } else if (self.SBStype == ShareTypeShare) {
            title = NSLocalizedString(@"TITLE_SHARE", @"分享");
            text = NSLocalizedString(@"SHARE_INTRO", @"分享内容");
            TA = NSTextAlignmentCenter;
        }
        
        CCLabelTTF *labelTitle = [CCLabelTTF labelWithString:title fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TITLE];
        labelTitle.color = ccWHITE;
        labelTitle.anchorPoint = ccp(0.5, 0.5);
        labelTitle.position = ccp(winSize.width / 2, posY);
        [self addChild:labelTitle];
        
        CCLabelTTF *labelWords = [CCLabelTTF labelWithString:text dimensions:wordSize alignment:TA vertAlignment:CCVerticalAlignmentTop lineBreakMode:NSLineBreakByCharWrapping fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TEXT];
        labelWords.color = ccWHITE;
        labelWords.anchorPoint = ccp(0.5, 1);
        labelWords.position = ccp(winSize.width / 2,  posY - labelTitle.boundingBox.size.height);
        [self addChild:labelWords];
        
        CCSprite *closeSprite = [CCSprite spriteWithSpriteFrameName:@"close.png"];
        CCSprite *closeHLSprite = [CCSprite spriteWithSpriteFrameName:@"close_HL.png"];
        CCMenuItem *closeItem = [CCMenuItemImage itemFromNormalSprite:closeSprite selectedSprite:closeHLSprite target:self selector:@selector(closeShareBorad)];
        closeItem.anchorPoint = ccp(0.5, 0.5);
        closeItem.position = ccp(winSize.width / 2, HEIGHT_OF_CLOSE_ITEM);
        
        NSArray *selectorNameArray = [NSArray arrayWithObjects:/*@"shareToQQ", @"shareToQQZone",*/ @"shareToQQWeibo", @"shareToWeiXin", @"shareToPYQ", /*@"shareToRenRen",*/ @"shareToSinaWeiBo", /*@"shareToDouban",*/ nil];
        
        NSArray *frameNameArray = [NSArray arrayWithObjects:/*@"share_qq", @"share_qqzone",*/ @"share_qqweibo", @"share_weixin", @"share_pyq", /*@"share_renren",*/ @"share_weibo", /*@"share_douban",*/ nil];
        
        NSArray *pointArray = [NSArray arrayWithObjects:/*[NSValue valueWithCGPoint:_ISPSet.ItemShareQQ], [NSValue valueWithCGPoint:_ISPSet.ItemShareQQZone], */[NSValue valueWithCGPoint:_ISPSet.ItemShareQQWeiBo], [NSValue valueWithCGPoint:_ISPSet.ItemShareWeixin], [NSValue valueWithCGPoint:_ISPSet.ItemSharePYQ], /*[NSValue valueWithCGPoint:_ISPSet.ItemShareRenRen],*/ [NSValue valueWithCGPoint:_ISPSet.ItemShareSinaWeiBo], /*[NSValue valueWithCGPoint:_ISPSet.ItemShareDouban],*/ nil];
        
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
        
        _menu = [CCMenu menuWithItems:[menuArray objectAtIndex:0], [menuArray objectAtIndex:1], [menuArray objectAtIndex:2], [menuArray objectAtIndex:3], /*[menuArray objectAtIndex:4], [menuArray objectAtIndex:5], [menuArray objectAtIndex:6], [menuArray objectAtIndex:7], */closeItem, nil];
        _menu.position = ccp(0, 0);
        [self addChild:_menu];
        
        NSArray *labelNameArray = [NSArray arrayWithObjects:@"朋友圈", @"微信好友", @"新浪微博", @"腾讯微博", nil];
        
        NSArray *labelPointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:_ISPSet.ItemLabelPYQ], [NSValue valueWithCGPoint:_ISPSet.ItemLabelWeixin], [NSValue valueWithCGPoint:_ISPSet.ItemLabelSinaWeiBo], [NSValue valueWithCGPoint:_ISPSet.ItemLabelQQWeiBo], nil];
        
        int labelCount = [labelNameArray count];
        for (int i = 0; i < labelCount; i++) {
            NSString *labelName = [labelNameArray objectAtIndex:i];
            
            CCLabelTTF *label = [CCLabelTTF labelWithString:labelName fontName:FONTNAME_OF_TEXT fontSize:labelFontSize];
            
            NSValue *positionValue = [labelPointArray objectAtIndex:i];
            CGPoint point = [positionValue CGPointValue];
            label.position = point;
            label.anchorPoint = ccp(0, 1);
            
            [self addChild:label];
            
        }
        
    }
    return self;
}

- (void)setItemInitalPostion {
    CGFloat spaceX, spaceY, width, posX, posY, deltaY, deltaX;
    if ([GPNavBar isiPad]) {
        spaceX = 80.0f;
        spaceY = 80.0f;
        width = 80.0f;
        posX = 25;
        posY = 270;
        deltaY = -90.0f;
        deltaX = -20.0f;
        
        
        _ISPSet.ItemSharePYQ        = ccp(posX + spaceX,               spaceY*2 + width*2 + posY);
        _ISPSet.ItemShareWeixin     = ccp(posX + spaceX*2 + width,     spaceY*2 + width*2 + posY);
        _ISPSet.ItemShareSinaWeiBo  = ccp(posX + spaceX*3 + width*2,   spaceY*2 + width*2 + posY);
        _ISPSet.ItemShareQQWeiBo    = ccp(posX + spaceX*4 + width*3,   spaceY*2 + width*2 + posY);
        
//        _ISPSet.ItemShareQQ         = ccp(posX + spaceX*4 + width*3,   spaceY*2 + width*2 + posY);
//        _ISPSet.ItemShareQQZone     = ccp(posX + spaceX,               width+spaceY + posY);
//        _ISPSet.ItemShareRenRen     = ccp(posX + spaceX*2 + width,      width+spaceY + posY);
//        _ISPSet.ItemShareDouban     = ccp(posX + spaceX*3 + width*2,    width+spaceY + posY);
//        posX + spaceX*4 + width*3
        
        _ISPSet.ItemLabelPYQ = ccp(_ISPSet.ItemSharePYQ.x+deltaX+13, _ISPSet.ItemSharePYQ.y+deltaY);
        _ISPSet.ItemLabelWeixin = ccp(_ISPSet.ItemShareWeixin.x+deltaX, _ISPSet.ItemShareWeixin.y+deltaY);
        _ISPSet.ItemLabelSinaWeiBo = ccp(_ISPSet.ItemShareSinaWeiBo.x+deltaX, _ISPSet.ItemShareSinaWeiBo.y+deltaY);
        _ISPSet.ItemLabelQQWeiBo = ccp(_ISPSet.ItemShareQQWeiBo.x+deltaX, _ISPSet.ItemShareQQWeiBo.y+deltaY);
        
        _ISPSet.ItemClose           = ccp(0, 0);
    } else if ([GPNavBar isiPhone5]) {
        spaceX = 30.0f;
        spaceY = 25.0f;
        width = 40.0f;
        posX = 5;
        posY = 200;
        deltaY = -50.0f;
        deltaX = -8.0f;
        
        _ISPSet.ItemSharePYQ        = ccp(posX + spaceX,               spaceY*2 + width*2 + posY);
        _ISPSet.ItemShareWeixin     = ccp(posX + spaceX*2 + width,     spaceY*2 + width*2 + posY);
        _ISPSet.ItemShareSinaWeiBo  = ccp(posX + spaceX*3 + width*2,   spaceY*2 + width*2 + posY);
        _ISPSet.ItemShareQQWeiBo    = ccp(posX + spaceX*4 + width*3,   spaceY*2 + width*2 + posY);
        
//        _ISPSet.ItemShareQQ         = ccp(posX + spaceX*4 + width*3,   spaceY*2 + width*2 + posY);
//        _ISPSet.ItemShareQQZone     = ccp(posX + spaceX,               width+spaceY + posY);
//        _ISPSet.ItemShareRenRen     = ccp(posX + spaceX*2 + width,      width+spaceY + posY);
//        _ISPSet.ItemShareDouban     = ccp(posX + spaceX*3 + width*2,    width+spaceY + posY);
//        posX + spaceX*4 + width*3
        
        _ISPSet.ItemLabelPYQ = ccp(_ISPSet.ItemSharePYQ.x, _ISPSet.ItemSharePYQ.y+deltaY);
        _ISPSet.ItemLabelWeixin = ccp(_ISPSet.ItemShareWeixin.x+deltaX, _ISPSet.ItemShareWeixin.y+deltaY);
        _ISPSet.ItemLabelSinaWeiBo = ccp(_ISPSet.ItemShareSinaWeiBo.x+deltaX, _ISPSet.ItemShareSinaWeiBo.y+deltaY);
        _ISPSet.ItemLabelQQWeiBo = ccp(_ISPSet.ItemShareQQWeiBo.x+deltaX, _ISPSet.ItemShareQQWeiBo.y+deltaY);
        
        _ISPSet.ItemClose           = ccp(0, 0);
    } else {
        spaceX = 30.0f;
        spaceY = 30.0f;
        width = 40.0f;
        posX = 5;
        posY = 130;
        deltaY = -50.0f;
        deltaX = -8.0f;
        
        _ISPSet.ItemSharePYQ        = ccp(posX + spaceX,               spaceY*2 + width*2 + posY);
        _ISPSet.ItemShareWeixin     = ccp(posX + spaceX*2 + width,     spaceY*2 + width*2 + posY);
        _ISPSet.ItemShareSinaWeiBo  = ccp(posX + spaceX*3 + width*2,   spaceY*2 + width*2 + posY);
        _ISPSet.ItemShareQQWeiBo    = ccp(posX + spaceX*4 + width*3,   spaceY*2 + width*2 + posY);
        
        _ISPSet.ItemLabelPYQ = ccp(_ISPSet.ItemSharePYQ.x, _ISPSet.ItemSharePYQ.y+deltaY);
        _ISPSet.ItemLabelWeixin = ccp(_ISPSet.ItemShareWeixin.x+deltaX, _ISPSet.ItemShareWeixin.y+deltaY);
        _ISPSet.ItemLabelSinaWeiBo = ccp(_ISPSet.ItemShareSinaWeiBo.x+deltaX, _ISPSet.ItemShareSinaWeiBo.y+deltaY);
        _ISPSet.ItemLabelQQWeiBo = ccp(_ISPSet.ItemShareQQWeiBo.x+deltaX, _ISPSet.ItemShareQQWeiBo.y+deltaY);
        
//        _ISPSet.ItemShareQQ         = ccp(posX + spaceX*4 + width*3,   spaceY*2 + width*2 + posY);
//        _ISPSet.ItemShareQQZone     = ccp(posX + spaceX,               width+spaceY + posY);
//        _ISPSet.ItemShareRenRen     = ccp(posX + spaceX*2 + width,      width+spaceY + posY);
//        _ISPSet.ItemShareDouban     = ccp(posX + spaceX*3 + width*2,    width+spaceY + posY);
//        posX + spaceX*4 + width*3
        
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
    [navBar showShareBoradWithType:ShareTypeNONE];
}

- (void)shareToQQ {
    [self shareWithShareType:ShareTypeQQ mediaType:SSPublishContentMediaTypeImage];
}

- (void)shareToQQZone {
    [self shareWithShareType:ShareTypeQQSpace mediaType:SSPublishContentMediaTypeImage];
}

- (void)shareToQQWeibo {
    [self shareWithShareType:ShareTypeTencentWeibo mediaType:SSPublishContentMediaTypeText];
}

- (void)shareToWeiXin {
    if (self.SBStype == ShareTypeSOS) {
        [self shareWithShareType:ShareTypeWeixiSession mediaType:SSPublishContentMediaTypeImage];
    } else {
        [self shareWithShareType:ShareTypeWeixiSession mediaType:SSPublishContentMediaTypeApp];
    }
    
}

- (void)shareToPYQ {
    if (self.SBStype == ShareTypeSOS) {
        [self shareWithShareType:ShareTypeWeixiTimeline mediaType:SSPublishContentMediaTypeImage];
    } else {
        [self shareWithShareType:ShareTypeWeixiTimeline mediaType:SSPublishContentMediaTypeApp];
    }
}

- (void)shareToRenRen {
    [self shareWithShareType:ShareTypeRenren mediaType:SSPublishContentMediaTypeText];
}

- (void)shareToSinaWeiBo {
    [self shareWithShareType:ShareTypeSinaWeibo mediaType:SSPublishContentMediaTypeText];
}

- (void)shareToDouban {
    [self shareWithShareType:ShareTypeDouBan mediaType:SSPublishContentMediaTypeText];
}

- (void)shareWithShareType:(ShareType)type mediaType:(SSPublishContentMediaType *)mediaType {
    [GPNavBar playBtnPressedEffect];
    
    NSString *imagePath = nil;
    NSString *content = nil;
    NSString *title = NSLocalizedString(@"TITLE_APP_NAME", nil);
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", APP_ID];
    NSString *urlStore = [NSString stringWithFormat:@"itunes.apple.com/app/id%@", APP_ID];
    
    if (self.SBStype == ShareTypeSOS) {
        imagePath = [ZZAcquirePath getDocDirectoryWithFileName:@"sharePic.png"];
        content = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"HELP_CONTENT", nil), url];
        
    } else if (self.SBStype == ShareTypeShare) {
        imagePath = [ZZAcquirePath getBundleDirectoryWithFileName:@"Icon@2x.png"];
        content = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"SHARE_CONTENT", nil), url];


    }
    
    id<ISSContent> publishContent = [ShareSDK content:content
                        defaultContent:@""
                                 image:[ShareSDK imageWithPath:imagePath]
                                 title:title
                                   url:urlStore
                           description:nil
                             mediaType:mediaType];
    
    if (self.SBStype == ShareTypeSOS) {
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
                                         CCLOG(@"%@", NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                         
                                         BOOL isAddCoin = [GPNavBar isTodayCanAddCoinWithSOS];
                                         if (isAddCoin) {
                                             GPNavBar *navBar = (GPNavBar *)[self parent];
                                             [navBar changeTotalScore:NUM_OF_ADD_COIN_USING_SOS];
                                             [navBar refreshTotalScore];
                                             
                                             
                                             NSString *msg = [NSString stringWithFormat:@"恭喜获得%d枚金币", NUM_OF_ADD_COIN_USING_SOS];
                                             
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
                                             [alert show];
                                             [alert release];
                                         }
                                         
                                         
                                         
                                     }
                                     else if (state == SSPublishContentStateFail)
                                     {
//                                         CCLOG(@"%@", (NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]));
                                         CCLOG(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                     }
                                 }];
        
    } else if (self.SBStype == ShareTypeShare) {
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
                                         CCLOG(@"%@", NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                         
                                         BOOL isAddCoin = [GPNavBar isTodayCanAddCoinWithShare];
                                         if (isAddCoin) {
                                             GPNavBar *navBar = (GPNavBar *)[self parent];
                                             [navBar changeTotalScore:NUM_OF_ADD_COIN_USING_SHARE];
                                             [navBar refreshTotalScore];
                                             
                                             NSString *msg = [NSString stringWithFormat:@"恭喜获得%d枚金币", NUM_OF_ADD_COIN_USING_SHARE];
                                             
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
                                             [alert show];
                                             [alert release];
                                         }
                                     }
                                     else if (state == SSPublishContentStateFail)
                                     {
                                         CCLOG(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                     }
                                 }];
        
    }
    
    
}


@end
