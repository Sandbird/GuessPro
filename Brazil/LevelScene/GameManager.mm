#import "GameManager.h"
//#import "MenuScene.h"
#import "MapScene.h"
//#import "LevelScene.h"
//#import "StatsManager.h"
//#import "StoryScene.h"
//#import "LoadingScene.h"
#import "StartLayer.h"
#import "GuessScene.h"

@implementation GameManager


@synthesize currentActiveLevelIndex = currentActiveLevelIndex_;
@synthesize gameData = gameData_;
@synthesize levelData = levelData_;

+ (GameManager *) sharedGameManager {
    static dispatch_once_t once;
    static GameManager *sharedGameManager;
    dispatch_once(&once, ^ { sharedGameManager = [[self alloc] init]; });
    return sharedGameManager;
}

+ (NSInteger)highresScale {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED    
    BOOL deviceIsPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    if(deviceIsPad) {
        return 2;
    } else {
        return 1;
    }
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    return 2;
#endif
}

+ (BOOL)highres {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED    
    BOOL deviceIsPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    if(deviceIsPad) {
        return YES;
    } else {
        return NO;
    }
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    return YES;
#endif
}


- (id)init {
	if( (self=[super init] )) {
		[self loadGameState];	
		self.currentActiveLevelIndex = 0;
	}
	return self;	
}

- (void) loadLevelWithFilename:(NSString *)filename {
	self.currentActiveLevelIndex = 0;
	
	NSMutableDictionary *level = [NSMutableDictionary dictionaryWithObjectsAndKeys:filename, @"Tilemap",
																	 @"Custom", @"Name",
																	 [NSNumber numberWithInt:0], @"Score", nil];
	
	[[self levels] addObject:level];
	self.currentActiveLevelIndex = (int)[[self levels] count] - 1;
    

//    [[CCDirector sharedDirector] replaceScene:
//         [CCTransitionFade transitionWithDuration:0.5f scene:[LevelScene sceneWithTilemapName:filename]]];

	
}
- (void) loadLevelWithIndex:(int)index {
	
	NSDictionary *level = [self levelWithIndex:index];
    if([level objectForKey:@"Tilemap"] == nil || [[level objectForKey:@"Tilemap"] isEqualToString:@""]) {
        return;
    }
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    self.currentActiveLevelIndex = index;

//    CCScene *loadingScene = [LoadingScene sceneWithLevel:level index:index];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GuessScene sceneWithPuzzleNum:index]]];

	
    /*
    //////////////////////////////////////////////////
    
//     Tracking
     
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    [[Playtomic Log] play];
    [[Playtomic Log] levelCounterMetricName:kStatsPlayerStartedMap andLevelNumber:self.currentActiveLevelIndex andUnique:NO];    
#endif
    
    //////////////////////////////////////////////////
    */
	
}
- (NSMutableDictionary*) levelWithIndex:(int)index {
	return [levelData_ objectAtIndex:index];
}
- (BOOL) isLevelCompletedAtIndex:(int)index {   
	return YES;
}
- (NSArray *) levels {
	return levelData_;
}

- (BOOL) isLastLevel {
	int currentLevel = self.currentActiveLevelIndex + 1;
	int levelCount = (int)[levelData_ count];
	
	return ( levelCount == currentLevel );
		

}
- (void) loadNextLevel {
	[self loadLevelWithIndex:self.currentActiveLevelIndex + 1];
}
- (void) repeatLevel {
	[self loadLevelWithIndex:self.currentActiveLevelIndex];
}

- (int)totalScore {
    int score = 0;
    for (NSDictionary *level in levelData_) {
        score+=[[level objectForKey:@"Score"] intValue];
    }
    return score;
}
- (int) playerLives {
	return [[playerData_ objectForKey:@"Lives"] intValue];
}
- (void) setPlayerLives:(int)lives {
	
	NSNumber *livesNumber = [NSNumber numberWithInt:lives];
	[playerData_ setObject:livesNumber forKey:@"Lives"];
	
	if(lives == 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:GameOverNotification
															object:nil]; 
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PlayerLivesDidChangeNotification 
														object:livesNumber]; 

}
- (void) decreasePlayerLives {
	int lives = [self playerLives];
	[self setPlayerLives:lives - 1];
}
- (void) increasePlayerLives {
	int lives = [self playerLives];
	[self setPlayerLives:lives + 1];
}
- (void) loadSettings {
	
}

