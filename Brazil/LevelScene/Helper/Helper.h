#define ccpp(__percentx__, __percenty__)																		\
ccp([[CCDirector sharedDirector] winSize].width - ([[CCDirector sharedDirector] winSize].width * (__percentx__ / 100)), [[CCDirector sharedDirector] winSize].height - ([[CCDirector sharedDirector] winSize].height * (__percenty__ / 100)))



long map(long x, long in_min, long in_max, long out_min, long out_max);