//
//  MapScene.h
//  CommanderCool
//
//  Created by Florian Strauß & Christian Janzen on 23.10.11.
//  Copyright 2011 Janzen & Strauß. All rights reserved.
//

//#import "MenuScene.h"
#import "SlidingMenuGrid.h"

@class PageControlLayer;

@interface MapScene : CCLayer <SlidingMenuGridDelegate> 

@property (nonatomic, retain) PageControlLayer *pageControl;

+(id)scene;

@end