- (void) loadMenuScene {
  
	[[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFade transitionWithDuration:0.5f scene:[StartLayer scene]]];

    
}
- (void) loadMapScene {
	[[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFade transitionWithDuration:0.5f scene:[MapScene scene]]];
}
- (void) muteSounds {
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0f];
	[settingsData_ setObject:[NSNumber numberWithBool:NO] forKey:@"Sound"];
}
- (void) muteMusic {
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0f];
	[settingsData_ setObject:[NSNumber numberWithBool:NO] forKey:@"Music"];
}
- (NSMutableDictionary *) settings {
	return settingsData_;
}

- (void) setAccelerometerTolerance:(float) val {
    [settingsData_ setObject:[NSNumber numberWithFloat:val] forKey:@"AccelerometerTolerance"];
}


- (void)setControls:(GameManagerControls)controls {
    [settingsData_ setObject:[NSNumber numberWithInt:controls] forKey:@"Controls"];
}

- (GameManagerControls)controls {
    NSNumber *val = (NSNumber *)[settingsData_ objectForKey:@"Controls"];
    if(val == nil) {
        return GameManagerControlsButtons;
    } else {
        return (GameManagerControls)[val intValue];
    }
}

- (float) getAccelerometerTolerance {
    NSNumber *val = (NSNumber *)[settingsData_ objectForKey:@"AccelerometerTolerance"];
    return [val floatValue];
}

- (void) enableSounds {
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0f];
	[settingsData_ setObject:[NSNumber numberWithBool:YES] forKey:@"Sound"];
}
- (void) enableMusic {
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.3f];	
	[settingsData_ setObject:[NSNumber numberWithBool:YES] forKey:@"Music"];
}
- (void) toggleSound {
	if([[SimpleAudioEngine sharedEngine] effectsVolume] == 0.0f) {
		[self enableSounds];
	} else {
		[self muteSounds];
	}
}
- (void) toggleMusic {
	if([[SimpleAudioEngine sharedEngine] backgroundMusicVolume] == 0.0f) {
		[self enableMusic];
	} else {
		[self muteMusic];
	}
}
- (BOOL) isMusicEnabled {
    if([settingsData_ objectForKey:@"Music"] != NULL) {
        return [[settingsData_ objectForKey:@"Music"] boolValue];
    } 
    return YES;
}
- (BOOL) isSoundEnabled {
    if([settingsData_ objectForKey:@"Sound"] != NULL) {
        return [[settingsData_ objectForKey:@"Sound"] boolValue];
    }
    return YES;
}
- (void) saveGameState {

    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
#ifdef LITE
    NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:@"GameData-Lite.plist"];
#else 
    NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:@"GameData.plist"];
#endif
    
	if(![gameData_ writeToFile:settingsPath atomically:YES]) {
        CCLOG(@"error saveGameState");
    }
    /*
    [[StatsManager sharedManager] save];
     */
}
- (void) loadGameState {
    if(levelData_ != nil) {
        return;
    }
    
#ifdef LITE
    NSString *gameDataFileName = @"GameData-Lite";
#else 
    NSString *gameDataFileName = @"GameData";
#endif
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", gameDataFileName]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:settingsPath]) {
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:gameDataFileName ofType:@"plist"];
        if ([[NSFileManager defaultManager] isReadableFileAtPath:bundlePath]) {
            [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:settingsPath error:nil];
        }
    }
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:gameDataFileName ofType:@"plist"];
#if COCOS2D_DEBUG == 1
    if ([[NSFileManager defaultManager] isReadableFileAtPath:bundlePath]) {
        [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:settingsPath error:nil];
    }
