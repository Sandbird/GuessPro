//
//  GuessScene.m
//  Brazil
//
//  Created by zhaozilong on 13-10-26.
//
//

#import "GuessScene.h"
#import "iBlock.h"
#import "Word.h"
#import "WordBlank.h"
#import "GPDatabase.h"
#import "SuccessLayer.h"

//所有的位置坐标
typedef struct FixedPostion {
    CGPoint readyItemSmall;
    CGPoint readyItemBomb;
    CGPoint readyItemFlying;
    
    CGPoint closeItemSmall;
    CGPoint closeItemBomb;
    CGPoint closeItemFlying;
    
    CGPoint pictrue;
}FixedPostionSet;




//item的状态
typedef enum {
    ItemEffectSmall,
    ItemEffectBomb,
    ItemEffectFlying,
    ItemEffectNONE,
}ItemEffectStatus;


typedef enum {
    ItemSmallMinusScore = 5,
    ItemBombMinusScore = 10,
    ItemFlyingMinusScore = 50,
}ItemMinusScore;


@interface GuessScene() {
    int _totalSquareNum;
    
    CCMenu *_itemMenu;
    BOOL _isBombReady;
    BOOL _isSmallReady;
    BOOL _isFlyReady;
    
    CCSprite *_picSprite;
    
//    CCTexture2D *_picTexture;
    
    BOOL _blockTouchLocked;
    BOOL _wordTouchLocked;
    
    FixedPostionSet _FPSet;
    
}
@property (nonatomic, retain)NSMutableArray *blockArray;
@property (nonatomic, retain)NSMutableArray *wordArray;
@property (nonatomic, retain)NSMutableArray *blankArray;

@property (nonatomic, retain)NSMutableArray *picSequenceArray;
@property (nonatomic, retain)NSString *answerStr;
@property (nonatomic, assign)GPNavBar *navBar;

@property (nonatomic, retain)PuzzleClass *currPuzzle;
@property (assign)int currPuzzleIndex;

//@property (nonatomic, retain)BOOL isBlankFull;

@property (assign)int currBlankIndex;
@property (assign)RecivedStatus currRecivedStatus;

@property (assign)int totalScore;
@property (assign)int currPuzzleScore;

@end

@implementation GuessScene

static GuessScene *instanceOfGuessScene;

- (void)dealloc {
    CCLOG(@"Puzzle Dealloc");
    
    [self.blockArray release];
    [self.wordArray release];
    [self.blankArray release];
    [self.picSequenceArray release];
    
    //    [GuessScene unloadEffectMusic];
    
    //    [SimpleAudioEngine end];
    instanceOfGuessScene = nil;
    [super dealloc];
}

+ (GuessScene *)sharedGuessScene {
    NSAssert(instanceOfGuessScene != nil, @"EatFuritsScene instance not yet initialized!");
	return instanceOfGuessScene;
}

+ (CCScene *)sceneWithPuzzleNum:(int)puzzleNum {
    CCScene *scene = [CCScene node];
    
    GuessScene *layer = [[[GuessScene alloc] initWithPuzzleNum:puzzleNum] autorelease];
    
    [scene addChild:layer];
    
    return scene;
}

