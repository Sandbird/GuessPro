//
//  MapScene.m
//  CommanderCool
//
//  Created by Florian Strauß & Christian Janzen on 23.10.11.
//  Copyright 2011 Janzen & Strauß. All rights reserved.
//


#import "MapScene.h"
#import "CCLabelTTF.h"
#import "LevelItemSprite.h"
#import "PageControlLayer.h"
#import "GPNavBar.h"

@interface MapScene()

@property GPNavBar *navBar;

@property (nonatomic, retain) CCLabelBMFont *title;

- (NSString *)backgroundForIndex:(NSUInteger)index;
- (NSString *)titleForIndex:(NSUInteger)index;
@end

@implementation MapScene
//@synthesize title = _title;
@synthesize pageControl = _pageControl;

+(id)scene {
	CCScene *scene = [CCScene node];
	MapScene *layer = [MapScene node];
	[scene addChild: layer];
	return scene;
}
- (void)dealloc {
    [_pageControl release];
//    [_title release];
    [super dealloc];
}

-(id) init {
	if( (self=[super init] )) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [[CCTextureCache sharedTextureCache] addImage:[AssetHelper getDeviceSpecificFileNameFor:@"map_icon.png"]];
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"cc_levelmenu.plist"]];      
        
        // Preloading
//        [CCSprite spriteWithFile:[AssetHelper getDeviceSpecificFileNameFor:[self backgroundForIndex:0]]];
//        [CCSprite spriteWithFile:[AssetHelper getDeviceSpecificFileNameFor:[self backgroundForIndex:1]]];
//        [CCSprite spriteWithFile:[AssetHelper getDeviceSpecificFileNameFor:[self backgroundForIndex:2]]];
//        [CCSprite spriteWithFile:[AssetHelper getDeviceSpecificFileNameFor:[self backgroundForIndex:3]]];
        
        // Scene Background
//		CCSprite *background = [CCSprite spriteWithFile:[AssetHelper getDeviceSpecificFileNameFor:[self backgroundForIndex:0]]];
//		background.position = CGPointMake(winSize.width / 2, winSize.height / 2);
//        background.tag = 10;
//		[self addChild:background z:0];
        
//        CCSprite *backgroundFade = [CCSprite spriteWithFile:[AssetHelper getDeviceSpecificFileNameFor:[self backgroundForIndex:0]]];
//        backgroundFade.position = background.position;
//        backgroundFade.tag = 11;
//        backgroundFade.opacity = 0.0;
//		[self addChild:backgroundFade z:1];
        
        CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(40, 40, 40, 255)];
        [self addChild:color];
		
        
		NSArray *levels = [[GameManager sharedGameManager] levels];
		NSMutableArray* allItems = [[NSMutableArray alloc] init];
        
        
        // Map Overview Title
//        _title = [[CCLabelBMFont labelWithString:[self titleForIndex:0] fntFile:[AssetHelper getDeviceSpecificFileNameFor:@"BadaBoom40.fnt"]] retain];
//		_title.position = CGPointMake(winSize.width / 2, winSize.height - (winSize.height * 0.10));
//        _title.scale = 0.1;
//		[self addChild:_title z:2];
//		id actionScaleTo = [CCScaleTo actionWithDuration:0.5 scale:1];
//		[_title runAction:actionScaleTo];
        
    
        int i = 0;
        BOOL lastCompletedMap = NO;
        
		for (NSDictionary *level in levels) {      

            int stars           = [[GameManager sharedGameManager] starsForLevelIndex:i];
            BOOL levelStatus    = [[level objectForKey:@"Completed"] boolValue];

            BOOL isCompleted    = (levelStatus || (!levelStatus && lastCompletedMap) || (i == 0));
            lastCompletedMap    = levelStatus;
            BOOL special        = [[GameManager sharedGameManager] hasPassMarkForLevelIndex:i];
//            int heaviness       = [[level objectForKey:@"Heaviness"] intValue];
            int type            = [[level objectForKey:@"Type"] intValue];
            
            SEL onClick = (isCompleted) ? @selector(selectLevel:) : nil;
            
            LevelItemSprite *button         = [LevelItemSprite layerWithLevelIndex:i 
                                                                             stars:stars 
                                                                        hasSpecial:special 
                                                                       isCompleted:isCompleted
                                                                        withType:type];
            LevelItemSprite *buttonActive   = [button activeItem];
                    
            CCMenuItemSprite *item = [CCMenuItemSprite itemFromNormalSprite:button
                                                             selectedSprite:buttonActive
                                                             disabledSprite:nil 
                                                                     target:self 
                                                                   selector:onClick];
            
            if([[level objectForKey:@"Tilemap"] isEqualToString:@""]) {
                item.opacity = 0.5;
            }


            [allItems addObject:item];
            i++;
        }
        
        // Cool Level Sliding Menu
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED   
        SlidingMenuGrid* menuGrid;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            menuGrid = [SlidingMenuGrid menuWithArray:allItems 
                                                                  cols:5 
                                                                  rows:6
                                                              position:ccp(40 * __HIGHRES_SCALE, 400 * __HIGHRES_SCALE)
                                                               padding:ccp(75 * __HIGHRES_SCALE, 60 * __HIGHRES_SCALE)
                                                         verticalPages:NO];
        } else {
            menuGrid = [SlidingMenuGrid menuWithArray:allItems 
                                                 cols:5
                                                 rows:([GPNavBar isiPhone5] ? 7 : 6)
                                             position:([GPNavBar isiPhone5] ? ccp(40 * __HIGHRES_SCALE, 450 * __HIGHRES_SCALE) : ccp(40 * __HIGHRES_SCALE, 380 * __HIGHRES_SCALE))
                                              padding:ccp(60 * __HIGHRES_SCALE, 60 * __HIGHRES_SCALE)
                                        verticalPages:NO];
        }

        
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
        SlidingMenuGrid* menuGrid = [SlidingMenuGrid menuWithArray:allItems 
                                                              cols:5 
                                                              rows:2 
                                                          position:ccp(140 * __HIGHRES_SCALE, 240 * __HIGHRES_SCALE) 
                                                           padding:ccp(90 * __HIGHRES_SCALE, 100 * __HIGHRES_SCALE) 
                                                     verticalPages:NO];
