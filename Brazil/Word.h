//
//  Word.h
//  Brazil
//
//  Created by zhaozilong on 13-10-27.
//
//

#import <Foundation/Foundation.h>
//#import "cocos2d.h"

typedef enum {
    WordStatusNormal,
    WordStatusWrong,
}WordStatus;

@interface Word : NSObject

@property (nonatomic, retain)CCSprite *wordSprite;
@property (nonatomic, retain)NSString *wordString;
@property (assign)BOOL isAtHome;
@property (assign)int currBlankIndex;


+ (id)wordWithStatus:(WordStatus)status word:(NSString *)wordStr squareIndex:(int)index parentNode:(CCNode *)parent;

//回到原来的位置
- (void)backHome;

//去到指定的答案位置
- (void)goToPosition:(CGPoint)point;

- (void)resetWordWithString:(NSString *)newWord;

- (void)changeWordStatusTo:(WordStatus)wordStatus;

@end
