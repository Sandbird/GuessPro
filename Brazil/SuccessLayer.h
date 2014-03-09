//
//  SuccessLayer.h
//  Brazil
//
//  Created by zhaozilong on 13-11-2.
//
//

#import "CCLayer.h"

#import "GADBannerView.h"

@interface SuccessLayer : CCLayer <GADBannerViewDelegate> {
    CGPoint _defaultPosition;
	CGPoint _lastTouchLocation;
    
    BOOL _isTouchHandled;
}

- (void)setSuccessLayerColorWithImgName:(NSString *)imgName;
- (void)setPositionLabel:(NSString *)posString;

@end
