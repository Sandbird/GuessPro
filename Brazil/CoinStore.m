//
//  CoinStore.m
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-5.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "CoinStore.h"

//所有的位置坐标
typedef struct ItemPostion {
    CGPoint ItemPrice6;
    CGPoint ItemPrice12;
    CGPoint ItemPrice18;
    CGPoint ItemPrice30;
    CGPoint ItemPrice88;
    
    CGPoint ItemClose;
    CGPoint ItemBackground;
}ItemPostionSet;

typedef enum {
    ProductPrice6,
    ProductPrice12,
    ProductPrice18,
    ProductPrice30,
    ProductPrice88,
    ProductPriceMAX,
}ProductPriceTags;

@interface CoinStore() {
    ItemPostionSet _IPSet;
    
    CCMenu *_menu;
    
//    CCSprite *_backgroud;
}

@property (nonatomic, retain) UIAlertView *indicator;

@property (assign) ProductPriceTags ppTag;

@end


@implementation CoinStore

- (void)dealloc {

    
    CCLOG(@"coinStore is dealloc");

    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:[AssetHelper getDeviceSpecificFileNameFor:@"Store.plist"]];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        self.isTouchEnabled = YES;
        
        self.ppTag = ProductPriceMAX;
        
        //为内部交易加监听事件
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
        [self addChild:color z:0];
        
        //加载帧到缓存
        CCSpriteFrameCache *framCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [framCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"Store.plist"]];
        
        CGFloat posY;
        CGSize wordSize;
        CGFloat fontSize;
        if ([GPNavBar isiPad]) {
            posY = winSize.height - 76.0f;
            wordSize = CGSizeMake(600, 200);
            fontSize = 37;
        } else if ([GPNavBar isiPhone5]) {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(250, 100);
            fontSize = 18;
        } else {
            posY = winSize.height - 38.0f;
            wordSize = CGSizeMake(250, 100);
            fontSize = 18;
        }
        
        NSString *title = @"电影院大卖场";
        
        CCLabelTTF *labelTitle = [CCLabelTTF labelWithString:title fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TITLE];
        labelTitle.color = ccWHITE;
        labelTitle.anchorPoint = ccp(0.5, 0.5);
        labelTitle.position = ccp(winSize.width / 2, posY);
        [self addChild:labelTitle];
        
        CCLabelTTF *labelWords = [CCLabelTTF labelWithString:@"欢迎购买黄金摄像机！\n购买任意数量黄金摄像机，即可去除广告条。" dimensions:wordSize alignment:NSTextAlignmentCenter vertAlignment:CCVerticalAlignmentTop lineBreakMode:NSLineBreakByCharWrapping fontName:FONTNAME_OF_TEXT fontSize:FONTSIZE_OF_BORAD_TEXT];
        labelWords.color = ccWHITE;
        labelWords.anchorPoint = ccp(0.5, 1);
        labelWords.position = ccp(winSize.width / 2,  posY - labelTitle.boundingBox.size.height);
        [self addChild:labelWords];
        
        
        //设置初始位置
        [self setItemInitalPostion];
        