- (id)initWithPuzzleNum:(int)puzzleNum {
    if (self = [super init]) {
        instanceOfGuessScene = self;
        
        //加载帧到缓存
        CCSpriteFrameCache *framCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [framCache addSpriteFramesWithFile:@"GPNavBar.plist"];
        
        //touch is enabled
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
        
        //初始位置设定
        [self setInitalPosition];
        
        
        //分配内存
        _blockArray = [[NSMutableArray alloc] init];
        _wordArray = [[NSMutableArray alloc] init];
        _blankArray = [[NSMutableArray alloc] init];
        
        //全部的分数,应该从本地读取
        self.totalScore = 500;
        
        //本张图片的分数，应该从本地读取
        self.currPuzzleScore = 0;
        
        //是否允许触摸
        _blockTouchLocked = NO;
        _wordTouchLocked = NO;
        
        //照片背后的框
        CCSprite *backBoraderSprite = [CCSprite spriteWithSpriteFrameName:@"outSide.png"];
        backBoraderSprite.anchorPoint = ccp(0.5, 0.5);
        backBoraderSprite.position = _FPSet.pictrue;
        [self addChild:backBoraderSprite z:ZORDER_PICTRUE];
        
        //道具初始状态
        self.currRecivedStatus = RecivedStatusNormal;
        
        //道具
        [self setItemMenu];
        
        //NavBar
        _navBar = [GPNavBar node];
        [self addChild:_navBar z:ZORDER_NAV_BAR];
        [_navBar setTotalLabelScore:self.totalScore];
        if (IS_KAYAC) {
            [_navBar setTipsLabelStr:self.currPuzzle.Hiragana];
        }
        
        [self startPuzzleWithLevelNum:puzzleNum];
        
        /*
        
        //获得PuzzleClass
        GPDatabase *gpdb = [[GPDatabase alloc] init];
        [gpdb openBundleDatabaseWithName:@"PuzzleDatabase.sqlite"];
        _picSequenceArray = [gpdb PuzzleSequenceIsOutOfOrder:NO groupName:PuzzleGroupALL];
        self.currPuzzleIndex = 0;
        int indexOfPic = [[self.picSequenceArray objectAtIndex:self.currPuzzleIndex] integerValue];
        self.currPuzzle = [gpdb puzzlesWithGroup:PuzzleGroupMovies indexOfPic:indexOfPic];
        [gpdb close];
        [gpdb release];
        
        //答案字符串
        self.answerStr = self.currPuzzle.answer;
        
        //设置图片
        [self resetPictrue];
        
        //block
        iBlock *block = nil;
        _totalSquareNum = 49;
        for (int i = 0; i < _totalSquareNum; i++) {
            block = [iBlock blockWithStatus:BlockStatusNormal squareIndex:i squareNum:_totalSquareNum parentNode:self];
            [self.blockArray addObject:block];
            
        }
        
        //WordBlank
        [self resetWordBlankArray];
        
        
        //Word
        Word *word = nil;
        for (int i = 0; i < NUM_OF_WORD_SELECTED; i++) {
            word = [Word wordWithStatus:WordStatusNormal word:[self.currPuzzle.wordMixes substringWithRange:NSMakeRange(i, 1)] squareIndex:i parentNode:self];
            [self.wordArray addObject:word];
            
        }
         
         */
        
    }
    
    return self;
}

- (void)startPuzzleWithLevelNum:(int)levelNum {
    
    //获得PuzzleClass
    GPDatabase *gpdb = [[GPDatabase alloc] init];
    [gpdb openBundleDatabaseWithName:@"PuzzleDatabase.sqlite"];
    _picSequenceArray = [gpdb PuzzleSequenceIsOutOfOrder:NO groupName:PuzzleGroupALL];
    self.currPuzzleIndex = levelNum;
    int indexOfPic = [[self.picSequenceArray objectAtIndex:self.currPuzzleIndex] integerValue];
    self.currPuzzle = [gpdb puzzlesWithGroup:PuzzleGroupMovies indexOfPic:indexOfPic];
    [gpdb close];
    [gpdb release];
    
    //答案字符串
    self.answerStr = self.currPuzzle.answer;
    
    //设置图片
    [self resetPictrue];
    
    //block
    iBlock *block = nil;
    _totalSquareNum = 49;
    for (int i = 0; i < _totalSquareNum; i++) {
        block = [iBlock blockWithStatus:BlockStatusNormal squareIndex:i squareNum:_totalSquareNum parentNode:self];
        [self.blockArray addObject:block];
        
    }
    
    //WordBlank
    [self resetWordBlankArray];
    
    
    //Word
    Word *word = nil;
    for (int i = 0; i < NUM_OF_WORD_SELECTED; i++) {
        word = [Word wordWithStatus:WordStatusNormal word:[self.currPuzzle.wordMixes substringWithRange:NSMakeRange(i, 1)] squareIndex:i parentNode:self];
        [self.wordArray addObject:word];
        
    }
}

- (void)setInitalPosition {
    _FPSet.readyItemSmall = ccp(0, 750);
    _FPSet.readyItemBomb = ccp(0, 650);
    _FPSet.readyItemFlying = ccp(0, 550);
    
    _FPSet.closeItemSmall = ccp(-30, 750);
    _FPSet.closeItemBomb = ccp(-30, 650);
    _FPSet.closeItemFlying = ccp(-30, 550);
    
    _FPSet.pictrue = ccp(134 + 250, 920 - 250);
}

#pragma mark - Item Menu Event

