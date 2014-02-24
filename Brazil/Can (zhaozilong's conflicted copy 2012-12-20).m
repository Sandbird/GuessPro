//
//  Can.m
//  Brazil
//
//  Created by zhaozilong on 12-11-29.
//
//

#import "Can.h"

@implementation Can

#define TALK_TAG 1234

//@synthesize delegate = _delegate;
@synthesize isTouchHandled = _isTouchHandled;
@synthesize can1Sprite = _can1Sprite;
@synthesize can2Sprite = _can2Sprite;
@synthesize can3Sprite = _can3Sprite;

BOOL CanIsAnimLocked = NO;

- (void)dealloc {
    
    //    [_delegate release], _delegate = nil;
    
    CCLOG(@"Can dealloc");
    
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [super dealloc];
}

+ (id)canWithParentNode:(CCNode *)parentNode {
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

- (id)initWithParentNode:(CCNode *)parentNode {
    
    if (self = [super init]) {
        //说话动画锁
        isCanAnimLocked = NO;
        
        //获取屏幕大小
        screenSize = [[CCDirector sharedDirector] winSize];
        
        //touch is enabled
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
        
        //帧缓存
        frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        CGFloat can1X, can2X, can3X;
        if ([ZZNavBar isiPad]) {
            can1X = 30;
            can2X = screenSize.width / 3 + 30;
            can3X = screenSize.width * 2 / 3 + 30;
        } else {
            can1X = 5;
            can2X = screenSize.width / 3 + 5;
            can3X = screenSize.width * 2 / 3 + 5;
        }
        
        //创建can1精灵
        frame = [frameCache spriteFrameByName:PNG_CAN_RECYCLE];
        _can1Sprite = [CCSprite spriteWithSpriteFrame:frame];
        _can1Sprite.anchorPoint = ccp(0, 0);//CGPointMake(0, 1);
        _can1Sprite.position = ccp(can1X, screenSize.height * 7 / 24);
        right1Sprite.anchorPoint = ccp(0, 0);
        right1Sprite.position = _can1Sprite.position;
        wrong1Sprite.anchorPoint = ccp(0, 0);
        wrong1Sprite.position = _can1Sprite.position;
        right1Sprite.visible = NO;
        wrong1Sprite.visible = NO;
        
        
        //创建can2精灵
        frame = [frameCache spriteFrameByName:PNG_CAN_HARM];
        _can2Sprite = [CCSprite spriteWithSpriteFrame:frame];
        _can2Sprite.anchorPoint = ccp(0, 0);//CGPointMake(0, 1);
        _can2Sprite.position = ccp(can2X, screenSize.height * 7 / 24);
        right2Sprite.anchorPoint = ccp(0, 0);
        right2Sprite.position = _can2Sprite.position;
        wrong2Sprite.anchorPoint = ccp(0, 0);
        wrong2Sprite.position = _can2Sprite.position;
        right2Sprite.visible = NO;
        wrong2Sprite.visible = NO;
        
        //创建can3精灵
        frame = [frameCache spriteFrameByName:PNG_CAN_KITCHEN];
        _can3Sprite = [CCSprite spriteWithSpriteFrame:frame];
        _can3Sprite.anchorPoint = ccp(0, 0);//CGPointMake(0, 1);
        _can3Sprite.position = ccp(can3X, screenSize.height * 7 / 24);
        right3Sprite.anchorPoint = ccp(0, 0);
        right3Sprite.position = _can3Sprite.position;
        wrong3Sprite.anchorPoint = ccp(0, 0);
        wrong3Sprite.position = _can3Sprite.position;
        right3Sprite.visible = NO;
        wrong3Sprite.visible = NO;
        
        [parentNode addChild:_can1Sprite];
        [parentNode addChild:right1Sprite];
        [parentNode addChild:wrong1Sprite];
        
        [parentNode addChild:_can2Sprite];
        [parentNode addChild:right2Sprite];
        [parentNode addChild:wrong2Sprite];
        
        [parentNode addChild:_can3Sprite];
        [parentNode addChild:right3Sprite];
        [parentNode addChild:wrong3Sprite];
        
        //初始化已经吃的水果个数
        fruitCount = 0;
        
//        [Can loadEffectMusic];
        //set can's favor
//        [self setCurrentFruitFavor];
        //        [self sayLikeFruit];
        sound = 0;//[[SimpleAudioEngine sharedEngine] playEffect:@"eatApple.m4a"];
//        [self sayLikeFruit];
        
    }
    
    return self;
}


- (CGRect)getCanSpriteRectByCanTags:(int)canTag {
    
    CGRect rect;
    CGFloat can1X, can2X, can3X, y;
    if ([ZZNavBar isiPad]) {
        rect.size = CGSizeMake(140, 30);
        can1X = 50;
        can2X = 320;
        can3X = 570;
        y = 490;
    } else {
        rect.size = CGSizeMake(70, 15);
        can1X = 15;
        can2X = 130;
        can3X = 230;
        if ([ZZNavBar isiPhone5]) {
            y = 260;
        } else {
            y = 240;
        }
        
    }
    
    
    switch (canTag) {
        case CanRecycleTag:
            rect.origin = CGPointMake(can1X, y);
            break;
            
        case CanHarmTag:
            rect.origin = CGPointMake(can2X, y);
            break;
            
        case CanKitchenTag:
            rect.origin = CGPointMake(can3X, y);
            break;
            
        default:
            break;
    }
    
    return rect;
}

- (void)setCanScaleAnim:(BOOL)isBig {
    if (isBig) {
        [_can1Sprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.5]];
    } else {
        [_can1Sprite runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];

    }
}

- (void)setCanRecycleResultByRubbishTag:(int)rubbishTag {
//    CCSequence *seq = [CCSequence acti];
    
    CCTintTo *colorGreen = [CCTintTo actionWithDuration:0.1 red:0 green:255 blue:0];
    CCTintTo *colorRed = [CCTintTo actionWithDuration:0.1 red:255 green:0 blue:0];
    CCTintTo *colorNormal = [CCTintTo actionWithDuration:0.1 red:255 green:255 blue:255];
    
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5];
    
    CCSequence *right;// = [CCSequence actions:colorGreen, delay, colorNormal, nil];
    CCSequence *wrong;// = [CCSequence actions:colorRed, [delay copy], colorNormal, nil];
    
    
    
    CCCallBlock *rubbishVisible = [CCCallBlock actionWithBlock:^{
        [self setRubbishVisible];
    }];
    switch (rubbishTag) {
        case RubbishDiskTag:
        case RubbishNewspaperTag:
            //回答正确
            CCLOG(@"回收垃圾，正确");
            
            CCCallBlock *showRight = [CCCallBlock actionWithBlock:^{
                [right1Sprite runAction:[CCShow action]];
            }];
            
            CCCallBlock *hideRight = [CCCallBlock actionWithBlock:^{
                [right1Sprite runAction:[CCHide action]];
            }];
            
            right = [CCSequence actions:showRight, colorGreen, delay, colorNormal, rubbishVisible, nil];
            
            //播放正确的声音
            [_can1Sprite runAction:right];
            break;
            
        default:
            //回答错误
            CCLOG(@"不是回收垃圾，错误");
            
            CCCallBlock *showWrong = [CCCallBlock actionWithBlock:^{
                [wrong1Sprite runAction:[CCShow action]];
            }];
            
            CCCallBlock *hideWrong = [CCCallBlock actionWithBlock:^{
                [wrong1Sprite runAction:[CCHide action]];
            }];
            
            wrong = [CCSequence actions:colorRed, delay, colorNormal, rubbishVisible, nil];
            
            //播放错误的声音
            
            [_can1Sprite runAction:wrong];
            break;
    }
}

