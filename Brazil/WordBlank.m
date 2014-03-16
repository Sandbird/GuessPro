//
//  WordBlank.m
//  Brazil
//
//  Created by zhaozilong on 13-10-29.
//
//

#import "WordBlank.h"

@implementation WordBlank

+ (id)blankWithSquareIndex:(int)index squareNum:(int)totalNum parentNode:(CCNode *)parent {
    return [[[self alloc] initWithSquareIndex:index squareNum:totalNum parent:parent] autorelease];
}

- (id)initWithSquareIndex:(int)index squareNum:(int)totalNum parent:(CCNode *)parent {
    self = [super init];
    if (self) {
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
//        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        float blankWidth = [GPNavBar isiPad] ? 96.0 : 40.0;
        //250 * 250()
        int initalPosOfX = (screenSize.width - totalNum * blankWidth) / 2;

        float blankX = initalPosOfX + ((float)index + (float)1 / 2) * blankWidth;
        float blankY;
        if ([GPNavBar isiPad]) {
            blankY = blankWidth * 3.5 + 20.0;
        } else if ([GPNavBar isiPhone5]) {
            blankY = blankWidth * 3.5 + 75.0;
        } else {
            blankY = blankWidth * 3.5 + 20.0;
        }
        
        self.point = ccp(blankX, blankY);
        
        self.blankSprite = [CCSprite spriteWithSpriteFrameName:@"WordFill.png"];
        self.blankSprite.scale = blankWidth / self.blankSprite.boundingBox.size.width;
        
        
        self.blankSprite.anchorPoint = ccp(0.5, 0.5);
        self.blankSprite.position = ccp(blankX, blankY);
        [parent addChild:self.blankSprite z:ZORDER_BLANK];
        
        self.fillWord = nil;
        
    }
    return self;
}


@end