- (void)setItemMenu {
    
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
     //加返回按钮和主页按钮
     //设一个全局变量，点到游戏中的时候，改变这个值，根据这个值判断返回哪个layer
    CCSprite *bombSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemBomb.png"]];
    CCMenuItem *bombItem = [CCMenuItemImage itemFromNormalSprite:bombSprite selectedSprite:nil target:self selector:@selector(bombItemPressed)];
    bombItem.tag = CCMenuItemBombTag;
    _isBombReady = NO;
    
    CCSprite *smallSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemSmall.png"]];
    CCMenuItem *smallItem = [CCMenuItemImage itemFromNormalSprite:smallSprite selectedSprite:nil target:self selector:@selector(smallItemPressed)];
    smallItem.tag = CCMenuItemSmallTag;
    _isSmallReady = NO;
    
    CCSprite *flySprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemFly.png"]];
    CCMenuItem *flyItem = [CCMenuItemImage itemFromNormalSprite:flySprite selectedSprite:nil target:self selector:@selector(flyItemPressed)];
    flyItem.tag = CCMenuItemFlyingTag;
    _isFlyReady = NO;
     
    _itemMenu = [CCMenu menuWithItems:smallItem, bombItem, flyItem, nil];
    
    _itemMenu.position = ccp(0, 0);
    
    smallItem.anchorPoint = ccp(0, 0.5);
    smallItem.position = _FPSet.closeItemSmall;
    
    bombItem.anchorPoint = ccp(0, 0.5);
    bombItem.position = _FPSet.closeItemBomb;
    
    flyItem.anchorPoint = ccp(0, 0.5);
    flyItem.position = _FPSet.closeItemFlying;
    
    
    
    [self addChild:_itemMenu];
    
}

- (void)smallItemPressed {
    
    if (![self canMinusScore:ItemSmallMinusScore]) {
        return;
    }
    
    //把剩余block变回正常
    [self makeSelectedBlockNormal];
    
    CCMenuItem *smallItem = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemSmallTag];
    
    CCMoveTo *MoveIn = nil;
    if (_isSmallReady) {
        MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemSmall];
        _isSmallReady = NO;
        [smallItem runAction:MoveIn];
        
//        //执行动画
//        CCAnimation *animation = [CCAnimation animationWithFrame:@"Small" frameCount:2 delay:0.1];
//        CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
//        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animate];
//        repeat.tag = 000;
//        [smallItem. runAction:repeat];
        
//        [self makeAllBlockGreen:NO];
        [self makeBlockEffectByEffectStatus:ItemEffectSmall isEffectOn:NO];
        
        //把block的状态改成正常
        self.currRecivedStatus = RecivedStatusNormal;
        
    } else {
        _isSmallReady = YES;
        
        //停止动画
//        [smallItem stopAllActions];
//        [smallItem set]
        
        CCMoveTo *MoveOut = [CCMoveTo actionWithDuration:0.1 position:_FPSet.readyItemSmall];
        [smallItem runAction:MoveOut];
        
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusFlying];
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusBomb];
        
        //所有方块闪光
//        [self makeAllBlockGreen:YES];
        [self makeBlockEffectByEffectStatus:ItemEffectSmall isEffectOn:YES];
        
        
        self.currRecivedStatus = RecivedStatusSmall;
        
    }
    
}

- (void)bombItemPressed {
    
    if (![self canMinusScore:ItemBombMinusScore]) {
        return;
    }
    
    //把剩余block变回正常
    [self makeSelectedBlockNormal];
    
    
    CCMenuItem *bombItem = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemBombTag];
    
    CCMoveTo *MoveIn = nil;
    if (_isBombReady) {
        _isBombReady = NO;
        MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemBomb];
        [bombItem runAction:MoveIn];
        
//        [self makeAllBlockRed:NO];
        [self makeBlockEffectByEffectStatus:ItemEffectBomb isEffectOn:NO];
        
        //把block的状态改成正常
        self.currRecivedStatus = RecivedStatusNormal;
        
    } else {
        _isBombReady = YES;
        CCMoveTo *MoveOut = [CCMoveTo actionWithDuration:0.1 position:_FPSet.readyItemBomb];
        [bombItem runAction:MoveOut];
        
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusSmall];
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusFlying];
        
//        [self makeAllBlockRed:YES];
        [self makeBlockEffectByEffectStatus:ItemEffectBomb isEffectOn:YES];
        
        self.currRecivedStatus = RecivedStatusBomb;
    }
    
}

- (void)flyItemPressed {
    
    if (![self canMinusScore:ItemFlyingMinusScore]) {
        return;
    }
    
    //把剩余block变回正常
    [self makeSelectedBlockNormal];
    
    
    CCMenuItem *flyItem = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemFlyingTag];
    
    CCMoveTo *MoveIn = nil;
    if (_isFlyReady) {
        _isFlyReady = NO;
        MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemFlying];
        [flyItem runAction:MoveIn];
        
