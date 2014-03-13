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

//#import <AGCommon/UINavigationBar+Common.h>
//#import <AGCommon/UIImage+Common.h>
//#import <AGCommon/UIColor+Common.h>
//#import <AGCommon/UIDevice+Common.h>
//#import <AGCommon/NSString+Common.h>


#define TAG_ALERT_ITEM_TIPS     111
#define TAG_ALERT_ITEM_ANSWER   222
#define TAG_ALERT_ITEM_SHARE    555

#define TAG_ALERT_SHOW_TIPS     333
#define TAG_ALERT_SHOW_ANSWER   444

//所有的位置坐标
typedef struct FixedPostion {
    //左边三个道具
    CGPoint readyItemSmall;
    CGPoint readyItemBomb;
    CGPoint readyItemFlying;
    
    CGPoint closeItemSmall;
    CGPoint closeItemBomb;
    CGPoint closeItemFlying;
    
    //右边三个道具
    CGPoint closeItemTips;
    CGPoint closeItemAnswer;
    CGPoint closeItemShare;
    
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
    ItemFlyingMinusScore = 20,
    ItemTipsMinusScore = 30,
    ItemAnswerMinusScore = 100,
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
    
    CCSpriteBatchNode *_blockBatch;
    CCSpriteBatchNode *_wordBatch;
    
}
@property (nonatomic, retain)NSMutableArray *blockArray;
@property (nonatomic, retain)NSMutableArray *wordArray;
@property (nonatomic, retain)NSMutableArray *blankArray;


@property (nonatomic, retain)NSMutableArray *picSequenceArray;
@property (nonatomic, retain)NSString *answerStr;


@property (nonatomic, retain)PuzzleClass *currPuzzle;
@property (assign)int currPuzzleIndex;

//@property (nonatomic, retain)BOOL isBlankFull;

@property (assign)int currBlankIndex;
@property (assign)RecivedStatus currRecivedStatus;

@property (assign)int totalScore;
@property (assign)int currPuzzleScore;

@property (assign)BOOL isNeedRestoreScene;

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

+ (CCScene *)sceneWithPuzzleNum:(int)levelNum {
    CCScene *scene = [CCScene node];
    
    GuessScene *layer = [[[GuessScene alloc] initWithPuzzleNum:levelNum] autorelease];
    
    [scene addChild:layer];
    
    return scene;
}

- (id)initWithPuzzleNum:(int)levelNum {
    if (self = [super init]) {
        instanceOfGuessScene = self;
        
        self.isTouchEnabled = YES;
        
        //加载帧到缓存
        CCSpriteFrameCache *framCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [framCache addSpriteFramesWithFile:[AssetHelper getDeviceSpecificFileNameFor:@"GuessPro.plist"]];
        
        //初始位置设定
        [self setInitalPosition];
        
        
        //分配内存
        _blockArray = [[NSMutableArray alloc] init];
        _wordArray = [[NSMutableArray alloc] init];
        _blankArray = [[NSMutableArray alloc] init];
        
        /*稍后修改
        CCSpriteFrame *blockFrame = [framCache spriteFrameByName:@"Block.png"];
        _blockBatch = [CCSpriteBatchNode batchNodeWithTexture:blockFrame.texture];
        [self addChild:_blockBatch z:ZORDER_BLOCK];
        
        CCSpriteFrame *wordFrame = [framCache spriteFrameByName:@"WordBlank.png"];
        _wordBatch = [CCSpriteBatchNode batchNodeWithTexture:wordFrame.texture];
        [self addChild:_wordBatch z:ZORDER_WORD_HOME];
         */
        
        self.isNeedRestoreScene = YES;
        
        //本张图片的分数，应该从本地读取
        self.currPuzzleScore = 0;
        
        //是否允许触摸
        _blockTouchLocked = NO;
        _wordTouchLocked = NO;
        
        //道具初始状态
        self.currRecivedStatus = RecivedStatusNormal;
        
        //道具
        [self setItemMenu];
        
        //NavBar
        _navBar = [[[GPNavBar alloc] initWithIsFromPlaying:YES] autorelease];
        [self addChild:_navBar z:ZORDER_NAV_BAR];
//        if (IS_KAYAC) {
//            [_navBar setTipsLabelStr:self.currPuzzle.Hiragana];
//        }
        
        NSInteger continueLevelNum = [_navBar continueLevel];
        BOOL isNeedRestore = [_navBar isNeedRestoreScene];
        
        if (levelNum == continueLevelNum && isNeedRestore) {
            [self loadContinuePuzzleWithLevelNum:levelNum];
        } else {
            [self startPuzzleWithLevelNum:levelNum];
        }
        
        //照片背后的框
        CCSprite *backBoraderSprite = [CCSprite spriteWithSpriteFrameName:@"outSide.png"];
        backBoraderSprite.anchorPoint = ccp(0.5, 0.5);
        CGFloat shouldWidth = ([GPNavBar isiPad] ? 468 : 228.8f);
        CGFloat currWidth = backBoraderSprite.boundingBox.size.width;
        backBoraderSprite.scale = shouldWidth / currWidth;
        backBoraderSprite.position = _FPSet.pictrue;
        [self addChild:backBoraderSprite z:ZORDER_PICTRUE];
    }
    
    return self;
}

