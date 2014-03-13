//
//  ShareBorad.h
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-11.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    ShareTypeSOS,
    ShareTypeShare,
    ShareTypeNONE,
    
}ShareBoradShareType;

@interface ShareBorad : CCLayer {
    
}

- (id)initWithShareType:(ShareBoradShareType)SBSType;

@end
