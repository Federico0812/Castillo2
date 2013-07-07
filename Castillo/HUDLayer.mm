//
//  GameScene.mm
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	info@gamextar.com
//	http://www.gamextar.com - iPhone Development
//
//

#import "HUDLayer.h"
#import "BuildScene.h"


@implementation GameHUD


// Shared HUD instance
static GameHUD *sharedManager_ = nil;

+ (GameHUD *)sharedManager
{
	if (!sharedManager_)
	{
		sharedManager_ = [[super allocWithZone:nil] init];
	}
	return sharedManager_;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax; //denotes an object that cannot be released
}


- (id)autorelease
{
	return self;
}

- (id)init
{
	if( (self = [super init]) )
	{
		
		// NSLog(@"HUD %i", [self retainCount]); 
		
        size = [[CCDirector sharedDirector] winSize];

        self.touchEnabled = YES;
        
		    NSLog (@"will init");


	}
	return self;
}

- (void)dealloc
{
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

-(void) setGame: (BuildScene*) newGame
{
	game = newGame;
}


- (void) showHUD
{
    NSLog (@"my hud");
    CCSprite *controller = [CCSprite spriteWithFile:@"controller.png"];
    controller.position = ccp(892, 76);
    controller.zOrder = 50;
    [self addChild:controller];
 
    /*
    CCMenu * up = [CCMenu menuWithItems: nil];
    CCMenuItemImage * upbut = [CCMenuItemImage itemFromNormalImage:@"block1.png" selectedImage:@"block1.png" target:self selector:@selector(up:)];
    up.position = ccp(920, 114);
    up.zOrder = 50;
    upbut.opacity = 0;
    upbut.scaleY = .6f;
    upbut.scaleX = 1.2f;
    
    [up addChild:upbut];
    
    [self addChild:up];
*/
}

-(void)up:(CCMenuItemImage *) sender {
  
    [game jumpMixus];
}
@end