- (void)registerWithTouchDispatcher {
    //touch is enabled
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
}

- (void)loadContinuePuzzleWithLevelNum:(int)levelNum {
    NSString *gameDataFileName = @"PlayerState";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", gameDataFileName]];
    
	NSMutableDictionary *playerState = [[[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath] autorelease];
    
    NSString *picName = [playerState objectForKey:PS_PIC_NAME];
    NSString *answerCN = [playerState objectForKey:PS_ANSWER];
    BOOL isBuiedAnswer = [[playerState objectForKey:PS_IS_BUIED_ANSWER] boolValue];
    NSString *groupName = [playerState objectForKey:PS_GROUP_NAME];
    NSInteger wordNum = [[playerState objectForKey:PS_WORD_NUM] integerValue];
    NSString *wordMixes = [playerState objectForKey:PS_WORD_MIXES];
    NSString *tips = [playerState objectForKey:PS_TIP];
    BOOL isBuiedTips = [[playerState objectForKey:PS_IS_BUY_TIP] boolValue];
    NSString *information = [playerState objectForKey:PS_INFORMATION];
    
    
    //获得PuzzleClass
    GPDatabase *gpdb = [[GPDatabase alloc] init];
    [gpdb openBundleDatabaseWithName:@"PuzzleDatabase.sqlite"];
    _picSequenceArray = [gpdb PuzzleSequenceIsOutOfOrder:NO groupName:PuzzleGroupALL];
    [gpdb close];
    [gpdb release];
    
    //还原puzzle
    self.currPuzzleIndex = levelNum;
    int indexOfPic = [[self.picSequenceArray objectAtIndex:self.currPuzzleIndex] integerValue];
    PuzzleClass * pc = [PuzzleClass puzzleWithIdKey:indexOfPic picName:picName answerCN:answerCN JA:nil EN:nil groupName:groupName wordNum:wordNum];
    pc.wordMixes = wordMixes;
    pc.isBuiedAnswer = isBuiedAnswer;
    pc.tips = tips;
    pc.isBuiedTips = isBuiedTips;
    pc.information = information;
    self.currPuzzle = pc;
    
    //设置blank和picture和block
    [self setBlankAndBlockAndPictrue];
    
    //还原现场
    //useItemArray
    NSArray *useItemGoneArray = [playerState objectForKey:PS_USE_ITEM_GONE];
    NSArray *useItemSmallArray = [playerState objectForKey:PS_USE_ITEM_SMALL];
    NSArray *useItemBombArray = [playerState objectForKey:PS_USE_ITEM_TRANS];
    
    for (NSNumber *numberGone in useItemGoneArray) {
        NSInteger goneIndex = [numberGone integerValue];
        iBlock *currBlock = [self.blockArray objectAtIndex:goneIndex];
        [currBlock makeBlock:BlockStatusGone];
    }
    
    for (NSNumber *numberSmall in useItemSmallArray) {
        NSInteger smallIndex = [numberSmall integerValue];
        iBlock *currBlock = [self.blockArray objectAtIndex:smallIndex];
        [currBlock makeBlock:BlockStatusSmall];
    }
    
    for (NSNumber *numberBomb in useItemBombArray) {
        NSInteger bombIndex = [numberBomb integerValue];
        iBlock *currBlock = [self.blockArray objectAtIndex:bombIndex];
        [currBlock makeBlock:BlockStatusBomb];
    }
    
}

- (void)saveScene {
    
    //如果此关已经打过，则不必要保存现场
    if (self.currPuzzleIndex < [_navBar continueLevel]) {
        return;
    }
    
    [_navBar setContinueLevel:self.currPuzzleIndex isNeedRestoreScene:self.isNeedRestoreScene];
    
    //如果不需要保存现场
    if (!self.isNeedRestoreScene) {
        return;
    }
    
    NSString *gameDataFileName = @"PlayerState";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", gameDataFileName]];
    
	NSMutableDictionary *playerState = [[[NSMutableDictionary alloc] init] autorelease];
    
    [playerState setObject:[NSNumber numberWithInt:self.currPuzzleIndex] forKey:PS_CONTINUE_LEVEL];
    [playerState setObject:[NSNumber numberWithInt:self.currPuzzle.idKey] forKey:PS_ID_KEY];
    [playerState setObject:self.currPuzzle.picName forKey:PS_PIC_NAME];
    [playerState setObject:self.currPuzzle.answer forKey:PS_ANSWER];
    [playerState setObject:[NSNumber numberWithBool:self.currPuzzle.isBuiedAnswer] forKey:PS_IS_BUIED_ANSWER];
    [playerState setObject:self.currPuzzle.groupName forKey:PS_GROUP_NAME];
    [playerState setObject:[NSNumber numberWithInt:self.currPuzzle.wordNum] forKey:PS_WORD_NUM];
    [playerState setObject:self.currPuzzle.wordMixes forKey:PS_WORD_MIXES];
    [playerState setObject:self.currPuzzle.tips forKey:PS_TIP];
    [playerState setObject:[NSNumber numberWithBool:self.currPuzzle.isBuiedTips] forKey:PS_IS_BUY_TIP];
    [playerState setObject:self.currPuzzle.information forKey:PS_INFORMATION];
    
    //如果正在使用fly道具，把全部的block还使用fly道具之前的状态再保存
    if (_blockTouchLocked) {
        [self unschedule:@selector(updateFly)];
        _blockTouchLocked = NO;
        CCSprite *flySprite = (CCSprite *)[self getChildByTag:CCSpriteFlyingItemTag];
        if (flySprite != nil) {
            [flySprite removeFromParentAndCleanup:YES];
        }
        
        for (iBlock *block in self.blockArray) {
            [block makeBlockBackToStatusBeforeFlyItem];
        }
    }
    
    //记录block的现场
    NSMutableArray *useItemGoneArray = [NSMutableArray array];
    NSMutableArray *useItemSmallArray = [NSMutableArray array];
    NSMutableArray *useItemBombArray = [NSMutableArray array];
    
    for (iBlock *block in self.blockArray) {
        if ([block isBlockGone]) {
            [useItemGoneArray addObject:[NSNumber numberWithInt:block.squareIndex]];
        }
        
        if ([block isBlockSmall]) {
            [useItemSmallArray addObject:[NSNumber numberWithInt:block.squareIndex]];
        }
        
        if ([block isBlockBomb]) {
            [useItemBombArray addObject:[NSNumber numberWithInt:block.squareIndex]];
        }
    }
    
    [playerState setObject:useItemGoneArray forKey:PS_USE_ITEM_GONE];
    [playerState setObject:useItemSmallArray forKey:PS_USE_ITEM_SMALL];
    [playerState setObject:useItemBombArray forKey:PS_USE_ITEM_TRANS];
    
    //保存起来
    if(![playerState writeToFile:settingsPath atomically:YES]) {
        CCLOG(@"error savePlayerState");
    }
    
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
    
    //设置blank和picture和block
    [self setBlankAndBlockAndPictrue];
}

- (void)setBlankAndBlockAndPictrue {
    
    //答案字符串
    self.answerStr = self.currPuzzle.answer;
    
    //设置图片
    [self resetPictrue];
    
    //block
    iBlock *block = nil;
    _totalSquareNum = 16;
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
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if ([GPNavBar isiPad]) {
        
        _FPSet.readyItemSmall = ccp(0, 820);
        _FPSet.readyItemBomb = ccp(0, 670);
        _FPSet.readyItemFlying = ccp(0, 520);
        
        _FPSet.closeItemSmall   = ccp(-30, 820);
        _FPSet.closeItemBomb    = ccp(-30, 670);
        _FPSet.closeItemFlying  = ccp(-30, 520);
        
        _FPSet.closeItemTips    = ccp(645+15, 820);
        _FPSet.closeItemAnswer  = ccp(645+15, 670);
        _FPSet.closeItemShare   = ccp(645+15, 520);
        
        _FPSet.pictrue = ccp(winSize.width / 2, 920 - 225);
    } else if ([GPNavBar isiPhone5]) {
        
        _FPSet.readyItemSmall = ccp(0, 820);
        _FPSet.readyItemBomb = ccp(0, 670);
        _FPSet.readyItemFlying = ccp(0, 520);
        
        _FPSet.closeItemSmall   = ccp(-15, 820);
        _FPSet.closeItemBomb    = ccp(-15, 670);
        _FPSet.closeItemFlying  = ccp(-15, 520);
        
        _FPSet.closeItemTips    = ccp(645+15, 820);
        _FPSet.closeItemAnswer  = ccp(645+15, 670);
        _FPSet.closeItemShare   = ccp(645+15, 520);
        
        _FPSet.pictrue = ccp(winSize.width / 2, 568 - 48 - PICTURE_WIDTH / 2);

    } else {
        
        _FPSet.readyItemSmall = ccp(0, 380);
        _FPSet.readyItemBomb = ccp(0, 330);
        _FPSet.readyItemFlying = ccp(0, 280);
        
        _FPSet.closeItemSmall   = ccp(-20, 380);
        _FPSet.closeItemBomb    = ccp(-20, 330);
        _FPSet.closeItemFlying  = ccp(-20, 280);
        
        _FPSet.closeItemTips    = ccp(270, 380);
        _FPSet.closeItemAnswer  = ccp(270, 330);
        _FPSet.closeItemShare   = ccp(270, 280);
        
        _FPSet.pictrue = ccp(winSize.width / 2, 480 - 38 - 10 - PICTURE_WIDTH / 2);
    }
    
    
}

#pragma mark - Item Menu Event

- (void)setItemMenu {
    
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
     //加返回按钮和主页按钮
     //设一个全局变量，点到游戏中的时候，改变这个值，根据这个值判断返回哪个layer
    CCSprite *smallSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemSmall.png"]];
//    CCSprite *smallHLSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemSmall_HL.png"]];
    CCMenuItem *smallItem = [CCMenuItemImage itemFromNormalSprite:smallSprite selectedSprite:nil target:self selector:@selector(smallItemPressed)];
    smallItem.tag = CCMenuItemSmallTag;
    _isSmallReady = NO;
    
    
    CCSprite *bombSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemBomb.png"]];
//    CCSprite *bombHLSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"Item10_HL.png"]];
    CCMenuItem *bombItem = [CCMenuItemImage itemFromNormalSprite:bombSprite selectedSprite:nil target:self selector:@selector(bombItemPressed)];
    bombItem.tag = CCMenuItemBombTag;
    _isBombReady = NO;
    
    
    CCSprite *flySprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemFly.png"]];
//    CCSprite *flyHLSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"Item50_HL.png"]];
    CCMenuItem *flyItem = [CCMenuItemImage itemFromNormalSprite:flySprite selectedSprite:nil target:self selector:@selector(flyItemPressed)];
    flyItem.tag = CCMenuItemFlyingTag;
    _isFlyReady = NO;
    
    //Tips
    CCSprite *tipsSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemTips.png"]];
    CCSprite *tipsHLSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemTips_HL.png"]];
    CCMenuItem *tipsItem = [CCMenuItemImage itemFromNormalSprite:tipsSprite selectedSprite:tipsHLSprite target:self selector:@selector(tipsItemPressed)];
    tipsItem.tag = CCMenuItemTipsTag;
    
    //Answer
    CCSprite *answerSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemAnswer.png"]];
    CCSprite *answerHLSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemAnswer_HL.png"]];
    CCMenuItem *answerItem = [CCMenuItemImage itemFromNormalSprite:answerSprite selectedSprite:answerHLSprite target:self selector:@selector(answerItemPressed)];
    answerItem.tag = CCMenuItemAnswerTag;
    
    //Share
    CCSprite *shareSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemShare.png"]];
    CCSprite *shareHLSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"ItemShare_HL.png"]];
    CCMenuItem *shareItem = [CCMenuItemImage itemFromNormalSprite:shareSprite selectedSprite:shareHLSprite target:self selector:@selector(shareItemPressed)];
    shareItem.tag = CCMenuItemShareTag;
     
    _itemMenu = [CCMenu menuWithItems:smallItem, bombItem, flyItem, tipsItem, answerItem, shareItem, nil];
    
    _itemMenu.position = ccp(0, 0);
    
    smallItem.anchorPoint = ccp(0, 0.5);
    smallItem.position = _FPSet.closeItemSmall;
    
    bombItem.anchorPoint = ccp(0, 0.5);
    bombItem.position = _FPSet.closeItemBomb;
    
    flyItem.anchorPoint = ccp(0, 0.5);
    flyItem.position = _FPSet.closeItemFlying;
    
    tipsItem.anchorPoint = ccp(0, 0.5);
    tipsItem.position = _FPSet.closeItemTips;
    
    answerItem.anchorPoint = ccp(0, 0.5);
    answerItem.position = _FPSet.closeItemAnswer;
    
    shareItem.anchorPoint = ccp(0, 0.5);
    shareItem.position = _FPSet.closeItemShare;
    
    [self addChild:_itemMenu];
    
}

