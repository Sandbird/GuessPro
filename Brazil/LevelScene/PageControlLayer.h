//
//  PageControlLayer.h
//  CommanderCool
//
//  Created by Florian Strauß & Christian Janzen on 27.05.11.
//  Copyright 2011 Janzen & Strauß. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PageControlLayer : CCLayer {
    
}
@property (nonatomic) int pages;
@property (nonatomic) int currentPage;

+ (id)layerWithPages:(int)pages currentPage:(int)page;
- (id)initWithPages:(int)pages currentPage:(int)page;
- (void)setupLayer;

@end
