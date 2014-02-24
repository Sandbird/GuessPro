//
//  Word.m
//  Brazil
//
//  Created by zhaozilong on 13-10-27.
//
//

#import "Word.h"

#define TAG_WORD_LABEL 321

@interface Word()

@property (assign)float posX;
@property (assign)float posY;

@end

@implementation Word

+ (id)wordWithStatus:(WordStatus)status word:(NSString *)wordStr squareIndex:(int)index parentNode:(CCNode *)parent {
    return [[[self alloc] initWithStatus:status word:wordStr squareIndex:index parent:parent] autorelease];
}

- (id)initWithStatus:(WordStatus)status word:(NSString *)wordStr squareIndex:(int)index parent:(CCNode *)parent {
    self = [super init];
    if (self) {
        
        self.isAtHome = YES;
        
        self.wordString = wordStr;
        
        int numPerLine = 8;
        float wordWidth = 96;
        
        
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
        
//        CCLabelTTF *wordLabel = [CCLabelTTF labelWithString:self.wordString fontName:@"MarkerFelt-Thin" fontSize:30];
        CCLabelTTF *wordLabel = [CCLabelTTF labelWithString:self.wordString dimensions:CGSizeMake(96, 96) alignment:NSTextAlignmentCenter fontName:@"HiraKakuProN-W6" fontSize:96];
        wordLabel.color = ccBLACK;
        wordLabel.tag = TAG_WORD_LABEL;
        
        wordLabel.anchorPoint = ccp(0, 0);
        wordLabel.position = ccp(0, 0);
        [self.wordSprite addChild:wordLabel];
        
        
    }
    return self;
}

- (void)backHome {
    CCMoveTo *backToPos = [CCMoveTo actionWithDuration:0.2 position:ccp(self.posX, self.posY)];
    [self.wordSprite runAction:backToPos];
    
    self.isAtHome = YES;
}

- (void)goToPosition:(CGPoint)point {
    CCMoveTo *goToPos = [CCMoveTo actionWithDuration:0.2 position:point];
    [self.wordSprite runAction:goToPos];
    
    self.isAtHome = NO;
}

- (void)resetWordWithString:(NSString *)newWord {
    CCLabelTTF *wordLabel = (CCLabelTTF *)[self.wordSprite getChildByTag:TAG_WORD_LABEL];
    [wordLabel setString:newWord];
    
    self.wordString = newWord;

}



@end