- (void)smallItemPressed {
    
    //把剩余block变回正常
    [self makeSelectedBlockNormal];
    
    if (![self canMinusScore:ItemSmallMinusScore]) {
        //金币不够了，跳出购买金币界面
        [_navBar showStoreLayer];
        return;
    }
    
    CCMenuItem *smallItem = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemSmallTag];
    
    CCMoveTo *MoveIn = nil;
    if (_isSmallReady) {
        _isSmallReady = NO;
        
        MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemSmall];
        [smallItem runAction:MoveIn];
        
//        [smallItem unselected];
        
        [self makeBlockEffectByEffectStatus:ItemEffectSmall isEffectOn:NO];
        
        //把block的状态改成正常
        self.currRecivedStatus = RecivedStatusNormal;
        
    } else {
        _isSmallReady = YES;
        
        CCMoveTo *MoveOut = [CCMoveTo actionWithDuration:0.1 position:_FPSet.readyItemSmall];
        [smallItem runAction:MoveOut];

        
//        [smallItem selected];
        
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusFlying];
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusBomb];
        
        //所有方块闪光
        [self makeBlockEffectByEffectStatus:ItemEffectSmall isEffectOn:YES];
        
        
        self.currRecivedStatus = RecivedStatusSmall;
        
    }
    
}

