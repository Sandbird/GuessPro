//
//  WordBlank.h
//  Brazil
//
//  Created by zhaozilong on 13-10-29.
//
//

#import <Foundation/Foundation.h>

@interface WordBlank : NSObject

@property (nonatomic, retain)CCSprite *blankSprite;

@property (assign)CGPoint point;

@property (nonatomic, retain)NSString *fillWord;

+ (id)blankWithSquareIndex:(int)index squareNum:(int)totalNum parentNode:(CCNode *)parent;

@end
