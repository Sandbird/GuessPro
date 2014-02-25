#import "SlidingMenuGrid.h"

@implementation SlidingMenuGrid

@synthesize padding;
@synthesize menuOrigin;
@synthesize touchOrigin;
@synthesize touchStop;
@synthesize bMoving;
@synthesize bSwipeOnlyOnMenu;
@synthesize	fMoveDelta;
@synthesize fMoveDeadZone;
@synthesize iPageCount;
@synthesize iCurrentPage;
@synthesize bVerticalPaging;
@synthesize fAnimSpeed;
@synthesize delegate;

+(id) menuWithArray:(NSMutableArray*)items cols:(int)cols rows:(int)rows position:(CGPoint)pos padding:(CGPoint)pad
{
	return [[[self alloc] initWithArray:items cols:cols rows:rows position:pos padding:pad verticalPages:false] autorelease];
}

+(id) menuWithArray:(NSMutableArray*)items cols:(int)cols rows:(int)rows position:(CGPoint)pos padding:(CGPoint)pad verticalPages:(bool)vertical
{
	return [[[self alloc] initWithArray:items cols:cols rows:rows position:pos padding:pad verticalPages:vertical] autorelease];
}

-(id) initWithArray:(NSMutableArray*)items cols:(int)cols rows:(int)rows position:(CGPoint)pos padding:(CGPoint)pad verticalPages:(bool)vertical
{
	if ((self = [super init]))
	{       
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		isMouseEnabled_ = YES;
		isKeyboardEnabled_ = YES;
#endif
        
		int z = 1;
		for (id item in items)
		{
			[self addChild:item z:z tag:z];
			++z;
		}

		padding = pad;
		iCurrentPage = 0;
		bMoving = false;
		bSwipeOnlyOnMenu = false;
		menuOrigin = pos;
		fMoveDeadZone = 15;
		bVerticalPaging = vertical;
		fAnimSpeed = 0.5f;

		(bVerticalPaging) ? [self buildGridVertical:cols rows:rows] : [self buildGrid:cols rows:rows];
		self.position = menuOrigin;
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) buildGrid:(int)cols rows:(int)rows
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	int col = 0, row = 0;
	for (CCMenuItem* item in self.children)
	{
		// Calculate the position of our menu item. 
		item.position = CGPointMake(self.position.x + col * padding.x + (iPageCount * winSize.width), self.position.y - row * padding.y);
		
		// Increment our positions for the next item(s).
		++col;
		if (col == cols)
		{
			col = 0;
			++row;
			
			if( row == rows )
			{
				iPageCount++;
				col = 0;
				row = 0;
			}
		}
	}
}
-(void) buildGridVertical:(int)cols rows:(int)rows
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	int col = 0, row = 0;
	for (CCMenuItem* item in self.children)
	{
		// Calculate the position of our menu item. 
		item.position = CGPointMake(self.position.x + col * padding.x , self.position.y - row * padding.y + (iPageCount * winSize.height));
		
		// Increment our positions for the next item(s).
		++col;
		if (col == cols)
		{
			col = 0;
			++row;
			
			if( row == rows )
			{
				iPageCount++;
				col = 0;
				row = 0;
			}
		}
	}
}

-(void) addChild:(CCMenuItem*)child z:(int)z tag:(int)aTag
{
	return [super addChild:child z:z tag:aTag];
}

