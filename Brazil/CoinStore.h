//
//  CoinStore.h
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-5.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "cocos2d.h"

@interface CoinStore : CCLayer <SKPaymentTransactionObserver, SKProductsRequestDelegate, SKRequestDelegate> {
    
}

- (void)smallToBigAction;

@end