#endif
  
	self.gameData = [[[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath] autorelease];

    // ----------------
    // Beta Check!
    if([self.gameData objectForKey:@"BetaVersion"] == nil) {
        [[NSFileManager defaultManager] removeItemAtPath:settingsPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:settingsPath error:nil];
        self.gameData = [[[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath] autorelease];
    } else {
        if([[self.gameData objectForKey:@"BetaVersion"] intValue] < 2) {
            [[NSFileManager defaultManager] removeItemAtPath:settingsPath error:nil];
            [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:settingsPath error:nil];
            self.gameData = [[[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath] autorelease];
        }
    }
   
    // -----------------
    
	playerData_ = [self.gameData objectForKey:@"Player"];
	settingsData_ = [self.gameData objectForKey:@"Settings"];	
	self.levelData = [self.gameData objectForKey:@"Levels"];
    
    // ---------------------------------------------
    // Merge Game Data: bundle plist <-> Document plist
    // When new maps are added merge the local store with the new fresh gameData from the bundle
    // ---------------------------------------------
    NSMutableDictionary *bundleDict = [NSDictionary dictionaryWithContentsOfFile:bundlePath];
    NSArray *bundleLevel = [bundleDict objectForKey:@"Levels"];

    if([levelData_ count] < [bundleLevel count]) {
        NSMutableArray *mergedLevels = [NSMutableArray array];
        
        for (NSMutableDictionary *level in bundleLevel) {
            NSDictionary *oldLevel = [self levelWithKey:@"Tilemap" value:[level objectForKey:@"Tilemap"]];
            NSMutableDictionary *mergeLevel = [NSMutableDictionary dictionaryWithDictionary:level];
            if(oldLevel != nil) {
                [mergeLevel setObject:[oldLevel objectForKey:@"Score"] forKey:@"Score"];
                [mergeLevel setObject:[oldLevel objectForKey:@"Completed"] forKey:@"Completed"];
                [mergeLevel setObject:[oldLevel objectForKey:@"SpecialItem"] forKey:@"SpecialItem"];
            }
            [mergedLevels addObject:mergeLevel];
        }
        self.levelData = [NSMutableArray arrayWithArray:mergedLevels];
        [self.gameData setObject:self.levelData forKey:@"Levels"];
    }
    // ---------------------------------------------
    
    /*
    [[StatsManager sharedManager] load];
     */
}
- (NSDictionary *)levelWithKey:(NSString *)key value:(id)value {
    NSDictionary *foundLevel = nil;
    for (NSDictionary *level in levelData_) {
        if([[level objectForKey:key] isEqual:value]) {
            foundLevel = level;
            break;
        }
    }
    return foundLevel;
    
    
}


- (void) setScore:(int)score forLevelIndex:(int)index {
    NSMutableDictionary *level = [self levelWithIndex:index];
    [level setValue:[NSNumber numberWithInt:score] forKey:@"Score"];
    [level setValue:[NSNumber numberWithBool:YES] forKey:@"Completed"];
    
    [self saveGameState];
    /*
    [[StatsManager sharedManager] save];
     */
}
- (int) scoreForLevelIndex:(int)index {
    NSDictionary *level = [self levelWithIndex:index];
    return [[level valueForKey:@"Score"] intValue];
}
- (int)scoreForCurrentActiveLevel {
    return [self scoreForLevelIndex:self.currentActiveLevelIndex];
}
- (void)setScoreForCurrentActiveLevel:(int)score {
    [self setScore:score forLevelIndex:self.currentActiveLevelIndex];
}

- (void)setCompletedForCurrentActiveLevel:(int)levelNum {
    self.currentActiveLevelIndex = levelNum;
    [self setScore:0 forLevelIndex:self.currentActiveLevelIndex];
}

- (int)starsForCurrentActiveLevelWithScore:(int)score {
    NSDictionary *level = [self levelWithIndex:self.currentActiveLevelIndex];
    NSArray *bestScores = [level objectForKey:@"BestScores"];
    int stars = 0;
    
    for (NSNumber *bestScore in bestScores) {
        if(score > [bestScore intValue]) {
            stars++;
        }
    }

    return stars;
}
- (int) starsForLevelIndex:(int)index {
    NSDictionary *level = [self levelWithIndex:index];
    NSArray *bestScores = [level objectForKey:@"BestScores"];
    NSNumber *score = [level objectForKey:@"Score"];
    int stars = 0;
    
    if([score intValue] == 0) return 0;

    for (NSNumber *bestScore in bestScores) {
        if([score intValue] > [bestScore intValue]) {
            stars++;
        }
    }
    
    return stars;
}


- (BOOL)hasPassMarkForLevelIndex:(int)index {
    NSDictionary *level = [self levelWithIndex:index];
    BOOL PassMark = [[level objectForKey:@"SpecialItem"] boolValue];
    return PassMark;
}
- (void)setPassMark:(BOOL)PassMark forLevelIndex:(int)index {
    NSMutableDictionary *level = [self levelWithIndex:index];
    [level setValue:[NSNumber numberWithBool:PassMark] forKey:@"SpecialItem"];
}

- (void)setPassMarkForCurrentActiveLevel:(BOOL)PassMark {
    [self setPassMark:PassMark forLevelIndex:self.currentActiveLevelIndex];
    
    [self saveGameState];
}


@end


