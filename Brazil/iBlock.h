//
//  iBlock.h
//  Brazil
//
//  Created by zhaozilong on 13-10-26.
//
//

#import <Foundation/Foundation.h>
#import "CCAnimationHelper.h"

#define NARROW_WIDTH ([GPNavBar isiPad] ? 134.0f : 60.0f)

@interface iBlock : NSObject

@property (assign)int squareIndex;



@property (assign)float blockScale;

+ (id)blockWithStatus:(BlockStatus)status squareIndex:(int)index squareNum:(int)totalNum parentNode:(CCNode *)parent;

- (void)makeBlock:(BlockStatus)blockStatusTag;

- (BOOL)isBlockSelected;
- (BOOL)isBlockGone;
- (BOOL)isBlockNormal;
- (BOOL)isBlockBouns;
- (BOOL)isBlockSmall;
- (BOOL)isBlockBomb;

//这个block是否已经有效果了，主要是small和bomb的效果
- (BOOL)isBlockHadItemEffect;


//封装blockSprite，避免直接操作BlockSprite
- (void)resetBlockBackToInitalStatus;
- (void)blockSpriteStopActionByTag:(int)tag;
- (void)blockSpriteRunAction:(CCAction *)action;
- (CGRect)blockSpriteBoundingBox;

- (void)makeBlockBackToStatusBeforeFlyItem;

@end