//        [self makeAllBlockBlue:NO];
        [self makeBlockEffectByEffectStatus:ItemEffectFlying isEffectOn:NO];
        
        //把block的状态改成正常
        self.currRecivedStatus = RecivedStatusNormal;
        
    } else {
        _isFlyReady = YES;
        CCMoveTo *MoveOut = [CCMoveTo actionWithDuration:0.1 position:_FPSet.readyItemFlying];
        [flyItem runAction:MoveOut];
        
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusSmall];
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusBomb];
        
//        [self makeAllBlockBlue:YES];
        [self makeBlockEffectByEffectStatus:ItemEffectFlying isEffectOn:YES];
        
        self.currRecivedStatus = RecivedStatusFlying;
    }
}

#pragma mark - Block Effect
- (void)makeSelectedBlockNormal {
    for (iBlock *tempBlock in self.blockArray) {
        if ([tempBlock isBlockSelected]) {
            [tempBlock makeBlock:BlockStatusNormal];
        }
    }
}

- (void)makeBlockEffectBackToNormalByReceivedStatus:(RecivedStatus)rStatus {
    switch (rStatus) {
        case RecivedStatusSmall:
            if (_isSmallReady) {
                _isSmallReady = NO;
                CCMoveTo *MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemSmall];
                CCMenuItem *smallItem = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemSmallTag];
                [smallItem runAction:MoveIn];
                
                //                [self makeAllBlockGreen:NO];
                [self makeBlockEffectByEffectStatus:ItemEffectSmall isEffectOn:NO];
            }
            break;
            
        case RecivedStatusBomb:
            if (_isBombReady) {
                _isBombReady = NO;
                CCMoveTo *MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemBomb];
                CCMenuItem *bombItem = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemBombTag];
                [bombItem runAction:MoveIn];
                
                //                [self makeAllBlockRed:NO];
                [self makeBlockEffectByEffectStatus:ItemEffectBomb isEffectOn:NO];
            }
            break;
            
        case RecivedStatusFlying:
            if (_isFlyReady) {
                _isFlyReady = NO;
                CCMoveTo *MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemFlying];
                CCMenuItem *flyItem = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemFlyingTag];
                [flyItem runAction:MoveIn];
                
                //                [self makeAllBlockBlue:NO];
                [self makeBlockEffectByEffectStatus:ItemEffectFlying isEffectOn:NO];
            }
            break;
            
        default:
            break;
    }
}

- (void)makeBlockEffectByEffectStatus:(ItemEffectStatus)IEStatus isEffectOn:(BOOL)isOn {
    CCNodeTag effectTag = CCNodeMAXTag;
    GLubyte red = 0.0, green = 0.0, blue = 0.0;
    switch (IEStatus) {
        case ItemEffectSmall:
            effectTag = CCActionGreenEffectTag;
            red = 137;
            green = 184;
            blue = 61;
            break;
            
        case ItemEffectBomb:
            effectTag = CCActionRedEffectTag;
            red = 192;
            green = 53;
            blue = 62;
            break;
            
        case ItemEffectFlying:
            effectTag = CCActionBlueEffectTag;
            red = 68;
            green = 177;
            blue = 186;
            break;
            
        default:
            break;
    }
    
    if (isOn) {
        for (iBlock *block in self.blockArray) {
            /*
            **飞机状态下，只要block不是gone状态就可以使用效果
            **变小或炸弹状态下，需要block不为gone并且没有small或bomb效果才可以使用效果，
            */
            if ((IEStatus == ItemEffectFlying && ![block isBlockGone]) || ((IEStatus == ItemEffectSmall || IEStatus == ItemEffectBomb) && ![block isBlockGone] && ![block isBlockHadItemEffect])) {
                CCTintTo *changeColor = [CCTintTo actionWithDuration:1.0 red:red green:green blue:blue];
                CCTintTo *changeNormal = [CCTintTo actionWithDuration:1.0 red:255 green:255 blue:255];
                CCSequence *cNormalToColor = [CCSequence actionOne:changeColor two:changeNormal];
                CCRepeatForever *repeat = [CCRepeatForever actionWithAction:cNormalToColor];
                repeat.tag = effectTag;
                [block blockSpriteRunAction:repeat];

            }
        }
    } else {
        for (iBlock *block in self.blockArray) {
            if (![block isBlockGone]) {
                
                [block blockSpriteStopActionByTag:effectTag];
                CCTintTo *changeNormal = [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255];
                [block blockSpriteRunAction:changeNormal];
            }
        }
        
        self.currRecivedStatus = RecivedStatusNormal;
    }
    
    
}