// Run the action necessary to slide the menu grid to the current page.
- (void) moveToCurrentPage
{
	
	// Perform the action
	id action = [CCMoveTo actionWithDuration:(fAnimSpeed*0.5) position:[self GetPositionOfCurrentPage]];
	[self runAction:action];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(CCMenuItem*) GetItemWithinTouch:(UITouch*)touch
{
	// Get the location of touch.
	CGPoint touchLocation = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
	
	// Parse our menu items and see if our touch exists within one.
	for (CCMenuItem* item in [self children])
	{
		CGPoint local = [item convertToNodeSpace:touchLocation];
		
        CGRect original = [item rect];
		CGRect r = CGRectMake(original.origin.x - 10, original.origin.y - 10, original.size.width + 20, original.size.height + 20);
		r.origin = CGPointZero;
		
		// If the touch was within this item. Return the item.
		if (CGRectContainsPoint(r, local))
		{
			return item;
		}
	}
	
	// Didn't touch an item.
	return nil;
}


-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Convert and store the location the touch began at.
	touchOrigin = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	
	// If we weren't in "waiting" state bail out.
	if (state != kCCMenuStateWaiting)
	{
		return NO;
	}
	
	// Activate the menu item if we are touching one.
	selectedItem = [self GetItemWithinTouch:touch];
	[selectedItem selected];
	
	// Only track touch if we are either in our menu system or dont care if they are outside of the menu grid.
	if (!bSwipeOnlyOnMenu || (bSwipeOnlyOnMenu && selectedItem) )
	{

        if(touchOrigin.y > 67 * __HIGHRES_SCALE) {
            state = kCCMenuStateTrackingTouch;
            return YES;
        }
		
	}
	
	return NO;
}

// Touch has ended. Process sliding of menu or press of menu item.
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{	
	// User has been sliding the menu.
	if( bMoving )
	{
		bMoving = false;
		
		// Do we have multiple pages?
		if( iPageCount >= 1 && (fMoveDeadZone < abs(fMoveDelta)))
		{
			// Are we going forward or backward?
			bool bForward = (fMoveDelta < 0) ? true : false;
			
			// Do we have a page available?
			if(bForward && (iPageCount>=iCurrentPage+1))
			{
				// Increment currently active page.
				iCurrentPage++;
			}
			else if(!bForward && (iCurrentPage > 0))
			{
				// Decrement currently active page.
				iCurrentPage--;
			}
		}

		// Start sliding towards the current page.
		[self moveToCurrentPage];	
		if([self.delegate respondsToSelector:@selector(menu:didScrollToPage:)]) {
            [self.delegate menu:self didScrollToPage:iCurrentPage];
        }
        [selectedItem unselected];
		
		
	}
	// User wasn't sliding menu and simply tapped the screen. Activate the menu item.
	else 
	{
		[selectedItem unselected];
		[selectedItem activate];
	}

	// Back to waiting state.
	state = kCCMenuStateWaiting;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[selectedItem unselected];
	
	state = kCCMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Calculate the current touch point during the move.
	touchStop = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];

	// Distance between the origin of the touch and current touch point.
	fMoveDelta = (bVerticalPaging) ? (touchStop.y - touchOrigin.y) : (touchStop.x - touchOrigin.x);

	// Set our position.
	[self setPosition:[self GetPositionOfCurrentPageWithOffset:fMoveDelta]];
	bMoving = true;
}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
- (BOOL)ccMouseDown:(NSEvent *)event {
    
	// Convert and store the location the touch began at.
	touchOrigin = [[CCDirector sharedDirector] convertEventToGL:event];

	
	// If we weren't in "waiting" state bail out.
	if (state != kCCMenuStateWaiting)
	{
		return NO;
	}
	
	// Activate the menu item if we are touching one.
	selectedItem = [self GetItemWithinEvent:event];
	[selectedItem selected];
	
	// Only track touch if we are either in our menu system or dont care if they are outside of the menu grid.
	if (!bSwipeOnlyOnMenu || (bSwipeOnlyOnMenu && selectedItem) )
	{
		state = kCCMenuStateTrackingTouch;
		return YES;
	}
	
	return NO;
}
- (BOOL)ccMouseDragged:(NSEvent *)event {
	// Calculate the current touch point during the move.
	touchStop = [[CCDirector sharedDirector] convertEventToGL:event];
    
	// Distance between the origin of the touch and current touch point.
	fMoveDelta = (bVerticalPaging) ? (touchStop.y - touchOrigin.y) : (touchStop.x - touchOrigin.x);
    
	// Set our position.
	[self setPosition:[self GetPositionOfCurrentPageWithOffset:fMoveDelta]];
	bMoving = true;
    
    return YES;
}
- (BOOL)ccMouseUp:(NSEvent *)event {
	// User has been sliding the menu.
	if( bMoving )
	{
		bMoving = false;
		
		// Do we have multiple pages?
		if( iPageCount >= 1 && (fMoveDeadZone < abs(fMoveDelta)))
		{
			// Are we going forward or backward?
			bool bForward = (fMoveDelta < 0) ? true : false;
			
			// Do we have a page available?
			if(bForward && (iPageCount>=iCurrentPage+1))
			{
				// Increment currently active page.
				iCurrentPage++;
			}
			else if(!bForward && (iCurrentPage > 0))
			{
				// Decrement currently active page.
				iCurrentPage--;
			}
		}
        
		// Start sliding towards the current page.
		[self moveToCurrentPage];	
		if([self.delegate respondsToSelector:@selector(menu:didScrollToPage:)]) {
            [self.delegate menu:self didScrollToPage:iCurrentPage];
        }
        [selectedItem unselected];
		
		
	}
	// User wasn't sliding menu and simply tapped the screen. Activate the menu item.
	else 
	{
		[selectedItem unselected];
		[selectedItem activate];
	}
    
	// Back to waiting state.
	state = kCCMenuStateWaiting;
    
    return YES;
}
- (CCMenuItem*)GetItemWithinEvent:(NSEvent*)event
{
	// Get the location of touch.
	CGPoint touchLocation = [[CCDirector sharedDirector] convertEventToGL:event];


	// Parse our menu items and see if our touch exists within one.
	for (CCMenuItem* item in [self children])
	{
		CGPoint local = [item convertToNodeSpace:touchLocation];
		
        CGRect original = [item rect];
		CGRect r = CGRectMake(original.origin.x - 10, original.origin.y - 10, original.size.width + 20, original.size.height + 20);
		r.origin = CGPointZero;
		
		// If the touch was within this item. Return the item.
		if (CGRectContainsPoint(r, local))
		{
			return item;
		}
	}
	
	// Didn't touch an item.
	return nil;
}
#endif

