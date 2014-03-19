//
//  Word.m
//  Brazil
//
//  Created by zhaozilong on 13-10-27.
//
//

#import "Word.h"
#import "GuessScene.h"

#define TAG_WORD_LABEL 321
#define TAG_ACTION_WORD_RED 222

@interface Word()

@property (assign)float posX;
@property (assign)float posY;

@property (nonatomic, assign)WordStatus wordStatus;

@end

@implementation Word

+ (id)wordWithStatus:(WordStatus)status word:(NSString *)wordStr squareIndex:(int)index parentNode:(CCNode *)parent {
    return [[[self alloc] initWithStatus:status word:wordStr squareIndex:index parent:parent] autorelease];
}

- (id)initWithStatus:(WordStatus)status word:(NSString *)wordStr squareIndex:(int)index parent:(CCNode *)parent {
    self = [super init];
    if (self) {
        
        self.wordStatus = status;
        
        self.isAtHome = YES;
        
        self.wordString = wordStr;
        
        int numPerLine = 8;
        float wordWidth = [GPNavBar isiPad] ? 96 : 40;
        
        
        int row = floorf((float)index / numPerLine);
        int colum = (index % numPerLine) + 1;
        
        float wordX = ((float)colum - (float)1 / 2) * wordWidth;
        float wordY = (row + (float)1 / 2) * wordWidth;
        
        self.posX = wordX;
        self.posY = wordY;
        
        self.wordSprite = [CCSprite spriteWithSpriteFrameName:@"WordBlank.png"];
        self.wordSprite.scale = wordWidth / self.wordSprite.boundingBox.size.width;
        
        
        self.wordSprite.anchorPoint = ccp(0.5, 0.5);
        self.wordSprite.position = ccp(wordX, wordY);
        [parent addChild:self.wordSprite z:ZORDER_WORD_HOME];
        
        CGSize wordSize = self.wordSprite.boundingBox.size;
//        CCLabelTTF *wordLabel = [CCLabelTTF labelWithString:self.wordString dimensions:/*CGSizeMake(wordWidth - 20, wordWidth - 20)*/wordSize alignment:NSTextAlignmentCenter fontName:@"HiraKakuProN-W6" fontSize:[GPNavBar isiPad] ? 76 : 20];
        
       CCLabelTTF *wordLabel =  [CCLabelTTF labelWithString:self.wordString dimensions:wordSize alignment:NSTextAlignmentCenter vertAlignment:CCVerticalAlignmentCenter lineBreakMode:NSLineBreakByWordWrapping fontName:FONTNAME_OF_TEXT fontSize:[GPNavBar isiPad] ? 76 : 30];
        wordLabel.color = ccBLACK;
        wordLabel.tag = TAG_WORD_LABEL;
        
        CGFloat wordPosX = self.wordSprite.boundingBox.size.width / 2 + ([GPNavBar isiPad] ? 0 : 3);
        wordLabel.anchorPoint = ccp(0.5, 0.5);
        wordLabel.position = ccp(wordPosX, wordPosX);
        [self.wordSprite addChild:wordLabel];
        
        
    }
    return self;
}

- (void)backHome {
    CCMoveTo *backToPos = [CCMoveTo actionWithDuration:0.1 position:ccp(self.posX, self.posY)];
    [self.wordSprite runAction:backToPos];
    
    self.isAtHome = YES;
}

- (void)goToPosition:(CGPoint)point {
    CCMoveTo *goToPos = [CCMoveTo actionWithDuration:0.1 position:point];
//    CCCallBlock *checkIsWin = [CCCallBlock actionWithBlock:^{
//        [[GuessScene sharedGuessScene] checkWinOrLose];
//    }];
//    
//    CCSequence *action = [CCSequence actionOne:goToPos two:checkIsWin];
    [self.wordSprite runAction:goToPos];
    
    self.isAtHome = NO;
}

- (void)resetWordWithString:(NSString *)newWord {
    CCLabelTTF *wordLabel = (CCLabelTTF *)[self.wordSprite getChildByTag:TAG_WORD_LABEL];
    [wordLabel setString:newWord];
    
    self.wordString = newWord;

}

- (void)changeWordStatusTo:(WordStatus)wordStatus {
    
    self.wordStatus = wordStatus;
    CGFloat interval = 0.1;
    
    CCTintTo *changeNormal = [CCTintTo actionWithDuration:interval red:255 green:255 blue:255];
    if (self.wordStatus == WordStatusNormal) {
        [self.wordSprite stopActionByTag:TAG_ACTION_WORD_RED];
        CCRotateTo *rotateToNormal = [CCRotateTo actionWithDuration:interval angle:0];
        CCSpawn *normalAction = [CCSpawn actionOne:changeNormal two:rotateToNormal];
        
        [self.wordSprite runAction:normalAction];
    } else if (self.wordStatus == WordStatusWrong) {
//        CCTintTo *changeColor = [CCTintTo actionWithDuration:8*interval red:192 green:53 blue:62];
//        CCSequence *cNormalToColor = [CCSequence actionOne:changeColor two:changeNormal];//16
        CCRotateTo *rotateL = [CCRotateTo actionWithDuration:interval angle:-10];
        CCRotateTo *rotateR = [CCRotateTo actionWithDuration:interval angle:10];
        CCSequence *rotateLR = [CCSequence actionOne:rotateL two:rotateR];//2
//        CCRepeat *repeatRotate = [CCRepeat actionWithAction:rotateLR times:8];
//        CCSpawn *rotateAndBlink = [CCSpawn actionOne:cNormalToColor two:repeatRotate];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:rotateLR];
        repeat.tag = TAG_ACTION_WORD_RED;
        [self.wordSprite runAction:repeat];
    }
}



@end