- (void)bombItemPressed {
    
    //把剩余block变回正常
    [self makeSelectedBlockNormal];
    
    if (![self canMinusScore:ItemBombMinusScore]) {
        //金币不够了，跳出购买金币界面
        [_navBar showStoreLayer];
        return;
    }
    
    CCMenuItem *bombItem = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemBombTag];
    
    if (_isBombReady) {
        _isBombReady = NO;
        
        CCMoveTo *MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemBomb];
        [bombItem runAction:MoveIn];
        
//        [bombItem unselected];
        
        [self makeBlockEffectByEffectStatus:ItemEffectBomb isEffectOn:NO];
        
        //把block的状态改成正常
        self.currRecivedStatus = RecivedStatusNormal;
        
    } else {
        _isBombReady = YES;
        
        CCMoveTo *MoveOut = [CCMoveTo actionWithDuration:0.1 position:_FPSet.readyItemBomb];
        [bombItem runAction:MoveOut];
        
//        [bombItem selected];
        
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusSmall];
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusFlying];
        
        [self makeBlockEffectByEffectStatus:ItemEffectBomb isEffectOn:YES];
        
        self.currRecivedStatus = RecivedStatusBomb;
    }
    
}

- (void)flyItemPressed {
    
    //把剩余block变回正常
    [self makeSelectedBlockNormal];
    
    if (![self canMinusScore:ItemFlyingMinusScore]) {
        //金币不够了，跳出购买金币界面
        [_navBar showStoreLayer];
        
        return;
    }
    
    CCMenuItem *flyItem = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemFlyingTag];
    
    if (_isFlyReady) {
        _isFlyReady = NO;
        
        CCMoveTo *MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemFlying];
        [flyItem runAction:MoveIn];
        