- (void)setCanHarmResultByRubbishTag:(int)rubbishTag {
    
    CCTintTo *colorGreen = [CCTintTo actionWithDuration:0.1 red:0 green:255 blue:0];
    CCTintTo *colorRed = [CCTintTo actionWithDuration:0.1 red:255 green:0 blue:0];
    CCTintTo *colorNormal = [CCTintTo actionWithDuration:0.1 red:255 green:255 blue:255];
    
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5];
    
    CCSequence *right;// = [CCSequence actions:colorGreen, delay, colorNormal, nil];
    CCSequence *wrong;// = [CCSequence actions:colorRed, [delay copy], colorNormal, nil];
    
    CCCallBlock *rubbishVisible = [CCCallBlock actionWithBlock:^{
        [self setRubbishVisible];
    }];

    
    switch (rubbishTag) {
        case RubbishPlasticTag:
        case RubbishBottleTag:
            //回答正确
            CCLOG(@"有害垃圾，正确");
            
            right = [CCSequence actions:colorGreen, delay, colorNormal, rubbishVisible, nil];
            
            //播放正确的声音
            [_can2Sprite runAction:right];
            
            break;
            
        default:
            //回答错误
            CCLOG(@"不是有害垃圾，错误");
            
            wrong = [CCSequence actions:colorRed, delay, colorNormal, rubbishVisible, nil];
            
            //播放错误的声音
            
            [_can2Sprite runAction:wrong];
            break;

    }
}


