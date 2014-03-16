//
//  WordBorad.h
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-13.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    
    WordBoradTypeTips,
    WordBoradTypeAnswer,
    WordBoradTypeNone,
    
}WordBoradType;

@interface WordBorad : CCLayer {
    
}

+ (WordBorad *)nodeWithWords:(NSString *)words wordBoradType:(WordBoradType)WBType;

@end
