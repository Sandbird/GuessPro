#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum GameManagerControls {
    GameManagerControlsButtons,
    GameManagerControlsAccelerometer 
} GameManagerControls;

//@class LevelScene;

#define GameOverNotification @"GameManagerGameOverNotification"
#define PlayerLivesDidChangeNotification @"GameManagerPlayerLivesDidChangeNotification"
#define CCGameDidPaused  @"CCGameDidPaused"



#define __HIGHRES [GameManager highres]
#define __HIGHRES_SCALE [GameManager highresScale]

@interface GameManager : NSObject {
//	LevelScene *levelScene_;
	int currentActiveLevelIndex_;
	NSMutableDictionary *gameData_;
	NSMutableDictionary *playerData_;
	NSMutableDictionary *settingsData_;
	NSMutableArray *levelData_;
}
/** current active level index */
@property int currentActiveLevelIndex;

/** the whole gameData.plst in as a dictionary */
@property (nonatomic, retain) NSMutableDictionary *gameData;

/** shortcut to the gameData levels */
@property (nonatomic, retain) NSArray *levelData;


/** Singleton */
+ (GameManager *) sharedGameManager;
+ (NSInteger)highresScale;
+ (BOOL)highres;

/**
 Retun the total score of all finished levels 
 
 @return total score 
 */
- (int)totalScore;

///---------------------------------------------------------------------------------------
/// @name Loading Level
///---------------------------------------------------------------------------------------

- (void) loadLevelWithIndex:(int)index;
- (void) loadLevelWithFilename:(NSString *)filename;



///---------------------------------------------------------------------------------------
/// @name Accessing the levels
///---------------------------------------------------------------------------------------

- (NSMutableDictionary*) levelWithIndex:(int)index;
- (BOOL)isLevelCompletedAtIndex:(int)index;
- (NSMutableArray *) levels;
- (BOOL) isLastLevel;

- (void)setScore:(int)score forLevelIndex:(int)index;
- (void)setScoreForCurrentActiveLevel:(int)score;
- (int) starsForCurrentActiveLevelWithScore:(int)score;
- (int) starsForLevelIndex:(int)index;

- (int) scoreForLevelIndex:(int)index;
- (int) scoreForCurrentActiveLevel;


- (BOOL)hasPassMarkForLevelIndex:(int)index;
- (void)setPassMark:(BOOL)PassMark forLevelIndex:(int)index;
- (void)setPassMarkForCurrentActiveLevel:(BOOL)PassMark;

//- (BOOL)hasSpecialItemForLevelIndex:(int)index;
//- (void)setSpecialItemForCurrentActiveLevel:(BOOL)specialItem;
//- (void)setSpecialItem:(BOOL)specialItem forLevelIndex:(int)index;

- (NSDictionary *)levelWithKey:(NSString *)key value:(id)value;

///---------------------------------------------------------------------------------------
/// @name Loading Scenes
///---------------------------------------------------------------------------------------

- (void)loadMenuScene;
- (void)loadMapScene;

///---------------------------------------------------------------------------------------
/// @name Player lives
///---------------------------------------------------------------------------------------

- (int) playerLives;
- (void) setPlayerLives:(int)lives;
- (void) decreasePlayerLives;
- (void) increasePlayerLives;


- (void) loadNextLevel;
- (void) repeatLevel;

///---------------------------------------------------------------------------------------
/// @name Game Settings (music/sounds)
///---------------------------------------------------------------------------------------

- (void) muteSounds;
- (void) muteMusic;
- (NSMutableDictionary *) settings;
- (void) enableSounds;
- (void) enableMusic;
- (void) toggleSound;
- (void) toggleMusic;
- (BOOL) isMusicEnabled;
- (BOOL) isSoundEnabled;
- (void)setAccelerometerTolerance:(float)val;
- (float)getAccelerometerTolerance;
- (void)setControls:(GameManagerControls)controls;
- (GameManagerControls)controls;

///---------------------------------------------------------------------------------------
/// @name Loading and Saving game data
///---------------------------------------------------------------------------------------

- (void) loadSettings;
- (void) saveGameState;
- (void) loadGameState;



@end
