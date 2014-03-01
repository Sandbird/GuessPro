//
//  iBlock.m
//  Brazil
//
//  Created by zhaozilong on 13-10-26.
//
//

#import "iBlock.h"

@interface iBlock()

@property (nonatomic, retain)CCSprite *blockSprite;

@property BlockStatus currBlockStatus;
@property float blockScaleInital;
@property (assign)CGPoint initalPos;

@end

@implementation iBlock

+ (id)blockWithStatus:(BlockStatus)status squareIndex:(int)index squareNum:(int)totalNum parentNode:(CCNode *)parent {
    return [[[self alloc] initWithStatus:status squareIndex:index squareNum:totalNum parent:parent] autorelease];
}

- (id)initWithStatus:(BlockStatus)status squareIndex:(int)index squareNum:(int)totalNum parent:(CCNode *)parent {
    self = [super init];
    if (self) {
        
        self.squareIndex = index;
        
        self.currBlockStatus = status;
        
        int numPerLine = sqrtf((float)totalNum);
        float blockWidth = (float)500.0 / numPerLine;
        //250 * 250()
        int posOfX = (index % numPerLine) + 1;

        float blockX = ((float)posOfX - (float)1 / 2) * blockWidth;
        float blockY = (floorf(index / numPerLine) + (float)1 / 2) * blockWidth;
        
        
        self.blockSprite = [CCSprite spriteWithSpriteFrameName:@"Block.png"];
        self.blockSprite.scale = blockWidth / self.blockSprite.boundingBox.size.width;
        self.blockScale = self.blockSprite.scale;
        self.blockScaleInital = self.blockSprite.scale;
        
        
        self.blockSprite.anchorPoint = ccp(0.5, 0.5);
        self.blockSprite.position = ccp(blockX + NARROW_WIDTH, 920 - blockY);
        self.initalPos = self.blockSprite.position;
        [parent addChild:self.blockSprite z:ZORDER_BLOCK];
        
        
        
    }
    return self;
}

- (void)makeBlock:(BlockStatus)blockStatusTag {
    
//    if (self.currBlockStatus == BlockStatusGone) {
//        return;
//    }
    CCSpriteFrame *frame = nil;
    switch (blockStatusTag) {
        case BlockStatusNormal:
            //
            [self.blockSprite stopActionByTag:CCActionBlockSelectedEffectTag];
            
            self.currBlockStatus = BlockStatusNormal;
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Block.png"];
            [self.blockSprite setDisplayFrame:frame];
            break;
            
        case BlockStatusSelected:
            self.currBlockStatus = BlockStatusSelected;
//            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Block_HL0.png"];
//            [self.blockSprite setDisplayFrame:frame];
            
            CCAnimation *selectedAnim = [CCAnimation animationWithFrame:@"Block_HL" frameCount:4 delay:0.2];
            CCAnimate *selectedAnimate = [CCAnimate actionWithAnimation:selectedAnim];
            CCRepeatForever *repeat = [CCRepeatForever actionWithAction:selectedAnimate];
            repeat.tag = CCActionBlockSelectedEffectTag;
            [self.blockSprite runAction:repeat];
            break;
            
        case BlockStatusGone:
            //
            self.currBlockStatus = BlockStatusGone;
            [self.blockSprite stopAllActions];
            self.blockSprite.visible = NO;
            break;
            
        case BlockStatusBomb:
            //
            self.currBlockStatus = BlockStatusBomb;
            [self.blockSprite setOpacity:80];
            break;
            
        case BlockStatusSmall:
            self.currBlockStatus = BlockStatusSmall;
            self.blockSprite.scale = self.blockSprite.scale * 2 / 3;
            self.blockScale = self.blockSprite.scale;
            break;
            
        case BlockStatusBouns:
            self.currBlockStatus = BlockStatusBouns;
//            self.blockSprite.scale = self.blockSprite.scale * 4 / 5;
//            self.blockScale = self.blockSprite.scale;
            break;
            
        default:
            break;
    }
}

- (BOOL)isBlockSelected {
    return (self.currBlockStatus == BlockStatusSelected);
}

- (BOOL)isBlockGone {
    return (self.currBlockStatus == BlockStatusGone);
}

- (BOOL)isBlockNormal {
    return (self.currBlockStatus == BlockStatusNormal);
}

- (BOOL)isBlockBouns {
    return (self.currBlockStatus == BlockStatusBouns);
}

- (BOOL)isBlockSmall {
    return (self.currBlockStatus == BlockStatusSmall || self.blockSprite.scale < self.blockScaleInital);
}

- (BOOL)isBlockBomb {
    return (self.currBlockStatus == BlockStatusBomb || self.blockSprite.opacity < 255);
}

- (BOOL)isBlockHadItemEffect {
    return (self.currBlockStatus == BlockStatusBomb || self.currBlockStatus == BlockStatusSmall || self.blockSprite.scale < self.blockScaleInital || self.blockSprite.opacity < 255);
}

- (void)resetBlockBackToInitalStatus {

    self.blockSprite.scale = self.blockScaleInital;
    self.blockSprite.opacity = 255;
    [self.blockSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Block.png"]];
    self.blockSprite.visible = YES;
    self.currBlockStatus = BlockStatusNormal;
    self.blockScale = self.blockScaleInital;
    self.blockSprite.position = self.initalPos;
    
    self.blockSprite.color = ccc3(255, 255, 255);
    
}

- (void)blockSpriteStopActionByTag:(int)tag {
    [self.blockSprite stopActionByTag:tag];
}

- (void)blockSpriteRunAction:(CCAction *)action {
    [self.blockSprite runAction:action];
}

- (CGRect)blockSpriteBoundingBox {
    return self.blockSprite.boundingBox;
}


@end
