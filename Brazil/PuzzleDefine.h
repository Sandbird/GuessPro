//
//  PuzzleDefine.h
//  Brazil
//
//  Created by zhaozilong on 13-10-31.
//
//

#ifndef Brazil_PuzzleDefine_h
#define Brazil_PuzzleDefine_h

#define NUM_OF_WORD_SELECTED 24

#define PICTURE_WIDTH ([GPNavBar isiPad] ? 500.0 : 220.0)


#define ZORDER_BLANK            0
#define ZORDER_WORD_HOME        0

#define ZORDER_SUCCESS_LAYER    1

#define ZORDER_WORD_SELECTED    2
#define ZORDER_PICTRUE          2

#define ZORDER_BLOCK            3
#define ZORDER_NAV_BAR          100

#define ZORDER_ITEM_FLY         4

#define IS_KAYAC                YES

#define PS_TOTAL_SCORE      @"totalScore"
#define PS_CONTINUE_LEVEL   @"continueLevel"
#define PS_IS_NEED_RESTORE_SCENE     @"isNeedRestoreScene"


#define PS_ID_KEY           @"idKey"
#define PS_PIC_NAME         @"picName"
//#define PS_ANSWER_CN        @"answerCN"
//#define PS_ANSWER_JA        @"answerJA"
//#define PS_ANSWER_EN        @"answerEN"
#define PS_GROUP_NAME       @"groupName"
#define PS_WORD_NUM         @"wordNum"
#define PS_ANSWER           @"answer"
#define PS_WORD_MIXES       @"wordMixes"
#define PS_TIP              @"tip"
#define PS_IS_BUY_TIP       @"isBuyTip"
//#define PS_SELECTED_WORDS   @"selectedWords"
//#define PS_SELECTED_BLANK   @"selectedBlank"
#define PS_USE_ITEM_GONE    @"useItemGone"
#define PS_USE_ITEM_SMALL   @"useItemSmall"
#define PS_USE_ITEM_TRANS   @"useItemTrans"

//题目类别
typedef enum {
    
    PuzzleGroupMovies,
    PuzzleGroupALL,
}PuzzleGroup;

//道具类别
typedef enum {
    
    BlockStatusNormal,//初始化的正常状态下
    BlockStatusSelected,//被选中的状态下
    BlockStatusGone,//已经消失的状态
    
    BlockStatusSmall,//道具变小的状态
    BlockStatusBomb,//道具被炸飞的状态
    BlockStatusFlying,//道具飞机略过的状态
    
    BlockStatusBouns,//双倍积分
    BlockStatusReset,//重置
}BlockStatus;


//当前可接受的道具类型
typedef enum {
    
    RecivedStatusNormal,//初始化的正常状态下
    RecivedStatusSmall,//道具变小的状态
    RecivedStatusBomb,//道具透明的状态
    RecivedStatusFlying,//道具飞机略过的状态
    
}RecivedStatus;

//tag集合
typedef enum {
    CCActionBlueEffectTag = 111,
    CCActionRedEffectTag,
    CCActionGreenEffectTag,
    CCActionGoldenEffectTag,
    CCActionBlockDisappearEffectTag,
    CCActionBlockSelectedEffectTag,
    CCActionWordBlankRotateEffectTag,
    CCSpriteFlyingItemTag,
    CCLayerSuccessLayerTag,
    CCMenuItemSmallTag,
    CCMenuItemBombTag,
    CCMenuItemFlyingTag,
    CCMenuItemTipsTag,
    CCMenuItemAnswerTag,
    CCMenuItemShareTag,
    CCNodeMAXTag = INT_MAX,
}CCNodeTag;






#endif