//        CCSprite *backgroud = [CCSprite spriteWithSpriteFrameName:@"StoreBackgroud.png"];
//        [self addChild:backgroud z:0];
//        backgroud.position = ccp(winSize.width / 2, winSize.height / 2);
        
        CCSprite *closeSprite = [CCSprite spriteWithSpriteFrameName:@"close.png"];
        CCSprite *closeHLSprite = [CCSprite spriteWithSpriteFrameName:@"close_HL.png"];
        CCMenuItem *closeItem = [CCMenuItemImage itemFromNormalSprite:closeSprite selectedSprite:closeHLSprite target:self selector:@selector(closeStore)];
        closeItem.anchorPoint = ccp(0.5, 0.5);
        closeItem.position = ccp(winSize.width / 2, 50);
        
        CCArray *storeBannerArray = [CCArray array];
        CCArray *storeBannerHLArray = [CCArray array];
        
        NSArray *tierArray = [NSArray arrayWithObjects:@"          50枚 = 6.00元", @"          150枚 = 12.00元", @"          300枚 = 18.00元", @"          600枚 = 30.00元", @"          2500枚 = 88.00元", nil];
        
        for (int i = 0; i < 5; i++) {
            CCSprite *storeBanner = [CCSprite spriteWithSpriteFrame:[framCache spriteFrameByName:@"StoreBanner.png"]];
            CCLabelTTF *label = [CCLabelTTF labelWithString:[tierArray objectAtIndex:i] dimensions:CGSizeMake(storeBanner.boundingBox.size.width, storeBanner.boundingBox.size.height) alignment:NSTextAlignmentLeft vertAlignment:CCVerticalAlignmentCenter lineBreakMode:NSLineBreakByCharWrapping fontName:@"STHeitiTC-Medium" fontSize:fontSize];
            label.color = ccBLACK;
            label.position = ccp(storeBanner.boundingBox.size.width / 2, storeBanner.boundingBox.size.height / 2);
            [storeBanner addChild:label];
            [storeBannerArray addObject:storeBanner];
//            [storeBannerBatch addChild:storeBanner];
            
            CCSprite *storeBannerHL = [CCSprite spriteWithSpriteFrame:[framCache spriteFrameByName:@"StoreBanner_HL.png"]];
            CCLabelTTF *labelHL = [CCLabelTTF labelWithString:[tierArray objectAtIndex:i] dimensions:CGSizeMake(storeBannerHL.boundingBox.size.width, storeBannerHL.boundingBox.size.height) alignment:NSTextAlignmentLeft vertAlignment:CCVerticalAlignmentCenter lineBreakMode:NSLineBreakByCharWrapping fontName:@"STHeitiTC-Medium" fontSize:fontSize];
            labelHL.position = ccp(storeBannerHL.boundingBox.size.width / 2, storeBannerHL.boundingBox.size.height / 2);
            labelHL.color = ccGRAY;
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
        tier0Item.position = _IPSet.ItemPrice6;
        
        CCMenuItem *tier1Item = [CCMenuItemImage itemFromNormalSprite:[storeBtns objectAtIndex:1] selectedSprite:[storeHLBtns objectAtIndex:1] target:self selector:@selector(buyTier1)];
        tier1Item.position = _IPSet.ItemPrice12;
        
        CCMenuItem *tier2Item = [CCMenuItemImage itemFromNormalSprite:[storeBtns objectAtIndex:2] selectedSprite:[storeHLBtns objectAtIndex:2] target:self selector:@selector(buyTier2)];
        tier2Item.position = _IPSet.ItemPrice18;
        
        CCMenuItem *tier3Item = [CCMenuItemImage itemFromNormalSprite:[storeBtns objectAtIndex:3] selectedSprite:[storeHLBtns objectAtIndex:3] target:self selector:@selector(buyTier3)];
        tier3Item.position = _IPSet.ItemPrice30;
        
        CCMenuItem *tier4Item = [CCMenuItemImage itemFromNormalSprite:[storeBtns objectAtIndex:4] selectedSprite:[storeHLBtns objectAtIndex:4] target:self selector:@selector(buyTier4)];
        tier4Item.position = _IPSet.ItemPrice88;
        
        
        _menu = [CCMenu menuWithItems:tier0Item, tier1Item, tier2Item, tier3Item, tier4Item, closeItem, nil];
        _menu.position = ccp(0, 0);
        [self addChild:_menu];
        
    }
    return self;
}