//飞机道具
- (void)blockMetFly {
    CCSprite *flySprite = [CCSprite spriteWithSpriteFrameName:@"Fly01.png"];
    flySprite.tag = CCSpriteFlyingItemTag;
    [self addChild:flySprite z:ZORDER_ITEM_FLY];
    flySprite.scale = 1.0;
    flySprite.anchorPoint = ccp(0.5, 0.5);
    flySprite.position = ccp(flySprite.boundingBox.size.width * -1 / 2, 920 - 250);
    
    _blockTouchLocked = YES;
    [self schedule:@selector(updateFly)];
}

-(void) updateFly
{
    //	NSNumber* factor = [speedFactors objectAtIndex:0];
    CCSprite *flySprite = (CCSprite *)[self getChildByTag:CCSpriteFlyingItemTag];
    CGPoint pos = flySprite.position;
    
    pos.x += 15.0 * 3;
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    // Reposition stripes when they're out of bounds
    
    flySprite.position = pos;
    
    for (iBlock *block in self.blockArray) {
        
        if ([block isBlockNormal] || [block isBlockSmall] || [block isBlockBomb]) {
            
            if (CGRectIntersectsRect(flySprite.boundingBox, [block blockSpriteBoundingBox])) {
                CCHide *hide = [CCHide action];
                CCScaleTo *little = [CCScaleTo actionWithDuration:0.1 scale:0];
                CCSequence *seq = [CCSequence actionOne:little two:hide];
                [block blockSpriteRunAction:seq];
            } else {
                CCShow *show = [CCShow action];
                CCScaleTo *big = [CCScaleTo actionWithDuration:0.1 scale:block.blockScale];
                CCSequence *seq = [CCSequence actionOne:show two:big];
                [block blockSpriteRunAction:seq];
            }
        }
        
    }
    
    if ((pos.x - flySprite.boundingBox.size.width / 2) > screenSize.width + 100) {
        [self unschedule:@selector(updateFly)];
        [flySprite removeFromParentAndCleanup:YES];
        _blockTouchLocked = NO;
    }
}

#pragma mark - Calculate Score
- (BOOL)canMinusScore:(int)minusScore {
    if (self.totalScore >= minusScore) {
        return YES;
    }
    
    return NO;
}

- (void)totalScoreMinusScore:(int)minusScore {
    self.totalScore -= minusScore;
    [_navBar setTotalLabelScore:self.totalScore];
}

- (NSMutableArray *)rowBounsArray {
    int count = self.blockArray.count;
    int numPerLine = sqrtf(count);
    NSMutableArray *bounsArray = [[NSMutableArray alloc] initWithCapacity:numPerLine];
    
    for (int i = 0; i < numPerLine; i++) {
        [bounsArray addObject:[NSNumber numberWithBool:YES]];
    }
    
    for (int i = 0; i < count; i = i + numPerLine) {
        for (int j = 0; j < numPerLine; j++) {
            iBlock *block = [self.blockArray objectAtIndex:i + j];
            if ([block isBlockGone]) {
                [bounsArray replaceObjectAtIndex:i / numPerLine withObject:[NSNumber numberWithBool:NO]];
                break;
            }
        }
    }
    
    return bounsArray;
}

