//
//  CoinStore.m
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-5.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "CoinStore.h"

typedef enum {
    ProductPrice6,
    ProductPrice12,
    ProductPrice18,
    ProductPrice30,
    ProductPrice88,
    ProductPriceMAX,
}ProductPriceTags;

@interface CoinStore()

@property (nonatomic, retain) UIAlertView *indicator;

@end


@implementation CoinStore

- (void)dealloc {

    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        //为内部交易加监听事件
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
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
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.100Coins"];
    
    [self setIndicatorShow];
}

- (void)buyTier1 {
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.100Coins"];
    
    [self setIndicatorShow];
}

- (void)buyTier2 {
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.100Coins"];
    
    [self setIndicatorShow];
}

- (void)buyTier3 {
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.100Coins"];
    
    [self setIndicatorShow];
}

- (void)buyTier4 {
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.100Coins"];
    
    [self setIndicatorShow];
}

- (void)buyWhichProduct:(NSString *)PID {
    
    if ([SKPaymentQueue canMakePayments]) {
        
        //请求产品信息
        NSArray *productArray = [[NSArray alloc] initWithObjects:PID, nil];
        
        NSSet *productSet = [NSSet setWithArray:productArray];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
        request.delegate = self;
        [request start];
        [productArray release];
        
        //        NSLog(@"允许程序内付费购买");
    } else {
        
        //        NSLog(@"不允许程序内付费购买");
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STORE_ALERT_TITLE", nil) message:NSLocalizedString(@"STORE_ALERT_MSG", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CLOSE", nil) otherButtonTitles:nil];
        
        [alerView show];
        [alerView release];
        
    }
}

//记录交易
-(void)recordTransaction:(NSString *)productName{
    //    NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)productName{
        NSLog(@"购买成功，给100金币");
    
    //    [UserSetting setPurchaseVIPMode:YES];
    
//    [UserSetting setIsPurchaseNoAdBanner:YES];
    
}

- (void)transactionCompleted:(SKPaymentTransaction *)transaction {
    
    //    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)transactionFailed:(SKPaymentTransaction *)transaction {
    //    NSLog(@"------失败--------");
    [self setIndicatorOff];
    if (transaction.error.code != SKErrorPaymentCancelled){
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)transactionRestored:(SKPaymentTransaction *)transaction {
    //    NSLog(@"交易恢复处理");
    
    NSString *PID = transaction.payment.productIdentifier;
    
    if ([PID length] > 0) {
        NSArray *temp = [PID componentsSeparatedByString:@"."];
        NSString *productName = [temp lastObject];
        
        if ([productName length] > 0) {
            [self provideContent:productName];
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    //    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self transactionCompleted:transaction];
                
                [self setIndicatorOff];
                
                //                NSLog(@"-----交易完成 --------");
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STORE_ALERT_CON", nil) message:NSLocalizedString(@"STORE_ALERT_CON_MSG", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CON_OK", nil) otherButtonTitles:nil];
                
                [alerView show];
                [alerView release];
                
                break;
            case SKPaymentTransactionStatePurchasing:
                //                NSLog(@"-----商品添加进列表 --------");
                break;
                
            case SKPaymentTransactionStateFailed:
                [self transactionFailed:transaction];
                //                NSLog(@"-----交易失败--------");
                
                [self setIndicatorOff];
                
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"STORE_ALERT_FAIL_MSG", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CLOSE", nil) otherButtonTitles:nil];
                
                [alerView2 show];
                [alerView2 release];
                break;
                
            case SKPaymentTransactionStateRestored:
                //                NSLog(@"-----已经购买过该商品 --------");
                [self transactionRestored:transaction];
                
                [self setIndicatorOff];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
    [self setIndicatorOff];
    //    NSLog(@"restoreCompletedTransactionsFailedWithError");
    
}

//- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
//    NSLog(@"removedTransactions");
//}
//
//- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
//    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
//}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSArray *myProducts = response.products;
    if ([myProducts count] >= 1) {
        //    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
        //    NSLog(@"产品付费数量: %d", [myProducts count]);
        
        SKPayment *payment = nil;
        for (SKProduct *product in myProducts) {
            //        NSLog(@"product info");
            //        NSLog(@"SKProduct 描述信息%@", [product description]);
            //        NSLog(@"产品标题 %@" , product.localizedTitle);
            //        NSLog(@"产品描述信息: %@" , product.localizedDescription);
            //        NSLog(@"价格: %@" , product.price);
            //        NSLog(@"Product id: %@" , product.productIdentifier);
            payment = [SKPayment paymentWithProduct:product];
        }
        
        //    NSLog(@"---------发送购买请求------------");
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [request autorelease];
    } else {
        [self setIndicatorOff];
        
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SORRY", nil) message:NSLocalizedString(@"FAIL_GET_INFO", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CON_OK", nil) otherButtonTitles:nil];
        
        [alerView show];
        [alerView release];
    }
}

#pragma mark - SKRequestDelegate

//下载失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    [self setIndicatorOff];
    
    //    NSLog(@"-------弹出错误信息----------");
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STORE_ALERT_TITLE", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CLOSE", nil) otherButtonTitles:nil];
    
    [alerView show];
    [alerView release];
}

- (void)requestDidFinish:(SKRequest *)request {
    //    NSLog(@"----------反馈信息结束--------------");
}

- (void)setIndicatorShow {
    
    NSString *str = NSLocalizedString(@"PLEASE_WAIT", @"请稍后...");
    _indicator = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_indicator addSubview:indicatorView];
    [indicatorView startAnimating];
    CGRect rect = indicatorView.frame;
    rect.origin.x += 125;
    rect.origin.y += 50;
    [indicatorView setFrame:rect];
    [indicatorView release];
    [_indicator show];
    [_indicator release];
    
    [self performSelector:@selector(setIndicatorOff) withObject:nil afterDelay:30];
}

- (void)setIndicatorOff {
    if (_indicator) {
        [_indicator dismissWithClickedButtonIndex:0 animated:YES];
        _indicator = nil;
    }
}


@end
