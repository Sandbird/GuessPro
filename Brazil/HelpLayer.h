//
//  HelpLayer.h
//  GuessProMovie
//
//  Created by zhaozilong on 14-4-14.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    HelpTypeItemIntro,
    HelpTypeBounsIntro,
    HelpTypeNONE,
    
}HelpType;

@interface HelpLayer : CCLayer {
    
}

- (id)initWithHelpType:(HelpType)type;

@end
