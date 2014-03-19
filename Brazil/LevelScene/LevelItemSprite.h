//
//  LevelLayer.h
//  CommanderCool
//
//  Created by Florian Strauß & Christian Janzen on 26.05.11.
//  Copyright 2011 Janzen & Strauß. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LevelItemSprite : CCSprite {
    
}
@property (nonatomic) int stars;
@property (nonatomic) int levelIndex;
@property (nonatomic) BOOL special;
@property (nonatomic) BOOL completed;
@property (nonatomic) int type;


+ (id)layerWithLevelIndex:(int)index stars:(int)stars hasSpecial:(BOOL)special isCompleted:(BOOL)completed withType:(int)type;
- (id)initWithLevelIndex:(int)index stars:(int)stars hasSpecial:(BOOL)special isCompleted:(BOOL)completed withType:(int)type;

- (LevelItemSprite *)activeItem;

- (void)setupLayer;
@end
