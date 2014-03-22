//
//  StartLayer.h
//  Brazil
//
//  Created by 赵子龙 on 13-11-5.
//
//

#import "CCLayer.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface StartLayer : CCLayer<MFMailComposeViewControllerDelegate>

+ (CCScene *)scene;

@end