//        [flyItem unselected];
        
        [self makeBlockEffectByEffectStatus:ItemEffectFlying isEffectOn:NO];
        
        //把block的状态改成正常
        self.currRecivedStatus = RecivedStatusNormal;
        
    } else {
        _isFlyReady = YES;
        
        CCMoveTo *MoveOut = [CCMoveTo actionWithDuration:0.1 position:_FPSet.readyItemFlying];
        [flyItem runAction:MoveOut];
        
//        [flyItem selected];
        
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusSmall];
        [self makeBlockEffectBackToNormalByReceivedStatus:RecivedStatusBomb];
        
        [self makeBlockEffectByEffectStatus:ItemEffectFlying isEffectOn:YES];
        
        self.currRecivedStatus = RecivedStatusFlying;
    }
}

- (void)tipsItemPressed {
    
    //把剩余block变回正常
    [self makeSelectedBlockNormal];
    
    if (self.currPuzzle.isBuiedTips) {
        [self showTipsAlert];
    } else {
        //显示Alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"查看提示道具" message:@"您愿意消耗50个黄金摄像机查看本关的提示么？" delegate:self cancelButtonTitle:@"不使用" otherButtonTitles:@"使用", nil];
        [alertView show];
        alertView.tag = TAG_ALERT_ITEM_TIPS;
        [alertView release];
    }
    
}

