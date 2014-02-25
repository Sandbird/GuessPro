//
//  PageControlLayer.m
//  CommanderCool
//
//  Created by Florian Strauß & Christian Janzen on 27.05.11.
//  Copyright 2011 Janzen & Strauß. All rights reserved.
//

#import "PageControlLayer.h"
#import "ColoredCircleSprite.h"

@implementation PageControlLayer

@synthesize pages = _pages;
@synthesize currentPage = _currentPage;

+ (id)layerWithPages:(int)pages currentPage:(int)page {
    return [[[PageControlLayer alloc] initWithPages:pages currentPage:page] autorelease];
}

- (id)initWithPages:(int)pages currentPage:(int)page{
    self = [super init];
    if (self) {
        _pages = pages;
        _currentPage = page;
        [self setupLayer];
    }
    return self;    
}
- (void)setCurrentPage:(int)currentPage {
    
    _currentPage = currentPage;
    int i = 0;
    for (ColoredCircleSprite *circle in [self children]) {

        if(self.currentPage == i) {
            circle.opacity = 255;
        } else {
            circle.opacity = 150;
        }
     
        i++;
    }
}
- (void)setupLayer {
    
    for (int i = 0; i < self.pages; i++) {
        ccColor4B color;
        if(self.currentPage == i) {
            color = ccc4(255, 255, 255, 255);
        } else {
            color = ccc4(255, 255, 255, 150);
        }
        ColoredCircleSprite *circle = [ColoredCircleSprite circleWithColor:color radius:5];
        circle.position = ccp((15 * i),0);
        [self addChild:circle];
    }
    self.contentSize = CGSizeMake(self.pages * 10, 10);
}
@end