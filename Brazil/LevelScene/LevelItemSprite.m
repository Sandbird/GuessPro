//
//  LevelLayer.m
//  CommanderCool
//
//  Created by Florian Strauß & Christian Janzen on 26.05.11.
//  Copyright 2011 Janzen & Strauß. All rights reserved.
//

#import "LevelItemSprite.h"
#import "GameManager.h"


@implementation LevelItemSprite

#pragma mark - Properties

@synthesize stars = _stars, levelIndex = _levelIndex, special = _special, completed = _completed, heaveness = _heaveness;

#pragma mark - init/dealloc

+ (id)layerWithLevelIndex:(int)index stars:(int)stars hasSpecial:(BOOL)special isCompleted:(BOOL)completed withHeaviness:(int)heaviness {
    return [[[LevelItemSprite alloc] initWithLevelIndex:index stars:stars hasSpecial:special isCompleted:completed withHeaviness:heaviness] autorelease];
}

- (id)initWithLevelIndex:(int)index stars:(int)stars hasSpecial:(BOOL)special isCompleted:(BOOL)completed withHeaviness:(int)heaviness {
    
    NSString *image;
    if(completed) {
        image = @"cc_levelmenu_item.png";        
    } else {
        image = @"cc_levelmenu_item_locked.png";
    }
    self = [super initWithSpriteFrameName:image];
    if (self) {
        self.levelIndex = index;
        self.stars      = stars;
        self.special    = special;
        self.completed  = completed;
        self.heaveness  = heaviness;
        
        [self setupLayer];        
    }
    return self;
}
- (void)dealloc {
    [super dealloc];
}
#pragma mark - setupLayer
- (void)setupLayer {

    
    // Show Stars and Level Label when level is not Completed!
    if(self.completed) {
        // Level levelIndex Label
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        CCLabelTTF *label = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i", (self.levelIndex + 1)] fontName:@"Helvetica-Bold" fontSize:18.0 * __HIGHRES_SCALE];
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        CCLabelTTF *label = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i", (self.levelIndex + 1)] fontName:@"Helvetica" fontSize:18.0 * __HIGHRES_SCALE];
#endif
  
        label.position = CGPointMake(35 * __HIGHRES_SCALE, 31 * __HIGHRES_SCALE);
        label.color = ccc3(153, 102, 51);
        [self addChild:label];
        [label release];
    
        // Stars
        NSInteger starPosX = 15 * __HIGHRES_SCALE;
        for(int starIndex=0; starIndex < 3; starIndex++) {
            CCSprite *starImage;
            
            if(starIndex < self.stars) {
                starImage = [[CCSprite alloc] initWithSpriteFrameName:@"cc_levelmenu_star.png"];
            } else {
                starImage = [[CCSprite alloc] initWithSpriteFrameName:@"cc_levelmenu_star_hidden.png"];
            }
            starImage.position = CGPointMake(starPosX, self.contentSize.height - (10 * __HIGHRES_SCALE));
            [self addChild:starImage z:10];
            [starImage release];
            starPosX += 15 * __HIGHRES_SCALE;
        }
        
        if(self.special) {
            CCSprite *specialItem = [CCSprite spriteWithSpriteFrameName:@"cc_levelmenu_award.png"];
            specialItem.position = ccp(54 *__HIGHRES_SCALE, 18 * __HIGHRES_SCALE);
            [self addChild:specialItem z:15];
        }
        
    }
    
    
}
/**
 * Creates a copy of the layer but in the active status
 */
- (LevelItemSprite *)activeItem {

    LevelItemSprite *layer = [LevelItemSprite layerWithLevelIndex:self.levelIndex stars:self.stars hasSpecial:self.special isCompleted:self.completed withHeaviness:self.heaveness];
    NSString *image;
    if(self.completed) {
        image = @"cc_levelmenu_item_pushed.png";
    } else {
        image = @"cc_levelmenu_item_locked_pushed.png";
    }
    
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    CCSpriteFrame *frame = [frameCache spriteFrameByName:image];
    [layer setTexture:frame.texture];
    [layer setTextureRect:frame.rect];
    

    for (CCNode *kind in [layer children]) {
        kind.position = CGPointMake(kind.position.x, kind.position.y - (9 * __HIGHRES_SCALE));
    }
    return layer;
}

#pragma mark - CCRGBAProtocol
-(void) setColor:(ccColor3B)color {
    
}

-(ccColor3B) color {
    return ccc3(255, 255, 255);
}

-(GLubyte) opacity {
    return 255;
}

-(void) setOpacity: (GLubyte) opacity {
    
}

@end
