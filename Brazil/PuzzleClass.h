//
//  PuzzleClass.h
//  Brazil
//
//  Created by zhaozilong on 13-10-31.
//
//

#import <Foundation/Foundation.h>

@interface PuzzleClass : NSObject

@property (assign)int idKey;
@property (nonatomic, retain)NSString *picName;
@property (nonatomic, retain)NSString *answerCN;
@property (nonatomic, retain)NSString *answerJA;
@property (nonatomic, retain)NSString *answerEN;
@property (nonatomic, retain)NSString *groupName;
@property (assign)int wordNum;

@property (nonatomic, retain)NSString *answer;

@property (nonatomic, retain)NSString *wordMixes;



//Kayac's
@property (nonatomic, retain)NSString *Hiragana;
@property (nonatomic, retain)NSString *Position;

+ (PuzzleClass *)puzzleWithIdKey:(int)idKey picName:(NSString *)picName answerCN:(NSString *)CN JA:(NSString *)JA EN:(NSString *)EN groupName:(NSString *)groupName wordNum:(int)wordNum;

@end