- (CGPoint) GetPositionOfCurrentPage
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	return (bVerticalPaging) ?
		CGPointMake(menuOrigin.x,menuOrigin.y-(iCurrentPage*winSize.height))
		: CGPointMake((menuOrigin.x-(iCurrentPage*winSize.width)),menuOrigin.y);
}

- (CGPoint) GetPositionOfCurrentPageWithOffset:(float)offset
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	return (bVerticalPaging) ?
	CGPointMake(menuOrigin.x,menuOrigin.y-(iCurrentPage*winSize.height)+offset)
	: CGPointMake((menuOrigin.x-(iCurrentPage*winSize.width)+offset),menuOrigin.y);
}



// Returns whether or not we should only allow swiping on the actual grid.
- (bool) IsSwipingOnMenuOnlyEnabled
{
	return bSwipeOnlyOnMenu;
}

// Sets the ability to swipe only on the menu or utilize entire screen for swiping.
- (void) SetSwipingOnMenuOnly:(bool)bValue
{
	bSwipeOnlyOnMenu = bValue;
}

// Returns the swiping dead zone. 
- (float) GetSwipeDeadZone
{
	return fMoveDeadZone;
}

- (void) SetSwipeDeadZone:(float)fValue
{
	fMoveDeadZone = fValue;
}

// Returns wheather or not vertical paging is enabled.
- (bool) IsVerticallyPaged
{
	return bVerticalPaging;
}

// Sets the vertical paging flag.
- (void) SetVerticalPaging:(bool)bValue
{
	bVerticalPaging = bValue;
	//[self buildGridVertical];
}

@end