- (void)showTipsAlert {
    //标记是否购买
    self.currPuzzle.isBuiedTips = YES;
    
    //显示Alert
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示如下" message:self.currPuzzle.tips delegate:self cancelButtonTitle:@"看好了" otherButtonTitles:nil];
    [alertView show];
    alertView.tag = TAG_ALERT_SHOW_TIPS;
    [alertView release];
}

- (void)answerItemPressed {
    
    //把剩余block变回正常
    [self makeSelectedBlockNormal];
    
    if (self.currPuzzle.isBuiedAnswer) {
        [self showAnswerAlert];
    } else {
        //显示Alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"查看答案道具" message:@"您愿意消耗100个黄金摄像机查看本关的答案么？" delegate:self cancelButtonTitle:@"不使用" otherButtonTitles:@"使用", nil];
        [alertView show];
        alertView.tag = TAG_ALERT_ITEM_ANSWER;
        [alertView release];
    }
}

- (void)showAnswerAlert {
    //标记是否购买
    self.currPuzzle.isBuiedAnswer = YES;
    
    //显示Alert
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"答案如下" message:self.currPuzzle.answer delegate:self cancelButtonTitle:@"看好了" otherButtonTitles:nil];
    [alertView show];
    alertView.tag = TAG_ALERT_SHOW_ANSWER;
    [alertView release];
}

- (void)shareItemPressed {
    
    //把剩余block变回正常
    [self makeSelectedBlockNormal];
    
    [_navBar showShareBoradWithType:ShareTypeSOS];
    
//    [self shareToWeiXin];
//    [self shareToSina];
    
//    //显示Alert
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"向朋友求助" message:@"使用向朋友求助道具，分享到社交网络，可奖励10个黄金摄像机，每天最多可以奖励50个" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//    [alertView show];
//    alertView.tag = TAG_ALERT_ITEM_SHARE;
//    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_ALERT_ITEM_TIPS) {
        if (buttonIndex == 1) {
            if (![self canMinusScore:ItemTipsMinusScore]) {
                //显示购买金币界面
                [_navBar showStoreLayer];
                return;
            }
            
            //显示Alert
            [self showTipsAlert];
            
            //扣金币
            [_navBar changeTotalScore:(-1 *ItemTipsMinusScore)];
            [_navBar refreshTotalScore];
            
            
        }
    } else if (alertView.tag == TAG_ALERT_ITEM_ANSWER) {
        if (buttonIndex == 1) {
            if (![self canMinusScore:ItemAnswerMinusScore]) {
                //显示购买金币界面
                [_navBar showStoreLayer];
                return;
            }
            
            //显示Alert
            [self showAnswerAlert];
            
            //扣金币
            [_navBar changeTotalScore:(-1 *ItemAnswerMinusScore)];
            [_navBar refreshTotalScore];
        }
    } else if (alertView.tag == TAG_ALERT_SHOW_TIPS) {
        
    } else if (alertView.tag == TAG_ALERT_SHOW_ANSWER) {
        
    } else if (alertView.tag == TAG_ALERT_ITEM_SHARE) {
        
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
    CCMenuItem *item;
    switch (rStatus) {
        case RecivedStatusSmall:
            item = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemSmallTag];
            if (_isSmallReady) {
                _isSmallReady = NO;
                
                CCMoveTo *MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemSmall];
                [item runAction:MoveIn];
                
//                [item unselected];
                
                [self makeBlockEffectByEffectStatus:ItemEffectSmall isEffectOn:NO];
            }
            break;
            
        case RecivedStatusBomb:
            item = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemBombTag];
            if (_isBombReady) {
                _isBombReady = NO;
                
                CCMoveTo *MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemBomb];
                [item runAction:MoveIn];
                
//                [item unselected];
                
                [self makeBlockEffectByEffectStatus:ItemEffectBomb isEffectOn:NO];
            }
            break;
            
        case RecivedStatusFlying:
            item = (CCMenuItem *)[_itemMenu getChildByTag:CCMenuItemFlyingTag];
            if (_isFlyReady) {
                _isFlyReady = NO;
                
                CCMoveTo *MoveIn = [CCMoveTo actionWithDuration:0.1 position:_FPSet.closeItemFlying];
                [item runAction:MoveIn];
                
//                [item unselected];

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
    CGFloat shouldWidth = PICTURE_WIDTH;
    CGFloat currWidth = flySprite.boundingBox.size.width;
    flySprite.scale = shouldWidth / currWidth;
    flySprite.anchorPoint = ccp(0.5, 0.5);
    flySprite.position = ccp(flySprite.boundingBox.size.width * -1 / 2, _FPSet.pictrue.y);
    
    //判断是否有飞行道具在运行
    _blockTouchLocked = YES;
    [self schedule:@selector(updateFly)];
}

