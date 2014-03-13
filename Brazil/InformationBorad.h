//
//  InformationBorad.h
//  GuessProMovie
//
//  Created by zhaozilong on 14-3-12.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface InformationBorad : CCLayer {
    
}

+ (InformationBorad *)nodeWithInformation:(NSString *)info parentView:(UIView *)parentView;

@end