- (void)setItemInitalPostion {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CGFloat posX = winSize.width / 2;
    CGFloat heightToBottom, heightOfBanner, spaceBetweenBanner;
    
    if ([GPNavBar isiPad]) {
        heightToBottom = 225;
        heightOfBanner = 75;
        spaceBetweenBanner = 40;
    } else if ([GPNavBar isiPhone5]) {
        heightToBottom = 130;
        heightOfBanner = 36;
        spaceBetweenBanner = 20;
    } else {
        heightToBottom = 100;
        heightOfBanner = 36;
        spaceBetweenBanner = 20;
    }
    
//    _IPSet.ItemBackground = ccp(winSize.width / 2, winSize.height / 2);
//    _IPSet.ItemClose = ccp(winSize.width / 2 + backgroud.boundingBox.size.width / 2, winSize.height / 2 + backgroud.boundingBox.size.height / 2);
    
    _IPSet.ItemPrice6 = ccp(posX, heightToBottom+heightOfBanner*4+spaceBetweenBanner*4);
    _IPSet.ItemPrice12 = ccp(posX, heightToBottom+heightOfBanner*3+spaceBetweenBanner*3);
    _IPSet.ItemPrice18 = ccp(posX, heightToBottom+heightOfBanner*2+spaceBetweenBanner*2);
    _IPSet.ItemPrice30 = ccp(posX, heightToBottom+heightOfBanner+spaceBetweenBanner);
    _IPSet.ItemPrice88 = ccp(posX, heightToBottom);
    
}

//- (void)smallToBigAction {
//    _backgroud.scale = 0;
//    CCScaleTo *scaleToBig = [CCScaleTo actionWithDuration:0.2 scale:1];
//    CCScaleTo *scaleToSmall = [CCScaleTo actionWithDuration:0.1 scale:0.9];
//    CCScaleTo *scaleToNormal = [CCScaleTo actionWithDuration:0.1 scale:1];
//    
//    CCSequence *smallToBig = [CCSequence actions:scaleToBig, scaleToSmall, scaleToNormal, nil];
//    
//    [_backgroud runAction:smallToBig];
//}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
}

+ (CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [CoinStore locationFromTouch:touch];
    BOOL isTouchHandled = YES;
    for (CCMenuItem *item in _menu.children) {
        if (CGRectContainsPoint(item.boundingBox, point)) {
            isTouchHandled = NO;
        }
    }
    
    return isTouchHandled;
}

- (void)closeStore {
//    [self removeFromParentAndCleanup:YES];
    
    GPNavBar *navBar = (GPNavBar *)[self parent];
    [navBar showStoreLayer];
}

- (void)buyTier0 {
    self.ppTag = ProductPrice6;
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.Coin.50"];
    
    [self setIndicatorShow];
}

- (void)buyTier1 {
    self.ppTag = ProductPrice12;
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.Coin.150"];
    
    [self setIndicatorShow];
}

- (void)buyTier2 {
    self.ppTag = ProductPrice18;
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.Coin.250"];
    
    [self setIndicatorShow];
}

- (void)buyTier3 {
    self.ppTag = ProductPrice30;
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.Coin.450"];
    
    [self setIndicatorShow];
}

- (void)buyTier4 {
    self.ppTag = ProductPrice88;
    [self buyWhichProduct:@"IAP.VOCEE.GuessProMovie.Coin.1500"];
    
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
//        NSLog(@"购买成功，给100金币");
    
    CCLOG(@"成功购买%d", [productName intValue]);
    
    GPNavBar *navBar = (GPNavBar *)[self parent];
    [navBar changeTotalScore:productName.intValue];
    [navBar refreshTotalScore];
    
//    switch (self.ppTag) {
//        case ProductPrice6:
//            <#statements#>
//            break;
//            
//        case ProductPrice12:
//            <#statements#>
//            break;
//            
//        case ProductPrice18:
//            <#statements#>
//            break;
//            
//        case ProductPrice30:
//            <#statements#>
//            break;
//            
//        case ProductPrice88:
//            <#statements#>
//            break;
//            
//        case ProductPriceMAX:
//            <#statements#>
//            break;
//            
//        case ProductPrice6:
//            <#statements#>
//            break;
//            
//        default:
//            break;
//    }

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
