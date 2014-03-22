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

@synthesize stars = _stars, levelIndex = _levelIndex, special = _special, completed = _completed;

#pragma mark - init/dealloc

+ (id)layerWithLevelIndex:(int)index stars:(int)stars hasSpecial:(BOOL)special isCompleted:(BOOL)completed withType:(int)type {
    return [[[LevelItemSprite alloc] initWithLevelIndex:index stars:stars hasSpecial:special isCompleted:completed withType:type] autorelease];
}

- (id)initWithLevelIndex:(int)index stars:(int)stars hasSpecial:(BOOL)special isCompleted:(BOOL)completed withType:(int)type {
    
    NSString *image;
    if(completed) {
        switch (type) {
            case 0:
                image = @"ItemBlack.png";
                break;
                
            case 1:
                image = @"ItemBlue.png";
                break;
                
            case 2:
                image = @"ItemRed.png";
                break;
                
            case 3:
                image = @"ItemGreen.png";
                break;
                
            default:
                break;
        }
        
    } else {
        image = @"ItemLock.png";
    }
    self = [super initWithSpriteFrameName:image];
    if (self) {
        self.levelIndex = index;
        self.stars      = stars;
        self.special    = special;
        self.completed  = completed;
        self.type  = type;
        
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
  
        label.position = CGPointMake(27 * __HIGHRES_SCALE, 16 * __HIGHRES_SCALE);
        label.color = ccc3(40, 40, 40);
        [self addChild:label];
        [label release];
    
        // Stars
        NSInteger starPosX = 15 * __HIGHRES_SCALE * 2.7;
        if (self.special) {
            CCSprite *starImage = [[CCSprite alloc] initWithSpriteFrameName:@"cc_levelmenu_star.png"];
            starImage.position = CGPointMake(starPosX, self.contentSize.height - (40 * __HIGHRES_SCALE));
            [self addChild:starImage z:10];
            [starImage release];
            starPosX += 15 * __HIGHRES_SCALE;
        }
        
        /*
        if(self.special) {
            CCSprite *specialItem = [CCSprite spriteWithSpriteFrameName:@"cc_levelmenu_award.png"];
            specialItem.position = ccp(54 *__HIGHRES_SCALE, 18 * __HIGHRES_SCALE);
            [self addChild:specialItem z:15];
        }
         */
        
    }
    
    
}
/**
 * Creates a copy of the layer but in the active status
 */
- (LevelItemSprite *)activeItem {

    LevelItemSprite *layer = [LevelItemSprite layerWithLevelIndex:self.levelIndex stars:self.stars hasSpecial:self.special isCompleted:self.completed withType:self.type];
    NSString *image;
    if(self.completed) {
        switch (self.type) {
            case 0:
                image = @"ItemBlack_HL.png";
                break;
                
            case 1:
                image = @"ItemBlue_HL.png";
                break;
                
            case 2:
                image = @"ItemRed_HL.png";
                break;
                
            case 3:
                image = @"ItemGreen_HL.png";
                break;
                
            default:
                break;
        }
        
    } else {
        image = @"ItemLock_HL.png";
    }
    
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    CCSpriteFrame *frame = [frameCache spriteFrameByName:image];
    [layer setTexture:frame.texture];
    [layer setTextureRect:frame.rect];
    

//    for (CCNode *kind in [layer children]) {
//        kind.position = CGPointMake(kind.position.x, kind.position.y - (9 * __HIGHRES_SCALE));
//    }
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