- (void)setCanKitchenResultByRubbishTag:(int)rubbishTag {
    
    CCTintTo *colorGreen = [CCTintTo actionWithDuration:0.1 red:0 green:255 blue:0];
    CCTintTo *colorRed = [CCTintTo actionWithDuration:0.1 red:255 green:0 blue:0];
    CCTintTo *colorNormal = [CCTintTo actionWithDuration:0.1 red:255 green:255 blue:255];
    
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5];
    
    CCSequence *right;// = [CCSequence actions:colorGreen, delay, colorNormal, nil];
    CCSequence *wrong;// = [CCSequence actions:colorRed, [delay copy], colorNormal, nil];
    
    CCCallBlock *rubbishVisible = [CCCallBlock actionWithBlock:^{
        [self setRubbishVisible];
    }];

    
    switch (rubbishTag) {
        case RubbishBatteryTag:
        case RubbishCokeTag:
            //回答正确
            CCLOG(@"厨余垃圾，正确");
            
            right = [CCSequence actions:colorGreen, delay, colorNormal, rubbishVisible, nil];
            
            //播放正确的声音
            [_can3Sprite runAction:right];
            break;
            
        default:
            //回答错误
            CCLOG(@"不是厨余垃圾，错误");
            
            wrong = [CCSequence actions:colorRed, delay, colorNormal, rubbishVisible, nil];
            
            //播放错误的声音
            
            [_can3Sprite runAction:wrong];
            break;

    }
}


- (void)setCanAnimByCanTag:(int)canTag rubbishTag:(int)rubbishTag {
    
    isCanAnimLocked = YES;
    
    CCRotateTo *shake0 = [CCRotateTo actionWithDuration:0.05 angle:0];
    CCRotateTo *shake1 = [CCRotateTo actionWithDuration:0.1 angle:-2];
    CCRotateTo *shake2 = [CCRotateTo actionWithDuration:0.1 angle:2];
    CCSequence *shake = [CCSequence actions:shake1, shake2, nil];
    CCRepeat *shakeTimes = [CCRepeat actionWithAction:shake times:4];
    CCSequence *action = [CCSequence actionOne:shakeTimes two:shake0];
    
    switch (canTag) {
        case CanRecycleTag:
            [_can1Sprite runAction:action];
            [self setCanRecycleResultByRubbishTag:rubbishTag];
            break;
            
        case CanHarmTag:
            [_can2Sprite runAction:action];
            [self setCanHarmResultByRubbishTag:rubbishTag];
            break;
            
        case CanKitchenTag:
            [_can3Sprite runAction:action];
            [self setCanKitchenResultByRubbishTag:rubbishTag];
            break;
            
        default:
            break;
    }
}

- (BOOL)isCanAnimationLocked {
    
    return isCanAnimLocked;
}

- (void)setRubbishVisible {
    isCanAnimLocked = NO;
    
    Rubbish *rubbish = [[RubbishScene sharedRubbishScene] rubbish];
    
    [rubbish setRubbishSpriteVisible:YES];
    
    [rubbish setRubbishSpriteAppearEffect];
}

- (void)saylikeRubbish:(int)canTag {
    switch (canTag) {
        case CanRecycleTag:
            [[[RubbishScene sharedRubbishScene] navBar] setTitleLabelWithString:@"Recyclable\n可回收物"];
            break;
            
        case CanHarmTag:
            [[[RubbishScene sharedRubbishScene] navBar] setTitleLabelWithString:@"Other Waste\n其它垃圾"];
            break;
            
        case CanKitchenTag:
            [[[RubbishScene sharedRubbishScene] navBar] setTitleLabelWithString:@"Kitchen Waste\n厨余垃圾"];
            break;
            
        default:
            NSAssert(1, @"没有点击正确的垃圾桶");
            break;
    }
}



#if 0

- (void)setCurrentFruitFavor {
    fruitTag = arc4random() % 7 + 10;
}

