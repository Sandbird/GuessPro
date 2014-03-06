//
//  CoinStore.m
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-5.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "CoinStore.h"

@interface CoinStore() {
    
}

@end


@implementation CoinStore

- (id)init {
    self = [super init];
    if (self) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        //touch is enabled
//        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-97 swallowsTouches:YES];
        
        //加载帧到缓存
        CCSpriteFrameCache *framCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [framCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"Store.plist"]];
        
        CCSprite *backgroud = [CCSprite spriteWithSpriteFrameName:@"StoreBackgroud.png"];
        [self addChild:backgroud z:0];
        backgroud.position = ccp(winSize.width / 2, winSize.height / 2);
        
        CCSprite *closeSprite = [CCSprite spriteWithSpriteFrameName:@"Close.png"];
        CCSprite *closeHLSprite = [CCSprite spriteWithSpriteFrameName:@"Close_HL.png"];
        CCMenuItem *closeItem = [CCMenuItemImage itemFromNormalSprite:closeSprite selectedSprite:closeHLSprite target:self selector:@selector(closeStore)];
        closeItem.anchorPoint = ccp(1, 1);
        closeItem.position = ccp(winSize.width / 2 + backgroud.boundingBox.size.width / 2, winSize.height / 2 + backgroud.boundingBox.size.height / 2);
        
//        CCSpriteBatchNode *storeBannerBatch = [CCSpriteBatchNode batchNodeWithTexture:[[framCache spriteFrameByName:@"StoreBanner.png"] texture]];
//        [self addChild:storeBannerBatch];
//        
//        CCSpriteBatchNode *storeBannerHLBatch = [CCSpriteBatchNode batchNodeWithTexture:[[framCache spriteFrameByName:@"StoreBanner_HL.png"] texture]];
//        [self addChild:storeBannerHLBatch];
        
        CCArray *storeBannerArray = [CCArray array];
        CCArray *storeBannerHLArray = [CCArray array];
        
        NSArray *tierArray = [NSArray arrayWithObjects:@"        50个 = 6.00元", @"        150个 = 12.00元", @"        300个 = 18.00元", @"        600个 = 30.00元", @"        2500个 = 88.00元", nil];
        
        for (int i = 0; i < 5; i++) {
            CCSprite *storeBanner = [CCSprite spriteWithSpriteFrame:[framCache spriteFrameByName:@"StoreBanner.png"]];
            CCLabelTTF *label = [CCLabelTTF labelWithString:[tierArray objectAtIndex:i] dimensions:CGSizeMake(storeBanner.boundingBox.size.width, storeBanner.boundingBox.size.height) alignment:NSTextAlignmentLeft vertAlignment:CCVerticalAlignmentCenter lineBreakMode:NSLineBreakByCharWrapping fontName:@"STHeitiTC-Medium" fontSize:40];
            label.color = ccBLACK;
            label.position = ccp(storeBanner.boundingBox.size.width / 2, storeBanner.boundingBox.size.height / 2);
            [storeBanner addChild:label];
            [storeBannerArray addObject:storeBanner];
//            [storeBannerBatch addChild:storeBanner];
            
            CCSprite *storeBannerHL = [CCSprite spriteWithSpriteFrame:[framCache spriteFrameByName:@"StoreBanner_HL.png"]];
            CCLabelTTF *labelHL = [CCLabelTTF labelWithString:[tierArray objectAtIndex:i] dimensions:CGSizeMake(storeBannerHL.boundingBox.size.width, storeBannerHL.boundingBox.size.height) alignment:NSTextAlignmentLeft vertAlignment:CCVerticalAlignmentCenter lineBreakMode:NSLineBreakByCharWrapping fontName:@"STHeitiTC-Medium" fontSize:40];
            labelHL.position = ccp(storeBannerHL.boundingBox.size.width / 2, storeBannerHL.boundingBox.size.height / 2);
            [storeBannerHL addChild:labelHL];
            [storeBannerHLArray addObject:storeBannerHL];
//            [storeBannerHLBatch addChild:storeBannerHL];
            
        }
//        CCArray *storeBtns = [storeBannerBatch children];
//        CCArray *storeHLBtns = [storeBannerHLBatch children];
        
        CCArray *storeBtns = storeBannerArray;
        CCArray *storeHLBtns = storeBannerHLArray;
        
        CCMenuItem *tier0Item = [CCMenuItemImage itemFromNormalSprite:[storeBtns objectAtIndex:0] selectedSprite:[storeHLBtns objectAtIndex:0] target:self selector:@selector(buyTier0)];
//        tier0Item.anchorPoint = ccp(0, 0);
        tier0Item.position = ccp(winSize.width / 2, 225+75*4+40*4);
        
        CCMenuItem *tier1Item = [CCMenuItemImage itemFromNormalSprite:[storeBtns objectAtIndex:1] selectedSprite:[storeHLBtns objectAtIndex:1] target:self selector:@selector(buyTier1)];
        tier1Item.position = ccp(winSize.width / 2, 225+75*3+40*3);
        
        CCMenuItem *tier2Item = [CCMenuItemImage itemFromNormalSprite:[storeBtns objectAtIndex:2] selectedSprite:[storeHLBtns objectAtIndex:2] target:self selector:@selector(buyTier2)];
        tier2Item.position = ccp(winSize.width / 2, 225+75*2+40*2);
        
        CCMenuItem *tier3Item = [CCMenuItemImage itemFromNormalSprite:[storeBtns objectAtIndex:3] selectedSprite:[storeHLBtns objectAtIndex:3] target:self selector:@selector(buyTier3)];
        tier3Item.position = ccp(winSize.width / 2, 225+75+40);
        
        CCMenuItem *tier4Item = [CCMenuItemImage itemFromNormalSprite:[storeBtns objectAtIndex:4] selectedSprite:[storeHLBtns objectAtIndex:4] target:self selector:@selector(buyTier4)];
        tier4Item.position = ccp(winSize.width / 2, 225);
        
        
        CCMenu *menu = [CCMenu menuWithItems:tier0Item, tier1Item, tier2Item, tier3Item, tier4Item, closeItem, nil];
        menu.position = ccp(0, 0);
        [self addChild:menu];
        
    }
    return self;
}

- (void)closeStore {
    [self removeFromParentAndCleanup:YES];
}

- (void)buyTier0 {
    
}

- (void)buyTier1 {
    
}

- (void)buyTier2 {
    
}

- (void)buyTier3 {
    
}

- (void)buyTier4 {
    
}


@end
