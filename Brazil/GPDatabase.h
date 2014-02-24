//
//  GPDatabase.h
//  Brazil
//
//  Created by zhaozilong on 13-10-31.
//
//

#import <Foundation/Foundation.h>
#import "PuzzleClass.h"

@interface GPDatabase : NSObject

- (void)openBundleDatabaseWithName:(NSString *)dbName;
- (void)close;

- (PuzzleClass *)puzzlesWithGroup:(PuzzleGroup)groupTag indexOfPic:(int)index;
- (NSMutableArray *)PuzzleSequenceIsOutOfOrder:(BOOL)isOut groupName:(PuzzleGroup)groupTag;

@end