- (void)sayLikeFruit {
    //吃东西的动画
    _isSpeakAnimLocked = YES;
    
    CCCallBlock *openLock = [CCCallBlock actionWithBlock:^{
        _isSpeakAnimLocked = NO;
    }];
    CCAnimation *speak = [CCAnimation animationWithFrame:@"speak" frameCount:2 delay:0.2];
    CCRepeat *speakRepeat = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:speak] times:3];
    [headSprite runAction:[CCSequence actionOne:speakRepeat two:openLock]];
    
    [[SimpleAudioEngine sharedEngine] stopEffect:sound];
    
    //得到label
    CCLabelTTF *talkLabel = (CCLabelTTF *)[talkSprite getChildByTag:TALK_TAG];
    
    switch (fruitTag) {
        case FruitAppleTag:
            CCLOG(@"我想吃Apple");
            //            [[SimpleAudioEngine sharedEngine] playEffect:@"eatApple.m4a"];
            sound = [[SimpleAudioEngine sharedEngine] playEffect:@"eatApple.m4a"];
            
            [talkLabel setString:@"我想吃苹果\nI want to eat\napple."];
            break;
            
        case FruitGrapeTag:
            CCLOG(@"我想吃Grape");
            sound = [[SimpleAudioEngine sharedEngine] playEffect:@"eatGrape.m4a"];
            [talkLabel setString:@"我想吃葡萄\nI want to eat\ngrape."];
            break;
            
        case FruitBananaTag:
            CCLOG(@"我想吃Banana");
            sound = [[SimpleAudioEngine sharedEngine] playEffect:@"eatBanana.m4a"];
            [talkLabel setString:@"我想吃香蕉\nI want to eat\nbanana."];
            break;
            
        case FruitCherryTag:
            CCLOG(@"我想吃Cherry");
            sound = [[SimpleAudioEngine sharedEngine] playEffect:@"eatCherry.m4a"];
            [talkLabel setString:@"我想吃樱桃\nI want to eat\ncherry."];
            break;
            
        case FruitOrangeTag:
            CCLOG(@"我想吃Orange");
            sound = [[SimpleAudioEngine sharedEngine] playEffect:@"eatOrange.m4a"];
            [talkLabel setString:@"我想吃桔子\nI want to eat\norange."];
            break;
            
        case FruitWatermelonTag:
            CCLOG(@"我想吃Watermelon");
            sound = [[SimpleAudioEngine sharedEngine] playEffect:@"eatWatermelon.m4a"];
            [talkLabel setString:@"我想吃西瓜\nI want to eat\nwatermelon."];
            break;
            
        case FruitDurianTag:
            CCLOG(@"我想吃Durian");
            sound = [[SimpleAudioEngine sharedEngine] playEffect:@"eatDurian.m4a"];
            [talkLabel setString:@"我想吃榴莲\nI want to eat\ndurian."];
            break;
            
        default:
            CCLOG(@"ERROR，我啥也不想吃。%d", fruitTag);
            break;
    }
    
    
}

- (NSString *)getCurrentFruitName {
    switch (fruitTag) {
        case FruitAppleTag:
            return @"Apple";
            break;
            
        case FruitGrapeTag:
            return @"Grape";
            break;
            
        case FruitBananaTag:
            return @"Banana";
            break;
            
        case FruitCherryTag:
            return @"Cherry";
            break;
            
        case FruitOrangeTag:
            return @"Orange";
            break;
            
        case FruitWatermelonTag:
            return @"Watermelon";
            break;
            
        case FruitDurianTag:
            return @"Durian";
            break;
            
        default:
            CCLOG(@"ERROR, 错误的水果名称。%d", fruitTag);
            return @"ERROR";
            break;
    }
    
}

//提前加载音效
+(void)loadEffectMusic{
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"eat.caf"];
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"eatApple.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"eatGrape.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"eatBanana.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"eatCherry.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"eatOrange.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"eatWatermelon.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"eatDurian.m4a"];
}

//播放背景音效
+(void)playEffectMusic {
    [[SimpleAudioEngine sharedEngine] playEffect:@"eat.caf"];
    //    [[SimpleAudioEngine sharedEngine] playEffect:@"eatApple.m4a"];
}
#endif

#pragma mark -
#pragma mark TouchEvent
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [RubbishScene locationFromTouch:touch];
    
    if (CGRectContainsPoint([_can1Sprite boundingBox], touchLocation) || CGRectContainsPoint([_can2Sprite boundingBox], touchLocation) || CGRectContainsPoint([_can3Sprite boundingBox], touchLocation)) {
        _isTouchHandled = YES;
    }
    
    if (CGRectContainsPoint([_can1Sprite boundingBox], touchLocation)) {
        
        //如果动画上锁，则不再设置当前喜欢的水果
//        if (CanIsAnimLocked == NO) {
            //说吃当前喜欢吃的水果
            [self saylikeRubbish:CanRecycleTag];
            CCLOG(@"可回收垃圾桶");
//        }
        
        [_can1Sprite runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.05 scale:1.1], [CCScaleTo actionWithDuration:0.05 scale:1.0], nil]];
	}
    
    if (CGRectContainsPoint([_can2Sprite boundingBox], touchLocation)) {

        CCLOG(@"有害垃圾桶");
        [self saylikeRubbish:CanHarmTag];
        
        [_can2Sprite runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.05 scale:1.1], [CCScaleTo actionWithDuration:0.05 scale:1.0], nil]];
	}

    
    if (CGRectContainsPoint([_can3Sprite boundingBox], touchLocation)) {
        
        CCLOG(@"厨余垃圾桶");
        [self saylikeRubbish:CanKitchenTag];
        
        [_can3Sprite runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.05 scale:1.1], [CCScaleTo actionWithDuration:0.05 scale:1.0], nil]];
	}

    
    return _isTouchHandled;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    _isTouchHandled = NO;
}


@end