-(void) updateFly
{
    //	NSNumber* factor = [speedFactors objectAtIndex:0];
    CCSprite *flySprite = (CCSprite *)[self getChildByTag:CCSpriteFlyingItemTag];
    CGPoint pos = flySprite.position;
    
    pos.x += 15.0 * ([GPNavBar isiPad] ? 2.5 : 0.5);
    
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
    if ([_navBar scores] >= minusScore) {
        return YES;
    }
    
    return NO;
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
        if ((self.currPuzzleIndex - 1)/*因为此时的currPuzzleIndex已经是下一个puzzle的Index了，所以需要-1*/ < [_navBar continueLevel]) {
            [_navBar playScoreAnimationNoPlusExtraScore:self.currPuzzleScore];
//            [_navBar changeTotalScore:self.currPuzzleScore];
        } else {
            [_navBar playScoreAnimationWithExtraScore:self.currPuzzleScore];
            [_navBar changeTotalScore:self.currPuzzleScore];
        }
        
        
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
        [self addChild:sLayer z:self.zOrder + 1];
        sLayer.tag = CCLayerSuccessLayerTag;
        
        [sLayer setCurrentPuzzleInfo:self.currPuzzle.information];
        
        //把上一个layer的touch事件都暂停。
        self.isTouchEnabled = NO;
        _itemMenu.isTouchEnabled = NO;
        
    } else {
        sLayer = (SuccessLayer *)[self getChildByTag:CCLayerSuccessLayerTag];
        [sLayer removeFromParentAndCleanup:YES];
        
        //把上一个layer的touch事件重新开启。
        self.isTouchEnabled = YES;
        _itemMenu.isTouchEnabled = YES;
    }
}