- (NSMutableArray *)columBounsArray {
//    int count = self.blockArray.count;
    int numPerLine = sqrtf(_totalSquareNum);
    NSMutableArray *bounsArray = [[NSMutableArray alloc] initWithCapacity:numPerLine];
    
    for (int i = 0; i < numPerLine; i++) {
        [bounsArray addObject:[NSNumber numberWithBool:YES]];
    }
    
    for (int i = 0; i < numPerLine; i++) {
        for (int j = i; j < numPerLine * (numPerLine - 1) + (i + 1); j=j+numPerLine) {
//            NSLog(@"%d", j);
            iBlock *block = [self.blockArray objectAtIndex:j];
            if ([block isBlockGone]) {
                [bounsArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
                break;
            }
            
        }
        
//        NSLog(@"------");
    }
    
    return bounsArray;
}

- (void)playBounsAnimation {
    int numPerLine = sqrtf(_totalSquareNum);
    
    //把一行的block加入数组
    NSMutableSet *rowBounsSet = [[NSMutableSet alloc] init];
    NSMutableArray *rowBounsArray = [self rowBounsArray];
    for (int i = 0; i < numPerLine; i++) {
        BOOL isBouns = [[rowBounsArray objectAtIndex:i] boolValue];
        if (isBouns) {
            for (int m = numPerLine * i; m < numPerLine * (i + 1); m++) {
                [rowBounsSet addObject:[NSNumber numberWithInt:m]];
            }
        }
    }
    [rowBounsArray release];
    
    
    //把一列的block加入数组
    NSMutableSet *columBounsSet = [[NSMutableSet alloc] init];
    NSMutableArray *columBounsArray = [self columBounsArray];
    for (int i = 0; i < numPerLine; i++) {
        BOOL isBouns = [[columBounsArray objectAtIndex:i] boolValue];
        if (isBouns) {
            for (int m = i; m < numPerLine * (numPerLine - 1) + (i + 1); m=m+numPerLine) {
                [columBounsSet addObject:[NSNumber numberWithInt:m]];
            }
        }
    }
    [columBounsArray release];
    
    //取交集
    [rowBounsSet intersectSet:columBounsSet];
    [columBounsSet release];
    
    
    //交集中的block都是bouns的
    NSArray *bounsArray = [rowBounsSet allObjects];
    for (NSNumber *blockIndex in bounsArray) {
        int index = blockIndex.intValue;
        iBlock *block = [self.blockArray objectAtIndex:index];
        CCTintTo *changeColor = [CCTintTo actionWithDuration:0.5 red:255 green:219 blue:21];
        CCTintTo *changeNormal = [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255];
        CCSequence *cNormalGolden = [CCSequence actionOne:changeColor two:changeNormal];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:cNormalGolden];
        repeat.tag = CCActionGoldenEffectTag;
        [block makeBlock:BlockStatusBouns];
        
        [block blockSpriteRunAction:repeat];
        
        
    }
    
    [rowBounsSet release];
}

- (void)calculateScore {
    for (iBlock *block in self.blockArray) {
        if ([block isBlockNormal]) {
            self.currPuzzleScore++;
        } else if ([block isBlockBouns]) {
            self.currPuzzleScore += 2;
        }
    }
    
    //只有大于零才播放积分动画
    if (self.currPuzzleScore > 0) {
        [_navBar playScoreAnimationWithExtraScore:self.currPuzzleScore totalScore:self.totalScore];
        self.totalScore += self.currPuzzleScore;
        self.currPuzzleScore = 0;
    }
}

- (void)blocksFlyToScoreAndDisappear {
    float time = 0.0;
    for (iBlock *block in self.blockArray) {
        
        ccBezierConfig bc = {ccp(40, 980), ccp(800, 0), ccp(0, 800),};
        
        
        time+=0.05;
        CCBezierTo *bt = [CCBezierTo actionWithDuration:time bezier:bc];
//        CCMoveTo *moveToScore = [CCMoveTo actionWithDuration:time position:ccp(0, 1024)];
        CCScaleTo *scaleToNone = [CCScaleTo actionWithDuration:time scale:0];
        CCSpawn *moveAndScale = [CCSpawn actionOne:bt two:scaleToNone];
        
        CCDelayTime *delay = [CCDelayTime actionWithDuration:1];
        CCSequence *seq = [CCSequence actionOne:delay two:moveAndScale];
        seq.tag = CCActionBlockDisappearEffectTag;
        [block blockSpriteRunAction:seq];
    }
    
}

#pragma mark - Next Puzzle

//是否让成功板出现
- (void)successLayerIsAppear:(BOOL)isOn {
    
    SuccessLayer *sLayer = nil;
    if (isOn) {
        sLayer = [SuccessLayer node];
        [sLayer setSuccessLayerColorWithImgName:self.currPuzzle.picName];
        [sLayer setPositionLabel:self.currPuzzle.Position];
        [self addChild:sLayer];
        sLayer.tag = CCLayerSuccessLayerTag;
    } else {
        sLayer = (SuccessLayer *)[self getChildByTag:CCLayerSuccessLayerTag];
        [sLayer removeFromParentAndCleanup:YES];
    }
}