#endif
		
        [allItems release];
        menuGrid.delegate = self;
        [menuGrid SetSwipingOnMenuOnly:NO];

		[self addChild:menuGrid z:2];
        
        [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"cc_menu.plist"]];
        
        // Back Button
//		CCSprite *back = [CCSprite spriteWithSpriteFrameName:@"back.png"];
//		CCSprite *backSelected = [CCSprite spriteWithSpriteFrameName:@"back_pushed.png"];
//		CCMenuItemSprite *backMenuItem = [CCMenuItemSprite itemFromNormalSprite:back 
//																 selectedSprite:backSelected 
//																 disabledSprite:nil 
//																		 target:self 
//																	   selector:@selector(back:)];
//		
//        // Back Button Menu
//        CCMenu *backMenu = [CCMenu menuWithItems:backMenuItem,  nil];
//		backMenu.position = CGPointMake(90 * __HIGHRES_SCALE,winSize.height - (winSize.height * 0.90));
//		[self addChild:backMenu z:5];
        
        
        self.pageControl = [PageControlLayer layerWithPages:menuGrid.iPageCount+1 currentPage:0];
//        self.pageControl.anchorPoint = ccp(0.5, 0.5);
        self.pageControl.position = CGPointMake(0/* - self.pageControl.boundingBox.size.width / 2*/, winSize.height * 0.02);
		[self addChild:self.pageControl z:7];
        
        
        //NavBar
        _navBar = [[[GPNavBar alloc] initWithSceneType:GPSceneTypeLevelLayer] autorelease];
        [self addChild:_navBar z:ZORDER_NAV_BAR];
//        [_navBar setTotalLabelScore:500];        
		
	}
	return self;
}
- (void)selectLevel:(CCMenuItemFont *)sender {
	[GPNavBar playBtnPressedEffect];
	[[GameManager sharedGameManager] loadLevelWithIndex:(int)(sender.tag - 1) GPSceneType:GPSceneTypeGuessLayer];
}
- (void)back:(id)sender {
	[[GameManager sharedGameManager] loadMenuScene];
}

#pragma mark - SlidingMenuGridDelegate
- (void)menu:(SlidingMenuGrid *)menu didScrollToPage:(int)index {
    [self.pageControl setCurrentPage:index];
    
//    CCSprite *background = (CCSprite *)[self getChildByTag:10];
//    CCSprite *backgroundFade = (CCSprite *)[self getChildByTag:11];
//    
//    
//    
//  
//        CCSprite *newBackground = [CCSprite spriteWithFile:[AssetHelper getDeviceSpecificFileNameFor:[self backgroundForIndex:index]]];
//        
//  
//            backgroundFade.texture = newBackground.texture;
//            
//            CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.2];
//            CCCallBlock *finish = [CCCallBlock actionWithBlock:^{
//                background.texture = newBackground.texture;
//            }];
//            CCSequence *sequence = [CCSequence actions:fadeIn, finish, nil];
//            [backgroundFade runAction:sequence];
    
//            [_title setString:[self titleForIndex:index]];
 
    
    
    
}

- (NSString *)backgroundForIndex:(NSUInteger)index {

    switch (index) {
        case 0:
            return @"background-noon.png";
            break;
        case 1:
            return @"background-dawn.png";
            break;
        case 2:
            return @"background-evening.png";
            break;
        case 3:
            return @"background-night.png";
            break;
        default:
            return @"background-noon.png";
            break;
    }
}

- (NSString *)titleForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return @"Chapter 1 - Jungle Boogy";
            break;
        case 1:
            return @"Chapter 2 - Snow Hell";
            break;
        case 2:
            return @"Chapter 3 - Desert Storm";
            break;
        case 3:
            return @"Chapter 4 - E.V.I.L";
            break;
        default:
            return @"Select Adventure";
            break;
    }
}
@end
