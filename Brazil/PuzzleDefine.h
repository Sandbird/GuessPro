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


#define ZORDER_BLANK            0
#define ZORDER_WORD_HOME        0

#define ZORDER_SUCCESS_LAYER    1

#define ZORDER_WORD_SELECTED    2
#define ZORDER_PICTRUE          2
#define ZORDER_BLOCK            3
#define ZORDER_NAV_BAR          3

#define ZORDER_ITEM_FLY         4


#define IS_KAYAC                NO




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
    RecivedStatusBomb,//道具被炸飞的状态
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
    CCNodeMAXTag = INT_MAX,
}CCNodeTag;






#endif