- (void)changeToNextPuzzle {
    self.currPuzzleIndex++;
    self.currRecivedStatus = RecivedStatusNormal;
    
    //获得下一个PuzzleClass
    GPDatabase *gpdb = [[GPDatabase alloc] init];
    
    [gpdb openBundleDatabaseWithName:@"PuzzleDatabase.sqlite"];
    int indexOfPic = [[self.picSequenceArray objectAtIndex:self.currPuzzleIndex] integerValue];
    self.currPuzzle = [gpdb puzzlesWithGroup:PuzzleGroupMovies indexOfPic:indexOfPic];
    [gpdb close];
    
    [gpdb release];
    
    //更换答案
    self.answerStr = self.currPuzzle.answer;
    
    //更换WordArray
    for (int i = 0; i < NUM_OF_WORD_SELECTED; i++) {
        Word *word = (Word *)[self.wordArray objectAtIndex:i];
        [word backHome];
        
        [word resetWordWithString:[self.currPuzzle.wordMixes substringWithRange:NSMakeRange(i, 1)]];
        
        [self reorderChild:word.wordSprite z:ZORDER_WORD_HOME];
        //        [self.wordArray addObject:word];
    }
    
    //调整WordBlank数组
    [self resetWordBlankArray];
    
    //Reset BlockArray
    for (iBlock *block in self.blockArray) {
        
        [block blockSpriteStopActionByTag:CCActionGoldenEffectTag];
        [block blockSpriteStopActionByTag:CCActionBlockDisappearEffectTag];
        
        [block resetBlockBackToInitalStatus];
        
//        block.blockSprite.color = ccc3(255, 255, 255);
    }
    
    //更换图片
    [self resetPictrue];
    
    //把SuccessLayer去掉
    [self successLayerIsAppear:NO];
    
    //把分数直接调整为最新的
    [_navBar stopAnimationAndSetScore:self.totalScore];
    
    if (IS_KAYAC) {
        [_navBar setTipsLabelStr:self.currPuzzle.Hiragana];
    }
}

- (void)resetPictrue {
    //如果有图片，先把图片从内存中清除
    if (_picSprite) {
        CCTexture2D *texture = _picSprite.texture;
        [_picSprite removeFromParentAndCleanup:YES];
        CCTextureCache *textureCache = [CCTextureCache sharedTextureCache];
        [textureCache removeTexture:texture];
    }
    
    _picSprite = [CCSprite spriteWithFile:self.currPuzzle.picName];
    [self addChild:_picSprite z:ZORDER_PICTRUE];
    _picSprite.anchorPoint = ccp(0.5, 0.5);
    _picSprite.position = _FPSet.pictrue;
    
    //ipad用ipadRetina的屏幕
//    _picSprite.scale = 0.5;
    
    
}

- (void)resetWordBlankArray {
    
    self.currBlankIndex = 0;
    
    //调整WordBlank数组
    for (WordBlank *wordBlank in self.blankArray) {
        [wordBlank.blankSprite removeFromParentAndCleanup:YES];
    }
    [self.blankArray removeAllObjects];
    
    WordBlank *wordBlank = nil;
    int wordNum = self.currPuzzle.wordNum;
    for (int i = 0; i < wordNum; i++) {
        wordBlank = [WordBlank blankWithSquareIndex:i squareNum:wordNum parentNode:self];
        [self.blankArray addObject:wordBlank];
        
//        if (self.currBlankIndex == i) {
//            CCRotateBy *rotate = [CCRotateBy actionWithDuration:3.0 angle:360];
//            CCRepeatForever *repeat = [CCRepeatForever actionWithAction:rotate];
//            repeat.tag = CCActionWordBlankRotateEffectTag;
//            [wordBlank.blankSprite runAction:repeat];
//        }
//        else {}
    }
    
    
    
}

#pragma mark - Touch Event

