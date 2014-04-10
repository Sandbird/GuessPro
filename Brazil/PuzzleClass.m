//
//  PuzzleClass.m
//  Brazil
//
//  Created by zhaozilong on 13-10-31.
//
//

#import "PuzzleClass.h"

@implementation PuzzleClass

- (void)dealloc {
//    [_tips release];
//    [_answer release];
    [super dealloc];
}

+ (PuzzleClass *)puzzleWithIdKey:(int)idKey picName:(NSString *)picName answerCN:(NSString *)CN JA:(NSString *)JA EN:(NSString *)EN groupName:(NSString *)groupName wordNum:(int)wordNum {
    return [[[self alloc] initWithIdKey:idKey picName:picName answerCN:CN JA:JA EN:EN groupName:groupName wordNum:wordNum] autorelease];
}

- (id)initWithIdKey:(int)idKey picName:(NSString *)picName answerCN:(NSString *)CN JA:(NSString *)JA EN:(NSString *)EN groupName:(NSString *)groupName wordNum:(int)wordNum {
    self = [super init];
    if (self) {
        self.idKey = idKey;
        self.picName = picName;
//        self.picName = [NSString stringWithFormat:@"00%d.png", idKey];
        
        //本地化，
        self.answer = CN;
        
//        self.answerCN = CN;
        self.answerEN = EN;
        self.answerJA = JA;
        self.groupName = groupName;
        self.wordNum = wordNum;
    }
    
    return self;
}

@end