- (void)changeToNextPuzzle {
    
//    self.currPuzzleIndex++;
    self.currRecivedStatus = RecivedStatusNormal;
    
    
    if (self.currPuzzleIndex == [_navBar continueLevel] && [_navBar isNeedRestoreScene]) {
        NSString *gameDataFileName = @"PlayerState";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", gameDataFileName]];
        
        NSMutableDictionary *playerState = [[[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath] autorelease];
        
        NSString *picName = [playerState objectForKey:PS_PIC_NAME];
        NSString *answerCN = [playerState objectForKey:PS_ANSWER];
        NSString *groupName = [playerState objectForKey:PS_GROUP_NAME];
        NSInteger wordNum = [[playerState objectForKey:PS_WORD_NUM] integerValue];
        NSString *wordMixes = [playerState objectForKey:PS_WORD_MIXES];
        
        
        //获得PuzzleClass
        int indexOfPic = [[self.picSequenceArray objectAtIndex:self.currPuzzleIndex] integerValue];
        PuzzleClass * pc = [PuzzleClass puzzleWithIdKey:indexOfPic picName:picName answerCN:answerCN JA:nil EN:nil groupName:groupName wordNum:wordNum];
        pc.wordMixes = wordMixes;
        self.currPuzzle = pc;
        
        //Reset BlockArray
        for (iBlock *block in self.blockArray) {
            
            [block blockSpriteStopActionByTag:CCActionGoldenEffectTag];
            [block blockSpriteStopActionByTag:CCActionBlockDisappearEffectTag];
            
            [block resetBlockBackToInitalStatus];
        }
        
        //还原block现场
        //useItemArray
        NSArray *useItemGoneArray = [playerState objectForKey:PS_USE_ITEM_GONE];
        NSArray *useItemSmallArray = [playerState objectForKey:PS_USE_ITEM_SMALL];
        NSArray *useItemBombArray = [playerState objectForKey:PS_USE_ITEM_TRANS];
        
        for (NSNumber *numberGone in useItemGoneArray) {
            NSInteger goneIndex = [numberGone integerValue];
            iBlock *currBlock = [self.blockArray objectAtIndex:goneIndex];
            [currBlock makeBlock:BlockStatusGone];
        }
        
        for (NSNumber *numberSmall in useItemSmallArray) {
            NSInteger smallIndex = [numberSmall integerValue];
            iBlock *currBlock = [self.blockArray objectAtIndex:smallIndex];
            [currBlock makeBlock:BlockStatusSmall];
        }
        
        for (NSNumber *numberBomb in useItemBombArray) {
            NSInteger bombIndex = [numberBomb integerValue];
            iBlock *currBlock = [self.blockArray objectAtIndex:bombIndex];
            [currBlock makeBlock:BlockStatusBomb];
        }
    } else {
        //获得下一个PuzzleClass
        GPDatabase *gpdb = [[GPDatabase alloc] init];
        
        [gpdb openBundleDatabaseWithName:@"PuzzleDatabase.sqlite"];
        int indexOfPic = [[self.picSequenceArray objectAtIndex:self.currPuzzleIndex] integerValue];
        self.currPuzzle = [gpdb puzzlesWithGroup:PuzzleGroupMovies indexOfPic:indexOfPic];
        [gpdb close];
        
        [gpdb release];
        
        //Reset BlockArray
        for (iBlock *block in self.blockArray) {
            
            [block blockSpriteStopActionByTag:CCActionGoldenEffectTag];
            [block blockSpriteStopActionByTag:CCActionBlockDisappearEffectTag];
            
            [block resetBlockBackToInitalStatus];
        }
    }
    
    
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
    
    //更换图片
    [self resetPictrue];
    
    //把SuccessLayer去掉
    [self successLayerIsAppear:NO];
    
    //把分数直接调整为最新的
    [_navBar stopAnimationAndRefreshScore];
    
    if (IS_KAYAC) {
        [_navBar setTipsLabelStr:self.currPuzzle.Hiragana];
    }
    
    //是否需要保存现场
    self.isNeedRestoreScene = YES;
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
    
    _picSprite.scale = PICTURE_WIDTH / _picSprite.boundingBox.size.height;
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
    
//    iBlock *currBlock = nil;
    BOOL isTouchBlock = NO;
    for (iBlock *block in self.blockArray) {
        if (CGRectContainsPoint([block blockSpriteBoundingBox], _lastTouchLocation)) {
            isTouchBlock = YES;
//            currBlock = block;
            break;
        }
    }
    
//    Word *currWord = nil;
    BOOL isTouchWord = NO;
    for (Word *word in self.wordArray) {
        if (CGRectContainsPoint([word.wordSprite boundingBox], _lastTouchLocation)) {
            isTouchWord = YES;
//            currWord = word;
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
 
*/
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint endPoint = [GuessScene locationFromTouch:touch];
    
    iBlock *currBlock = nil;
    BOOL isTouchBlock = NO;
    for (iBlock *block in self.blockArray) {
        if (CGRectContainsPoint([block blockSpriteBoundingBox], _lastTouchLocation) && CGRectContainsPoint([block blockSpriteBoundingBox], endPoint)) {
            isTouchBlock = YES;
            currBlock = block;
            break;
        }
    }
    
    Word *currWord = nil;
    BOOL isTouchWord = NO;
    for (Word *word in self.wordArray) {
        if (CGRectContainsPoint([word.wordSprite boundingBox], _lastTouchLocation) && CGRectContainsPoint([word.wordSprite boundingBox], endPoint)) {
            isTouchWord = YES;
            currWord = word;
            break;
        }
    }
    
    if (isTouchBlock || isTouchWord) {
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

                            [_navBar changeTotalScore:(-1 * ItemSmallMinusScore)];
                            [_navBar refreshTotalScore];
                            
                        }
                        
                        break;
                        
                    case RecivedStatusBomb:
                        if (![currBlock isBlockHadItemEffect]) {
                            [currBlock makeBlock:BlockStatusBomb];
                            [self bombItemPressed];

                            [_navBar changeTotalScore:(-1 * ItemBombMinusScore)];
                            [_navBar refreshTotalScore];
                        }
                        break;
                        
                    case RecivedStatusFlying:
                        [self blockMetFly];
                        [self flyItemPressed];

                        [_navBar changeTotalScore:(-1 * ItemFlyingMinusScore)];
                        [_navBar refreshTotalScore];
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
            
            //To check next blank of waiting input
            int countIndex = 0;
            for (WordBlank *blank in self.blankArray) {
                if (!blank.fillWord) {
                    self.currBlankIndex = countIndex;
                    break;
                }

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
                    
                    //过关之后，保存本关的状态
                    [[GameManager sharedGameManager] setCompletedForCurrentActiveLevel:self.currPuzzleIndex];
                    [[GameManager sharedGameManager] setPassMarkForCurrentActiveLevel:YES];
                    
                    //下一关的序号
                    self.currPuzzleIndex++;
                    self.isNeedRestoreScene = NO;
                    
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
 }

- (void)onExit {
    [super onExit];
    
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

@end