+(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    _lastTouchLocation = [GuessScene locationFromTouch:touch];
    
    iBlock *currBlock = nil;
    BOOL isTouchBlock = NO;
    for (iBlock *block in self.blockArray) {
        if (CGRectContainsPoint([block blockSpriteBoundingBox], _lastTouchLocation)) {
            isTouchBlock = YES;
            currBlock = block;
            break;
        }
    }
    
    Word *currWord = nil;
    BOOL isTouchWord = NO;
    for (Word *word in self.wordArray) {
        if (CGRectContainsPoint([word.wordSprite boundingBox], _lastTouchLocation)) {
            isTouchWord = YES;
            currWord = word;
            break;
        }
    }
    
    if (isTouchBlock || isTouchWord) {
        _isTouchHandled = YES;
    } else {
        [self makeSelectedBlockNormal];
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusSmall];
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusBomb];
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusFlying];
    }
    
    if (_isTouchHandled) {
        if (isTouchBlock && !_blockTouchLocked) {
            if (![currBlock isBlockGone]) {
                switch (self.currRecivedStatus) {
                    case RecivedStatusNormal:
                        if ([currBlock isBlockSelected]) {
                            [currBlock makeBlock:BlockStatusGone];
                        } else {
                            [self makeSelectedBlockNormal];
                            [currBlock makeBlock:BlockStatusSelected];
                        }
                        break;
                        
                    case RecivedStatusSmall:
                        if (![currBlock isBlockHadItemEffect]) {
                            [currBlock makeBlock:BlockStatusSmall];
                            [self smallItemPressed];
                            [self totalScoreMinusScore:ItemSmallMinusScore];

                        }
                        
                        break;
                        
                    case RecivedStatusBomb:
                        if (![currBlock isBlockHadItemEffect]) {
                            [currBlock makeBlock:BlockStatusBomb];
                            [self bombItemPressed];
                            [self totalScoreMinusScore:ItemBombMinusScore];
                        }
                        break;
                        
                    case RecivedStatusFlying:
                        [self blockMetFly];
                        [self flyItemPressed];
                        [self totalScoreMinusScore:ItemFlyingMinusScore];
                        break;
                        
                    default:
                        break;
                }
            }
            
        } else if (isTouchWord && !_wordTouchLocked) {//触摸的是单词
            
            [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusSmall];
            [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusBomb];
            [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusFlying];
            self.currRecivedStatus = RecivedStatusNormal;
            
            //Test if blank is full.
            BOOL isBlankFull = YES;
            for (WordBlank *blank in self.blankArray) {
                if (!blank.fillWord) {
                    isBlankFull = NO;
                    break;
                }
            }
            
            //触摸的是单词，本单词消失
            WordBlank *currBlank = nil;
            if (currWord.isAtHome && !isBlankFull) {
                [self reorderChild:currWord.wordSprite z:ZORDER_WORD_SELECTED];
                currBlank = (WordBlank *)[self.blankArray objectAtIndex:self.currBlankIndex];
                [currWord goToPosition:currBlank.point];
                currBlank.fillWord = currWord.wordString;
                currWord.currBlankIndex = self.currBlankIndex;
            } else if (!currWord.isAtHome) {
                [self reorderChild:currWord.wordSprite z:ZORDER_WORD_HOME];
                currBlank = (WordBlank *)[self.blankArray objectAtIndex:currWord.currBlankIndex];
                [currWord backHome];
                currBlank.fillWord = nil;
            }
            
            int countIndex = 0;
            BOOL isIn = YES;
            for (WordBlank *blank in self.blankArray) {
                if (!blank.fillWord && isIn) {
                    self.currBlankIndex = countIndex;
//                    isIn = NO;
                    
                    
                    //执行动画
//                    CCRotateTo *rotate = [CCRotateTo actionWithDuration:1.0 angle:180];
//                    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:rotate];
//                    repeat.tag = CCActionWordBlankRotateEffectTag;
//                    [blank.blankSprite runAction:repeat];
                    
                    break;
                }
//                else {
//                    [blank.blankSprite stopActionByTag:CCActionWordBlankRotateEffectTag];
//                }
                countIndex++;
            }
            
            if (countIndex >= self.blankArray.count) {
                //可以计算结果了，都选择完了
                NSString *customAnswer = @"";
                for (WordBlank *blank in self.blankArray) {
                    customAnswer = [customAnswer stringByAppendingString:blank.fillWord];
                }
                
                
                if ([customAnswer isEqualToString:self.answerStr]) {
                    NSLog(@"Win");
                    
                    [self makeSelectedBlockNormal];
                    
                    //显示成功板
                    [self successLayerIsAppear:YES];
                    
                    //播放bounsBlock的动画
                    [self playBounsAnimation];
                    
                    //统计分数
                    [self calculateScore];
                    
                    //播放分数统计动画
                    [self blocksFlyToScoreAndDisappear];
                    
                    
                } else {
                    NSLog(@"Lose");
                }
                
            }
            
            
        }
        
    }
    
    return _isTouchHandled;
    
}

/*
 -(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event {
 
 CGPoint currentTouchLocation = [GuessScene locationFromTouch:touch];
 
 // Take the difference of the current to the last touch location.
 CGPoint moveTo = ccpSub(_lastTouchLocation, currentTouchLocation);
 // Then reverse it since the goal is not to give the impression of moving the camera over the background,
 // but to touch and move the background.
 moveTo = ccpMult(moveTo, -1);
 
 _lastTouchLocation = currentTouchLocation;
 
 // Adjust the layer's position accordingly, this will change the position of all nodes it contains too.
 //	fruitSprite.position = ccpAdd(fruitSprite.position, moveTo);
 }
 
 - (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
 //    _isTouchHandled = NO;
 
 // Move the game layer back to its designated position.
 //	CCMoveTo* move = [CCMoveTo actionWithDuration:0.1 position:_defaultPosition];
 //	CCEaseIn* ease = [CCEaseIn actionWithAction:move rate:0.5f];
 
 //	[fruitSprite runAction:ease];
 
 }
 */

- (void)onExit {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

@end
