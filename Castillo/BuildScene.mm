//
//  BuildScene.mm
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//
// Import the interfaces
#import "BuildScene.h"
#import "WarScene.h"
#import "HUDLayer.h"
#define PTM_RATIO 32

#define kRADIAL_GRAVITY_FORCE 250.0f

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;  
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

// Build implementation
@implementation BuildScene

-(void)afterStep {
	// process collisions and result from callbacks called by the step
}
////////////////////////////////////////////////////////////////////////////////
-(void)step:(ccTime)dt {
	float32 frameTime = dt;
	int stepsPerformed = 0;
	while ( (frameTime > 0.0) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS) ){
		float32 deltaTime = std::min( frameTime, FIXED_TIMESTEP );
		frameTime -= deltaTime;
		if (frameTime < MINIMUM_TIMESTEP) {
			deltaTime += frameTime;
			frameTime = 0.0f;
		}
		world->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
		stepsPerformed++;
		[self afterStep]; // process collisions and result from callbacks called by the step
	}
	world->ClearForces ();
}
////////////////////////////////////////////////////////////////////////////////
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BuildScene *layer = [BuildScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	 [scene addChild:[GameHUD sharedManager]z:10];
	// return the scene
	return scene;
}
////////////////////////////////////////////////////////////////////////////////
// initialize your instance here
-(id) init
{
	if( (self=[super init])) {
		
		// enable touches
        self.touchEnabled = YES;
		// enable accelerometer
        self.accelerometerEnabled = YES;
        
        
		[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
        
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, 0.0f);
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity);
		
		world->SetContinuousPhysics(true);
		/*
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw();
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2Draw::e_shapeBit;
		flags += b2Draw::e_jointBit;
		m_debugDraw->SetFlags(flags);
		*/
        
		[self schedule: @selector(tick:) interval:1.0f/60.0f];
		
        //TUTORIAL - loading one of the levels - test each level to see how it works
        lh = [[LevelHelperLoader alloc] initWithContentOfFile:@"R1.1"];
	        
        //creating the objects
        [lh addObjectsToWorld:world cocos2dLayer:self];
        
        if([lh hasPhysicBoundaries])
            [lh createPhysicBoundaries:world];
        
        if(![lh isGravityZero])
            [lh createGravity:world];
        
        self.position = ccpAdd(self.position,  ccp(0,-1000));
        // Define the ground body.
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0, 0); // bottom-left corner
        
        // Call the body factory which allocates memory for the ground body
        // from a pool and creates the ground box shape (also from a pool).
        // The body is also added to the world.
        b2Body* groundBody = world->CreateBody(&groundBodyDef);
        
        // Define the ground box shape.
        b2PolygonShape groundBox;		
        
        // Create our static "Planet"
        b2CircleShape shape;
        shape.m_radius = 26.0f;
        shape.m_p.Set(15.0f, 12.2f);
        b2FixtureDef fd;
        fd.shape = &shape;
        planet = groundBody->CreateFixture(&fd);
         redder = false;
        crops = true;
        
        options = [CCMenu menuWithItems:nil];
        //setting amounts!!!!
        intAmount1 = 225;
        intAmount2 = 100;
        intAmount3 = 1;
        intAmount4 = 5;
        intAmount5 = 2;
        
        [[GameHUD sharedManager] setGame:self];
	

      
        amount1 = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:23];
        amount1.color = ccWHITE;
       amount1.position = ccp(180,1700);
        [amount1 setString: [NSString stringWithFormat:@"%i", intAmount1]];
        CCMenuItemLabel *labelItem1 = [CCMenuItemLabel itemWithLabel:amount1];
        amount2 = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:23];
        amount2.color = ccWHITE;
        amount2.position = ccp(180,1550);
        [amount2 setString: [NSString stringWithFormat:@"%i", intAmount2]];
        CCMenuItemLabel *labelItem2 = [CCMenuItemLabel itemWithLabel:amount2];
        amount3 = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:23];
        amount3.color = ccWHITE;
        amount3.position = ccp(180,1400);
        [amount3 setString: [NSString stringWithFormat:@"%i", intAmount3]];
        CCMenuItemLabel *labelItem3 = [CCMenuItemLabel itemWithLabel:amount3];
        amount4 = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:23];
        amount4.color = ccWHITE;
        amount4.position = ccp(180,1250);
        [amount4 setString: [NSString stringWithFormat:@"%i", intAmount4]];
        CCMenuItemLabel *labelItem4 = [CCMenuItemLabel itemWithLabel:amount4];
        amount5 = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:23];
        amount5.color = ccWHITE;
        amount5.position = ccp(180,1100);
        [amount5 setString: [NSString stringWithFormat:@"%i", intAmount5]];
        CCMenuItemLabel *labelItem5 = [CCMenuItemLabel itemWithLabel:amount5];
        advert   = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:45];
        advert.color = ccWHITE;
        advert.position = ccp(512,1378);
        [advert setString: [NSString stringWithFormat:@"Use blocks to build a basic structure"]];
        CCMenuItemLabel *labelAdvert = [CCMenuItemLabel itemWithLabel:advert];
        
        [options addChild:labelItem1 z:1];
        [options addChild:labelItem2 z:1];
        [options addChild:labelItem3 z:1];
        [options addChild:labelItem4 z:1];
        [options addChild:labelItem5 z:1];
        [options addChild:labelAdvert z:1];
        
        firstTime = true;
        destroying = false;
        forcedThree = false;
        forcedFour = false;
        stopAccel = false;
        float teppe = 0;
        options.position = ccp(0,teppe);
        NSLog([NSString stringWithFormat:@"posx %f, posy %f",[self position].x, [self position].y]);
         option1 = [CCMenuItemImage itemFromNormalImage:@"block1.png" selectedImage:@"block1.png" target:self selector:@selector(onSelection:)];
         option2 = [CCMenuItemImage itemFromNormalImage:@"block2.png" selectedImage:@"block2.png" target:self selector:@selector(onSelection:)];
         option3 = [CCMenuItemImage itemFromNormalImage:@"king.png" selectedImage:@"king.png" target:self selector:@selector(onSelection:)];
         option4 = [CCMenuItemImage itemFromNormalImage:@"armory.png" selectedImage:@"armory.png" target:self selector:@selector(onSelection:)];
         option5 = [CCMenuItemImage itemFromNormalImage:@"door.png" selectedImage:@"door.png" target:self selector:@selector(onSelection:)];
         option6 = [CCMenuItemImage itemFromNormalImage:@"destroy.png" selectedImage:@"destroy.png" target:self selector:@selector(onSelection:)];
         option7 = [CCMenuItemImage itemFromNormalImage:@"opt7.png" selectedImage:@"opt7.png" target:self selector:@selector(onSelection:)];
         option8 = [CCMenuItemImage itemFromNormalImage:@"opt8.png" selectedImage:@"opt8.png" target:self selector:@selector(onSelection:)];
         option9 = [CCMenuItemImage itemFromNormalImage:@"opt9.png" selectedImage:@"opt9.png" target:self selector:@selector(onSelection:)];
         option10 = [CCMenuItemImage itemFromNormalImage:@"opt10.png" selectedImage:@"opt10.png" target:self selector:@selector(onSelection:)];
         option11 = [CCMenuItemImage itemFromNormalImage:@"buildemode.png" selectedImage:@"buildemode.png" target:self selector:@selector(onSelection:)];
         option12 = [CCMenuItemImage itemFromNormalImage:@"opt12.png" selectedImage:@"opt12.png" target:self selector:@selector(onSelection:)];
        option1.position = ccp(80,1700);  option1.tag = 0;
        option2.position = ccp(80,1550);option2.tag = 1;
        option3.position = ccp(80,1400);option3.tag = 2;
        option4.position = ccp(80,1250);option4.tag = 3;
        option5.position = ccp(80,1100);option5.tag = 4;
        option6.position = ccp(240,1730);option6.tag = 5;
        option7.position = ccp(520,2700);option7.tag = 6;
        option8.position = ccp(600,2700);option8.tag = 7;
        option9.position = ccp(680,2700);option9.tag = 8;
        option10.position = ccp(760,2700); option10.tag = 9;
        option11.position = ccp(810,1713);option11.tag = 10;
        option12.position = ccp(920,2700);option12.tag = 11;
        [options addChild:option1];
        [options addChild:option2];
        [options addChild:option3];
        [options addChild:option4];
        [options addChild:option5];
        [options addChild:option6];
        [options addChild:option7];
        [options addChild:option8];
        [options addChild:option9];
        [options addChild:option10];
        [options addChild:option11];
        [options addChild:option12];
        [self addChild:options];
        [self setupCollisionHandling];
        
    
       

        
        
        [[GameHUD sharedManager] showHUD];
        
        Fader = [[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(fading) userInfo:nil repeats:NO] retain];
        element = 0; destroying = false;

        mixus = [lh spriteWithUniqueName:@"mixus1"];
        
    
	}
	return self;
}




-(void) fading {
    if (advert.opacity != 0) {
    CCAction *fadeOut = [CCFadeOut actionWithDuration:0.5];
        [advert runAction:fadeOut];
        [Fader invalidate];
        
    }}




-(void) setupCollisionHandling {
    
    [lh useLevelHelperCollisionHandling];
    
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:BLOCK1 andTagB: BLOCK1 idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:BLOCK1 andTagB: BLOCK2 idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:BLOCK1 andTagB: SHOOTER idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:BLOCK1 andTagB: DOOR idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:BLOCK1 andTagB: KING idListener:self selListener:@selector(bothStatic:)];
    
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:BLOCK2 andTagB: BLOCK2 idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:BLOCK2 andTagB: SHOOTER idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:BLOCK2 andTagB: DOOR idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:BLOCK2 andTagB: KING idListener:self selListener:@selector(bothStatic:)];
    
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:SHOOTER andTagB: SHOOTER idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:SHOOTER andTagB: DOOR idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:SHOOTER andTagB: KING idListener:self selListener:@selector(bothStatic:)];
    
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:DOOR andTagB: DOOR idListener:self selListener:@selector(bothStatic:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:DOOR andTagB: KING idListener:self selListener:@selector(bothStatic:)];
}
-(void)bothStatic:(LHContactInfo*)contact{
    LHSprite *a = [contact spriteA];
    LHSprite *b = [contact spriteB];
    static1 = a;
    static2 = b;
    makeStatic = true;
}



-(void)onSelection:(CCMenuItemImage *) sender {
    NSLog(@"selecciona");

    if (sender.tag == 0) {element = 0; destroying = false;}
    if (sender.tag == 1) {element = 1; destroying = false;}
    if (sender.tag == 2) {element = 2; destroying = false;}
    if (sender.tag == 3) {element = 3; destroying = false;}
    if (sender.tag == 4) {element = 4; destroying = false;}
    if (sender.tag == 5) {
        destroying = true;
    }
    if (sender.tag == 6) {element = 6;}
    if (sender.tag == 7) {element = 7;}
    if (sender.tag == 8) {element = 8;}
    if (sender.tag == 9) {element = 9;}
    if (sender.tag == 10) {
    
        [self savelevel];
    
    }
    if (sender.tag == 11) {
      
            if (redder) {redder = false;}
            else  {redder = true;}       
    }
}

////////////////////////////////////////////////////////////////////////////////
//FIX TIME STEPT------------>>>>>>>>>>>>>>>>>>
-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	float pi = 3.1416f;
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		b2Body* ground = planet->GetBody();
        b2CircleShape* circle = (b2CircleShape*)planet->GetShape();
        // Get position of our "Planet" - Nick
        b2Vec2 center = ground->GetWorldPoint(circle->m_p);
        // Get position of our current body in the iteration - Nick
        b2Vec2 positionVec = b->GetPosition();
        // Get the distance between the two objects. - Nick
     /*   CGPoint position2 = ccp (positionVec.x, positionVec.y);
        float angle = ccpToAngle(position2);
        CGPoint position3 = ccpForAngle(angle);
        b2Vec2 newposition (-position3.x,-position3.y);*/
        b2Vec2 d = center - positionVec;
        // The further away the objects are, the weaker the gravitational force is - Nick
        float force = 600 + d.LengthSquared(); // 150 can be changed to adjust the amount of force - Nick
        d.Normalize();

        
        b2Vec2 F =force * d;
        // Finally apply a force on the body in the direction of the "Planet" - Nick
        b->ApplyForce(F, positionVec);
		
        if (crops) 
        {crops= false;
            [self chargelevel];}
            
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
    
    
    
    
    if (touchesOnScreen == 1)
        
    {[self lateralMoved];}
    
    LHSprite * base = [lh spriteWithUniqueName:@"planet"];
    
    float xdist = [mixus position].x - [base position].x;
    float ydist = [mixus position].y - [base position].y;
    
    float mixusNX = sqrtf(powf(xdist, 2.0f) + powf(ydist, 2.0f));
        
    if (firstTime) {firstTime = false; mixusDX = mixusNX;}
    
    self.position = ccpAdd(ccpSub(self.position, ccp (0, -mixusDX)),  ccp (0, -mixusNX));
    
    option1.position = ccpAdd(ccpSub(option1.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option2.position = ccpAdd(ccpSub(option2.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option3.position = ccpAdd(ccpSub(option3.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option4.position = ccpAdd(ccpSub(option4.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option5.position = ccpAdd(ccpSub(option5.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option6.position = ccpAdd(ccpSub(option6.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option7.position = ccpAdd(ccpSub(option7.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option8.position = ccpAdd(ccpSub(option8.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option9.position = ccpAdd(ccpSub(option9.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option10.position = ccpAdd(ccpSub(option10.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option11.position = ccpAdd(ccpSub(option11.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    option12.position = ccpAdd(ccpSub(option12.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    amount1.position = ccpAdd(ccpSub(amount1.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    amount2.position = ccpAdd(ccpSub(amount2.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    amount3.position = ccpAdd(ccpSub(amount3.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    amount4.position = ccpAdd(ccpSub(amount4.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    amount5.position = ccpAdd(ccpSub(amount5.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    advert.position = ccpAdd(ccpSub(advert.position, ccp (0, mixusDX)),  ccp (0, mixusNX));
    
    //down
    if ([option1 position].y < 1700) {option1.position = ccp([option1 position].x, 1700);}
    if ([ option2 position].y < 1550) { option2.position = ccp([ option2 position].x, 1550);}
    if ([ option3 position].y < 1400) { option3.position = ccp([ option3 position].x, 1400);}
    if ([ option4 position].y < 1250) { option4.position = ccp([ option4 position].x, 1250);}
    if ([ option5 position].y < 1100) { option5.position = ccp([ option5 position].x, 1100);}
    if ([ option6 position].y < 1730) { option6.position = ccp([ option6 position].x, 1730);}
    if ([ option7 position].y < 2700) { option7.position = ccp([ option7 position].x, 2700);}
    if ([ option8 position].y < 2700) { option8.position = ccp([ option8 position].x, 2700);}
    if ([ option9 position].y < 2700) { option9.position = ccp([ option9 position].x, 2700);}
    if ([ option10 position].y < 2700) { option10.position = ccp([ option10 position].x, 2700);}
    if ([ option11 position].y < 1713) { option11.position = ccp([ option11 position].x, 1713);}
    if ([ option12 position].y < 2700) { option12.position = ccp([ option12 position].x, 2700);}
    if ([ amount1 position].y < 1700) { amount1.position = ccp([ amount1 position].x, 1700);}
    if ([ amount2 position].y < 1550) { amount2.position = ccp([ amount2 position].x, 1550);}
    if ([ amount3 position].y < 1400) { amount3.position = ccp([ amount3 position].x, 1400);}
    if ([ amount4 position].y < 1250) { amount4.position = ccp([ amount4 position].x, 1250);}
    if ([ amount5 position].y < 1100) { amount5.position = ccp([ amount5 position].x, 1100);}
    if ([ advert position].y < 1378) { advert.position = ccp([advert position].x, 1378);}
    
    ///upper
    if ([option1 position].y > 3700) {option1.position = ccp([option1 position].x, 3700);}
    if ([ option2 position].y > 3550) { option2.position = ccp([ option2 position].x, 3550);}
    if ([ option3 position].y > 3400) { option3.position = ccp([ option3 position].x, 3400);}
    if ([ option4 position].y > 3250) { option4.position = ccp([ option4 position].x, 3250);}
    if ([ option5 position].y > 3100) { option5.position = ccp([ option5 position].x, 3100);}
    if ([ option6 position].y > 3730) { option6.position = ccp([ option6 position].x, 3730);}
    if ([ option7 position].y > 4700) { option7.position = ccp([ option7 position].x, 4700);}
    if ([ option8 position].y > 4700) { option8.position = ccp([ option8 position].x, 4700);}
    if ([ option9 position].y > 4700) { option9.position = ccp([ option9 position].x, 4700);}
    if ([ option10 position].y > 4700) { option10.position = ccp([ option10 position].x, 4700);}
    if ([ option11 position].y > 3713) { option11.position = ccp([ option11 position].x, 3713);}
    if ([ option12 position].y > 4700) { option12.position = ccp([ option12 position].x, 4700);}
    if ([ amount1 position].y > 3700) { amount1.position = ccp([ amount1 position].x, 3700);}
    if ([ amount2 position].y > 3550) { amount2.position = ccp([ amount2 position].x, 3550);}
    if ([ amount3 position].y > 3400) { amount3.position = ccp([ amount3 position].x, 3400);}
    if ([ amount4 position].y > 3250) { amount4.position = ccp([ amount4 position].x, 3250);}
    if ([ amount5 position].y > 3100) { amount5.position = ccp([ amount5 position].x, 3100);}
    if ([ advert position].y > 3378) { advert.position = ccp([ advert position].x, 3378);}
    
    
    if ([self position].y >-1000) {self.position = ccp (0,-1000);}
    if ([self position].y <-3000) {self.position = ccp (0,-3000);}
    
    
    mixusDX = mixusNX;

    
    
    
    float RotatePi;
    RotatePi = -ccpToAngle(ccp(xdist, ydist));
    
    float nextAngle = RotatePi + pi;
    nextAngle = nextAngle / (2 * pi);
    nextAngle = 360 * nextAngle - 90;
    
    
    [mixus transformRotation:nextAngle];
    
    self.rotation = -mixus.rotation;
    options.rotation = mixus.rotation;
    

    if (makeStatic) {
        [static1 makeStatic];
        [static2 makeStatic];
        makeStatic = false;
    }
    
}
//FIX TIME STEPT<<<<<<<<<<<<<<<----------------------
////////////////////////////////////////////////////////////////////////////////


- (void) savelevel {
    if (intAmount3 > 0) {
        [advert setString:[NSString stringWithFormat:@"You need a king's chamber still"]];
        [Fader invalidate];
        advert.opacity = 255;
        Fader = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fading) userInfo:nil repeats:NO] retain];
        
    }
    else {
        
            NSLog(@"saving level");
    NSMutableArray* levelsave = [[NSMutableArray alloc]init];
    
    
    NSArray* spritesR = [lh spritesWithTag:BLOCK1]; { 
        for (LHSprite* spr in spritesR) {
            
    NSNumber *tagspr = [NSNumber numberWithInt:spr.tag];
    NSNumber *evolution = [NSNumber numberWithInt:1];
    NSNumber *positionx = [NSNumber numberWithFloat:[spr position].x];
    NSNumber *positiony = [NSNumber numberWithFloat:[spr position].y];
    NSNumber *rotation = [NSNumber numberWithFloat:[spr rotation]];
   
            [levelsave addObject:tagspr];
            [levelsave addObject:evolution];
            [levelsave addObject:positionx];
            [levelsave addObject:positiony];
            [levelsave addObject:rotation];
            
        }}
    
    NSArray* spritesS = [lh spritesWithTag:BLOCK2]; { 
        for (LHSprite* spr in spritesS) {
            
            NSNumber *tagspr = [NSNumber numberWithInt:spr.tag];
            NSNumber *evolution = [NSNumber numberWithInt:1];
            NSNumber *positionx = [NSNumber numberWithFloat:[spr position].x];
            NSNumber *positiony = [NSNumber numberWithFloat:[spr position].y];
            NSNumber *rotation = [NSNumber numberWithFloat:[spr rotation]];
            
            [levelsave addObject:tagspr];
            [levelsave addObject:evolution];
            [levelsave addObject:positionx];
            [levelsave addObject:positiony];
            [levelsave addObject:rotation];
            
        }}
    
    NSArray* spritesT = [lh spritesWithTag:KING]; { 
        for (LHSprite* spr in spritesT) {
            
            NSNumber *tagspr = [NSNumber numberWithInt:spr.tag];
            NSNumber *evolution = [NSNumber numberWithInt:1];
            NSNumber *positionx = [NSNumber numberWithFloat:[spr position].x];
            NSNumber *positiony = [NSNumber numberWithFloat:[spr position].y];
            NSNumber *rotation = [NSNumber numberWithFloat:[spr rotation]];
            
            [levelsave addObject:tagspr];
            [levelsave addObject:evolution];
            [levelsave addObject:positionx];
            [levelsave addObject:positiony];
            [levelsave addObject:rotation];
            
        }}
    
    NSArray* spritesU = [lh spritesWithTag:SHOOTER]; { 
        for (LHSprite* spr in spritesU) {
            
            NSNumber *tagspr = [NSNumber numberWithInt:spr.tag];
            NSNumber *evolution = [NSNumber numberWithInt:1];
            NSNumber *positionx = [NSNumber numberWithFloat:[spr position].x];
            NSNumber *positiony = [NSNumber numberWithFloat:[spr position].y];
            NSNumber *rotation = [NSNumber numberWithFloat:[spr rotation]];
            
            [levelsave addObject:tagspr];
            [levelsave addObject:evolution];
            [levelsave addObject:positionx];
            [levelsave addObject:positiony];
            [levelsave addObject:rotation];
            
        }}
    
    NSArray* spritesV = [lh spritesWithTag:DOOR]; { 
        for (LHSprite* spr in spritesV) {
            
            NSNumber *tagspr = [NSNumber numberWithInt:spr.tag];
            NSNumber *evolution = [NSNumber numberWithInt:1];
            NSNumber *positionx = [NSNumber numberWithFloat:[spr position].x];
            NSNumber *positiony = [NSNumber numberWithFloat:[spr position].y];
            NSNumber *rotation = [NSNumber numberWithFloat:[spr rotation]];
            
            [levelsave addObject:tagspr];
            [levelsave addObject:evolution];
            [levelsave addObject:positionx];
            [levelsave addObject:positiony];
            [levelsave addObject:rotation];
            
        }}
    
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:levelsave] 
                                              forKey:[NSString stringWithFormat:@"DirectCastle"]]; 

  /*  [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.2 scene:[WarScene scene] withColor:ccWHITE]];*/
}}
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
        
    }

- (void) chargelevel {
    
    NSLog(@"loading level");
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *BoxNowUsed = [currentDefaults objectForKey:[NSString stringWithFormat:@"DirectCastle"]];
    
    int off1 = 0;
    int off2 = 0;
    int off3 = 0;
    int off4 = 0;
    int off5 = 0;
    
    
    if (BoxNowUsed != nil)
    {NSMutableArray *elementor = [NSKeyedUnarchiver unarchiveObjectWithData:BoxNowUsed];
        int counter = [elementor count];
        counter = counter / 5;
        NSLog([NSString stringWithFormat:@"cuenta da %i",counter]);

       
        for(int i = 0; i < counter; i++) {
            
            
            int meta = 5 * i;
            int sprtag =  [[elementor objectAtIndex:meta + 0] intValue];
            int evolution =  [[elementor objectAtIndex:meta + 1] intValue];
            float positionx = [[elementor objectAtIndex:meta + 2] floatValue];
            float positiony = [[elementor objectAtIndex:meta + 3] floatValue];
            float rotationer = [[elementor objectAtIndex:meta + 4] floatValue];
            
            NSLog([NSString stringWithFormat:@"sprite numero %i, tag %i, evolution %i, pos (%f,%f) rot %f",i,sprtag,evolution,positionx,positiony,rotationer]);
            LHSprite *apple;
            NSString *former;
            if (sprtag == 1) {former = [NSString stringWithFormat:@"block1"];
                off1++;                
            }
            if (sprtag == 2) {former = [NSString stringWithFormat:@"block2"];
                off2++;
            }
            if (sprtag == 3) {former = [NSString stringWithFormat:@"king"];
                off3++;
            }
            if (sprtag == 4) {former = [NSString stringWithFormat:@"emiter"];
                off4++;
            }
            if (sprtag == 5) {former = [NSString stringWithFormat:@"door1"];
                off5++;
            }
            apple =     [lh                 createSpriteWithName:[NSString stringWithFormat:@"%@",former]
                                                       fromSheet:@"initierBlue"
                                                      fromSHFile:@"initierBlue"];
            apple.tag = sprtag;
            CGPoint space = ccp(positionx, positiony);
            [apple transformPosition:space];
            [apple transformRotation: rotationer];
            // NSLog([NSString stringWithFormat:@"apple del apple pos (%f,%f) rot %f",[apple position].x, [apple position].y, apple.rotation]);
            apple.opacity = 225;
            
            
        }
        
        intAmount1 = intAmount1 - off1;
        intAmount2 = intAmount2 - off2;
        intAmount3 = intAmount3 - off3;
        intAmount4 = intAmount4 - off4;
        intAmount5 = intAmount5 - off5;

        [amount1 setString: [NSString stringWithFormat:@"%i", intAmount1]];
        [amount2 setString: [NSString stringWithFormat:@"%i", intAmount2]];
        [amount3 setString: [NSString stringWithFormat:@"%i", intAmount3]];
        [amount4 setString: [NSString stringWithFormat:@"%i", intAmount4]];
        [amount5 setString: [NSString stringWithFormat:@"%i", intAmount5]];
        
        
        
       
    }
    
    if (option3!=nil) {
    CGPoint place = option3.position;
    float rotate = options.rotation;
    stopAccel = true; NSLog(@"acelerometro no puede andar");
    [options removeChild:option3 cleanup:YES];
 
    option3 = [CCMenuItemImage itemFromNormalImage:@"king2.png" selectedImage:@"king2.png" target:self selector:@selector(onSelection:)];
    option3.tag = 2;
    option3.position = place;

    [options addChild:option3];
    options.rotation = rotate;
    
    forcedThree = false;
    stopAccel = false;
    }
    
    
    
    if (intAmount3 == 0) {
        CGPoint place = option4.position;
        CGPoint place2 = option5.position;
        CGPoint placemenu = options.position;
        float rotate = options.rotation;
        stopAccel = true; NSLog(@"acelerometro no puede andar");
        [option4 removeFromParentAndCleanup:YES];
        [option5 removeFromParentAndCleanup:YES];
        option4 = [CCMenuItemImage itemFromNormalImage:@"armory.png" selectedImage:@"armory.png" target:self selector:@selector(onSelection:)];
        option4.tag = 3;
        option4.position = place;
        [options addChild:option4];
        
        option5 = [CCMenuItemImage itemFromNormalImage:@"door.png" selectedImage:@"door.png" target:self selector:@selector(onSelection:)];
        option5.tag = 4;
        option5.position = place2;
        [options addChild:option5];
        
        options.rotation = rotate;
   
        forcedFour = false;
        stopAccel = false;
        
        
        
       
    }  
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchesOnScreen!=1) {
    
    NSLog(@"released");
    
    
    
    float pi = 3.14159f;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint touchingPoint = [[CCDirector sharedDirector] convertToGL:location];
    touchingPoint = ccpSub(touchingPoint, ccp(512, 384));
    float distex = touchingPoint.x;
    float distey = touchingPoint.y;
    
    
    float root = sqrtf(powf(distex, 2.0f) + powf(distey, 2.0f));
    float angleforth = ccpToAngle(touchingPoint);
    
    angleforth = angleforth + (2 * pi) * (self.rotation / 360);
    
    
    CGPoint newPoint = ccpForAngle(angleforth);
    newPoint.x = 512 + newPoint.x * root;
    newPoint.y = 384 + newPoint.y * root;
    
    

    
    ///newpoint termina
    
    float number = + pi / 2 + (2 * pi) * (self.rotation / 360);
    CGPoint rodant = ccpForAngle(number);
    float haut= -[self position].y;
    rodant = ccp(rodant.x *haut ,rodant.y *haut);
    
    touchingPoint = ccpAdd(newPoint, rodant);
 
    

    
    if (destroying) {
    NSLog(@"destruir espacio");
    NSArray* spritesR = [lh spritesWithTag:BLOCK1]; { 
        for (LHSprite* spr in spritesR) {
         float distancex =  touchingPoint.x - [spr position].x;
         float distancey =  touchingPoint.y - [spr position].y;
         
            bool dokill;
            dokill = true;
            float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
            if (rooter > 50) {dokill = false;}
            if (dokill) {
               
                [spr removeSelf];
               
                intAmount1++;
             
                
                [amount1 setString: [NSString stringWithFormat:@"%i", intAmount1]];
                 
            }}}
        
        NSArray* spritesS = [lh spritesWithTag:BLOCK2]; { 
            for (LHSprite* spr in spritesS) {
                float distancex =  touchingPoint.x - [spr position].x;
                float distancey =  touchingPoint.y - [spr position].y;
             
                bool dokill;
                dokill = true;
                float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
                if (rooter > 70) {dokill = false;}
                if (dokill) {
                    NSLog(@"hay un gatito 2");
                     [spr removeSelf];
                    intAmount2++;
                    [amount2 setString: [NSString stringWithFormat:@"%i", intAmount2]];
                     
                }}}
        
        NSArray* spritesT = [lh spritesWithTag:KING]; { 
            for (LHSprite* spr in spritesT) {
                float distancex =  touchingPoint.x - [spr position].x;
                float distancey =  touchingPoint.y - [spr position].y;
              
                bool dokill;
                dokill = true;
                float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
                if (rooter > 50) {dokill = false;}
                if (dokill) {
                  
                     [spr removeSelf];
                    intAmount3++;
                    [amount3 setString: [NSString stringWithFormat:@"%i", intAmount3]];
                     
                }}}
        
        NSArray* spritesU = [lh spritesWithTag:SHOOTER]; { 
            for (LHSprite* spr in spritesU) {
                float distancex =  touchingPoint.x - [spr position].x;
                float distancey =  touchingPoint.y - [spr position].y;
               
                bool dokill;
                dokill = true;
                float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
                if (rooter > 90) {dokill = false;}
                if (dokill) {
                   
                     [spr removeSelf];
                    intAmount4++;
                    [amount4 setString: [NSString stringWithFormat:@"%i", intAmount4]];
                     
                }}}
        
        NSArray* spritesV = [lh spritesWithTag:DOOR]; { 
            for (LHSprite* spr in spritesV) {
                float distancex =  touchingPoint.x - [spr position].x;
                float distancey =  touchingPoint.y - [spr position].y;
               
                bool dokill;
                dokill = true;
                float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
                if (rooter > 130) {dokill = false;}
                if (dokill) {
                    NSLog(@"hay un gatito 5");
                     [spr removeSelf];
                   intAmount5++;
                    [amount5 setString: [NSString stringWithFormat:@"%i", intAmount5]];
                    
                }}}
    
    
    
}
else {
    
    forcedThree = false;
    forcedFour = false;

    LHSprite *base;
    base = [lh spriteWithUniqueName:@"planet"];
    
    
    

    
    NSString *former;
    redder = false;
    bool blockage;
    blockage = false;
    bool secondblockage;
    bool demasiadoCercaDeAlguno;

    
    // nuevo para angulo bis
    float xdist = touchingPoint.x - [base position].x;
    float ydist = touchingPoint.y - [base position].y;
    
    
    float RotatePi;
    RotatePi = -ccpToAngle(ccp(xdist, ydist));
    
    float nextAngle = RotatePi + pi;
    nextAngle = nextAngle / (2 * pi);
    nextAngle = 360 * nextAngle - 90;
    
    
    

    
    
    secondblockage = true;
    demasiadoCercaDeAlguno = false;

    
    float distanceBASEx =  touchingPoint.x - [base position].x;
    float distanceBASEy =  touchingPoint.y - [base position].y;
    
    float rootBASE = sqrtf(powf(distanceBASEx, 2.0f) + powf(distanceBASEy, 2.0f));
   
    bool closeToEarth = true;
    
    if (rootBASE < 930) {
        secondblockage = false;
        closeToEarth = false;
    }
    if (rootBASE < 900) {
        demasiadoCercaDeAlguno = true;
        closeToEarth=false;
    }
    
   
    //cosas aplicable a muchos bloques!!
    
    LHSprite * closestOne;
    float shortestRooter = 20000;
    float rectificanteEnX;
    float rectificanteEnY;
    
    //definiendo valores para cada objeto
    
    NSMutableArray* rectificanteXarray = [[NSMutableArray alloc]init];
    NSMutableArray* rectificanteYarray = [[NSMutableArray alloc]init];
    
    //index = 0; OBJETO: BLOCK1;
    [rectificanteXarray addObject:[NSNumber numberWithInt:75]];
    [rectificanteYarray addObject:[NSNumber numberWithInt:75]];
    
    //index = 1; OBJETO: BLOCK2;
    [rectificanteXarray addObject:[NSNumber numberWithInt:150]];
    [rectificanteYarray addObject:[NSNumber numberWithInt:75]];
    
    //index = 2; OBJETO: KING;
    [rectificanteXarray addObject:[NSNumber numberWithInt:60]];
    [rectificanteYarray addObject:[NSNumber numberWithInt:145]];
    
    //index = 3; OBJETO: EMITER;
    [rectificanteXarray addObject:[NSNumber numberWithInt:180]];
    [rectificanteYarray addObject:[NSNumber numberWithInt:200]];
    
    //index = 4; OBJETO: DOOR;
    [rectificanteXarray addObject:[NSNumber numberWithInt:180]];
    [rectificanteYarray addObject:[NSNumber numberWithInt:300]];
    
    //index = 5; OBJETO: test;
    [rectificanteXarray addObject:[NSNumber numberWithInt:10]];
    [rectificanteYarray addObject:[NSNumber numberWithInt:10]];
    
    //index = 6; OBJETO: test;
    [rectificanteXarray addObject:[NSNumber numberWithInt:10]];
    [rectificanteYarray addObject:[NSNumber numberWithInt:10]];
    
    //index = 7; OBJETO: test;
    [rectificanteXarray addObject:[NSNumber numberWithInt:10]];
    [rectificanteYarray addObject:[NSNumber numberWithInt:10]];
    
    //index = 8; OBJETO: test;
    [rectificanteXarray addObject:[NSNumber numberWithInt:10]];
    [rectificanteYarray addObject:[NSNumber numberWithInt:10]];
    
    
    
    
    NSArray* spritesR1 = [lh spritesWithTag:BLOCK1]; {
        for (LHSprite* spr in spritesR1) {
       
            
            float distancex =  touchingPoint.x - [spr position].x;
            float distancey =  touchingPoint.y - [spr position].y;
    
            float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
            if (rooter < shortestRooter) {shortestRooter = rooter; closestOne = spr;
                rectificanteEnX = [[rectificanteXarray objectAtIndex: spr.tag -1] intValue];
                rectificanteEnY = [[rectificanteYarray objectAtIndex: spr.tag -1] intValue];
            }
        
        }}
    
    NSArray* spritesR2 = [lh spritesWithTag:BLOCK2]; {
        for (LHSprite* spr in spritesR2) {
           
            float distancex =  touchingPoint.x - [spr position].x;
            float distancey =  touchingPoint.y - [spr position].y;
            
            float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
            if (rooter < shortestRooter) {shortestRooter = rooter; closestOne = spr;
                rectificanteEnX = [[rectificanteXarray objectAtIndex: spr.tag -1] intValue];
                rectificanteEnY = [[rectificanteYarray objectAtIndex: spr.tag -1] intValue];
            }
            
        }}
 
    
    NSArray* spritesR3 = [lh spritesWithTag:KING]; {
        for (LHSprite* spr in spritesR3) {
            
            
            float distancex =  touchingPoint.x - [spr position].x;
            float distancey =  touchingPoint.y - [spr position].y;
            
            float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
            if (rooter < shortestRooter) {shortestRooter = rooter; closestOne = spr;
                rectificanteEnX = [[rectificanteXarray objectAtIndex: spr.tag -1] intValue];
                rectificanteEnY = [[rectificanteYarray objectAtIndex: spr.tag -1] intValue];
            }
            
        }}
    
    NSArray* spritesR4 = [lh spritesWithTag:SHOOTER]; {
        for (LHSprite* spr in spritesR4) {

            
            float distancex =  touchingPoint.x - [spr position].x;
            float distancey =  touchingPoint.y - [spr position].y;
            
            float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
            if (rooter < shortestRooter) {shortestRooter = rooter; closestOne = spr;
                rectificanteEnX = [[rectificanteXarray objectAtIndex: spr.tag -1] intValue];
                rectificanteEnY = [[rectificanteYarray objectAtIndex: spr.tag -1] intValue];
            }
            
        }}
    
    
    NSArray* spritesR5 = [lh spritesWithTag:DOOR]; {
        for (LHSprite* spr in spritesR5) {

            float distancex =  touchingPoint.x - [spr position].x;
            float distancey =  touchingPoint.y - [spr position].y;
            
            float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
            if (rooter < shortestRooter) {shortestRooter = rooter; closestOne = spr;
                rectificanteEnX = [[rectificanteXarray objectAtIndex: spr.tag -1] intValue];
                rectificanteEnY = [[rectificanteYarray objectAtIndex: spr.tag -1] intValue];
            }
            
        }}
    
    
    //copy for any further block
    
    
    if (closeToEarth == false)
    {  NSLog(@"priority for land");  }
    else { if (shortestRooter < 300) {

                    LHSprite * spr;
                    spr = closestOne;
                    
                    secondblockage = false;

                    float distanceCenterX =  [spr position].x - [base position].x;
                    float distanceCenterY =  [spr position].y - [base position].y;
                    float proRooter = sqrtf(powf(distanceCenterX, 2.0f) + powf(distanceCenterY, 2.0f));
                    
                    bool movimientoHorizontal = true;
                    
                    
                    if (proRooter < rootBASE - 50) {
                        movimientoHorizontal = false;
                        float rectifiedAngle;
                        rectifiedAngle = ccpToAngle (ccp (distanceCenterX,distanceCenterY));
                        CGPoint newtouch = ccpForAngle(rectifiedAngle);
                        float a = [base position].x + newtouch.x * rootBASE;
                        float b = [base position].y + newtouch.y * rootBASE;
                        newtouch = ccp (a, b);
                        touchingPoint = newtouch;
                        
                        float direction = - ((nextAngle) * 2 * pi)/360 - 3 * pi / 2;
                        CGPoint lateralRectifier = ccpForAngle(direction);
                        NSLog(@"esta a la derecha, se mueve angulo %f", direction);
                        float rectificanteEnYbis = [[rectificanteYarray objectAtIndex: element] intValue]/2 + rectificanteEnY/2;
                        lateralRectifier = ccp (lateralRectifier.x * rectificanteEnYbis, lateralRectifier.y * rectificanteEnYbis);
                        
                        touchingPoint = ccp (([spr position].x + lateralRectifier.x), ([spr position].y + lateralRectifier.y));
                        
                    }
                    
                    if (proRooter - 50 > rootBASE) {
                        movimientoHorizontal = false;
                        float rectifiedAngle;
                        rectifiedAngle = ccpToAngle (ccp (distanceCenterX,distanceCenterY));
                        CGPoint newtouch = ccpForAngle(rectifiedAngle);
                        float a = [base position].x + newtouch.x * rootBASE;
                        float b = [base position].y + newtouch.y * rootBASE;
                        newtouch = ccp (a, b);
                        touchingPoint = newtouch;
                        
                        float direction = - ((nextAngle) * 2 * pi)/360 - pi / 2;
                        CGPoint lateralRectifier = ccpForAngle(direction);
                        NSLog(@"esta a la derecha, se mueve angulo %f", direction);
                        float rectificanteEnYbis = [[rectificanteYarray objectAtIndex: element] intValue]/2 + rectificanteEnY/2;
                        lateralRectifier = ccp (lateralRectifier.x * rectificanteEnYbis, lateralRectifier.y * rectificanteEnYbis);
                        
                        touchingPoint = ccp (([spr position].x + lateralRectifier.x), ([spr position].y + lateralRectifier.y));
                        
                    }
                    
                    
                    if (movimientoHorizontal) {
                        // definir hacia los costados
                        float distanceCenterNewX =  touchingPoint.x - [base position].x;
                        float distanceCenterNewY =  touchingPoint.y - [base position].y;
                        
                        float closeBlockRotation = ccpToAngle (ccp (distanceCenterX,distanceCenterY));
                        float newBlockRotation = ccpToAngle (ccp (distanceCenterNewX,distanceCenterNewY));
                        
                        if (closeBlockRotation > newBlockRotation) {
                            
                            float direction = - ((nextAngle) * 2 * pi)/360 - 0;
                            CGPoint lateralRectifier = ccpForAngle(direction);
                            NSLog(@"esta a la derecha, se mueve angulo %f", direction);
                            float rectificanteEnXbis = [[rectificanteXarray objectAtIndex: element] intValue]/2 + rectificanteEnX/2;
                            lateralRectifier = ccp (lateralRectifier.x * rectificanteEnXbis, lateralRectifier.y * rectificanteEnXbis);
                            
                            touchingPoint = ccp (([spr position].x + lateralRectifier.x), ([spr position].y + lateralRectifier.y));
                            
                        }
                        else{
                            NSLog(@"esta a la izquierda");
                            
                            float direction = - ((nextAngle) * 2 * pi)/360 - pi;
                            CGPoint lateralRectifier = ccpForAngle(direction);
                            NSLog(@"esta a la derecha, se mueve angulo %f", direction);
                             float rectificanteEnXbis = [[rectificanteXarray objectAtIndex: element] intValue]/2 + rectificanteEnX/2;
                            lateralRectifier = ccp (lateralRectifier.x * rectificanteEnXbis, lateralRectifier.y * rectificanteEnXbis);
                            
                            touchingPoint = ccp (([spr position].x + lateralRectifier.x), ([spr position].y + lateralRectifier.y));
                            
                        }}}}

    
    
    
    // verificar que no haya ninguna otra pieza cerca, si la hay: blockage;
 
        

    
      
    
   
    
    

    
    //integrando el demasiado cerca

    if (demasiadoCercaDeAlguno) {secondblockage = true;}
    
    bool esporposicion;
    esporposicion = false;
    /*if (nextAngle > 90) {
        secondblockage = true; blockage =true;
        esporposicion = true;
    }
    if (nextAngle < -90) {
        secondblockage = true; blockage =true;
        esporposicion = true;
    }*/
    
 
   
    
    if (secondblockage) {
        if (esporposicion)
        {
        [advert setString:[NSString stringWithFormat:@"You can't build outside your land"]];
        [Fader invalidate];
        Fader = nil;
        advert.opacity = 255;
        Fader = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fading) userInfo:nil repeats:NO] retain];
        } else {
            
            if (demasiadoCercaDeAlguno) {
                [advert setString:[NSString stringWithFormat:@"Too close to earth"]];
                [Fader invalidate];
                Fader = nil;
                advert.opacity = 255;
                Fader = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fading) userInfo:nil repeats:NO] retain];
            } else {
            
            
            
            [advert setString:[NSString stringWithFormat:@"Too far from earth"]];
            [Fader invalidate];
            Fader = nil;
            advert.opacity = 255;
            Fader = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fading) userInfo:nil repeats:NO] retain];
            }
        
        }
        
    blockage = true;
    
    } else {
    
        
        if (element == 0) {former = [NSString stringWithFormat:@"block1"];
            if (intAmount1 == 0) { blockage =true;} else {
                intAmount1 = intAmount1 - 1;
                [amount1 setString: [NSString stringWithFormat:@"%i", intAmount1]];}}
        
        
        if (element == 1) {former = [NSString stringWithFormat:@"block2"];
            if (intAmount2 == 0) { blockage =true;} else {
                intAmount2 = intAmount2 - 1;
                [amount2 setString: [NSString stringWithFormat:@"%i", intAmount2]];}}
        
        
        if (element == 2) {former = [NSString stringWithFormat:@"king"];
            
            if (intAmount3 == 0) { blockage =true;} else {
                intAmount3 = intAmount3 - 1;
                [amount3 setString: [NSString stringWithFormat:@"%i", intAmount3]];}}
        
        
        if (element == 3) {former = [NSString stringWithFormat:@"emiter"];
            if (intAmount4 == 0) { blockage =true;} else {
                intAmount4 = intAmount4 - 1;
                [amount4 setString: [NSString stringWithFormat:@"%i", intAmount4]];}}
        
        
        if (element == 4) {former = [NSString stringWithFormat:@"door1"];
            if (intAmount5 == 0) { blockage =true;} else {
                intAmount5 = intAmount5 - 1;
                [amount5 setString: [NSString stringWithFormat:@"%i", intAmount5]];}}
        
        
        if (element == 5) {former = [NSString stringWithFormat:@"machinery"];}
        if (element == 6) {former = [NSString stringWithFormat:@"pass∞∞20through"];}
        if (element == 7) {former = [NSString stringWithFormat:@"bridges"];}
        if (element == 8) {former = [NSString stringWithFormat:@"king"];}
        if (element == 9) {former = [NSString stringWithFormat:@"door1"];}
        if (element == 10) {former = [NSString stringWithFormat:@"block1"];}
        
        
        
    }
    
    if (blockage) {
     /*   [advert setString:[NSString stringWithFormat:@"You don´t have any!"]];
        [Fader invalidate];
        advert.opacity = 255;
        Fader = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fading) userInfo:nil repeats:NO] retain];*/
    

    } else {
    
       
        
        
        LHSprite * apple =
        [lh                 createSpriteWithName:[NSString stringWithFormat:@"%@",former]
                                    fromSheet:@"initierBlue"
                                    fromSHFile:@"initierBlue"];
        
        if (element == 0) {[apple setTag:1];}
        if (element == 1) {[apple setTag:2];}
        if (element == 2) {[apple setTag:3];}
        if (element == 3) {[apple setTag:4];}
        if (element == 4) {[apple setTag:5];}
        [apple transformPosition: touchingPoint];
        float xdist = [apple position].x - [base position].x;
        float ydist = [apple position].y - [base position].y;
        
        
        float RotatePi;
        RotatePi = -ccpToAngle(ccp(xdist, ydist));
        
        float nextAngle = RotatePi + pi;
        nextAngle = nextAngle / (2 * pi);
        nextAngle = 360 * nextAngle - 90;
        [apple transformRotation:nextAngle];
        
        
        
    }}}
    
    if (touchesOnScreen == 1)
    {touchesOnScreen = 0;}

    
}


////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (touchesOnScreen == 1) {
    
        float pi = 3.14159f;
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:[touch view]];
        CGPoint touchingPoint = [[CCDirector sharedDirector] convertToGL:location];
        
        mixusControl = touchingPoint;
        touchingPoint = ccpSub(touchingPoint, ccp(512, 384));
        mixusFX = touchingPoint.x;
        mixusFY = touchingPoint.y;
    
        [self lateralMoved];
    }
         
    
    
}

-(void) lateralMoved {

    if (touchesOnScreen == 1) {
        
        float pi = 3.14159f;

        CGPoint touchingPoint = ccp(mixusFX,mixusFY);
 
        
        
        float root = sqrtf(powf(mixusFX, 2.0f) + powf(mixusFY, 2.0f));
        float angleforth = ccpToAngle(touchingPoint);
        
        angleforth = angleforth + (2 * pi) * (self.rotation / 360);
        
        
        CGPoint newPoint = ccpForAngle(angleforth);
        newPoint.x = 512 + newPoint.x * root;
        newPoint.y = 384 + newPoint.y * root;
        
        
        
        
        ///newpoint termina
        
        float number = + pi / 2 + (2 * pi) * (self.rotation / 360);
        CGPoint rodant = ccpForAngle(number);
        float haut= -[self position].y;
        rodant = ccp(rodant.x *haut ,rodant.y *haut);
        
        touchingPoint = ccpAdd(newPoint, rodant);
        
        mixus = [lh spriteWithUniqueName:@"mixus1"];
        
        
        CGPoint rootex;
        float rotareA;
        float rotareB;
        bool goOn; goOn = false;
        
        if (controlCall) {

            rootex = ccpSub(ccp (910,76), mixusControl);
            float number = (2 * pi) * (self.rotation / 360);
            float fuerza;
            float fuerza2;
            fuerza = sqrtf(powf(rootex.x, 2.0f) + powf(rootex.y, 2.0f));
            
            if (fuerza < 175) {
                goOn = true;
            rotareA = ccpToAngle(ccpSub(mixusControl, ccp (800,-200)));
            rotareB = ccpToAngle(ccpSub( ccp (910,76), ccp (800,-200)));
            
            CGPoint direccion;
            CGPoint direccion2 = ccp(0,0);

            
            
            
            if (mixusControl.y > 90) {
                direccion2 = ccpForAngle(number - (pi/2));
                fuerza2 = fuerza;
            }
            
            
            direccion = ccpForAngle(number);
            
            if (rotareA < rotareB) {fuerza = -fuerza;
                
                if (fuerza < 40) {
                    if (fuerza > -60) {
                        fuerza = 0; fuerza2 = 2 * fuerza2;}}
                
                
            }
            
            CGPoint preRootex1 = ccp (-direccion.x * fuerza * 0.75f,- direccion.y * fuerza * 0.75f);
            CGPoint preRootex2 = ccp (-direccion2.x * fuerza2,- direccion2.y * fuerza2);
            rootex = ccp (preRootex1.x + preRootex2.x, preRootex1.y + preRootex2.y);
            
            }} else {
                
            goOn = true;
            rootex = ccpSub(touchingPoint, [mixus position]);
            rotareA = ccpToAngle(touchingPoint);
            rotareB = ccpToAngle([mixus position]);
            
        }
        
        if (goOn ) {
        
        if (rotareA < rotareB) {mixus.scaleX = .4;} else {mixus.scaleX = -.4;}
        
        b2Vec2 impulse (rootex.x, rootex.y);
        b2Vec2 previous = [mixus body] -> GetLinearVelocity();
        previous = b2Vec2 ((previous.x)/2,(previous.y)/2);
        float forcepre = sqrtf(powf(previous.x, 2.0f) + powf(previous.y, 2.0f));
        if (forcepre < 19) {
            
            float impulseRatio;
            if (controlCall) {impulseRatio = .08f;
                NSLog(@"Control Call!");
            } else {impulseRatio = 0.04f;}
            
            [mixus body] -> SetLinearVelocity(impulseRatio * impulse + previous);
            
            
            
        }}
    }

}


- (void)jumpMixus
{    NSLog(@"jump llega");
    
    float pi = 3.14159f;
    float direccion = ((self.rotation)/360) *2 * pi + pi/2;
    CGPoint jump = ccpForAngle(direccion);
    NSLog(@"jump %f float", direccion);
    b2Vec2 impulseJump (jump.x, jump.y);
    b2Vec2 previousJump = [mixus body] -> GetLinearVelocity();
    float forcepre = sqrtf(powf(previousJump.x, 2.0f) + powf(previousJump.y, 2.0f));

        if (forcepre < 10) {
            [mixus body] -> SetLinearVelocity(18 * impulseJump + previousJump);} else {
                
                [mixus body] -> SetLinearVelocity(5 * impulseJump + previousJump);
            }
    }


////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
    
        float pi = 3.14159f;
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:[touch view]];
        CGPoint touchingPoint = [[CCDirector sharedDirector] convertToGL:location];
        CGPoint oldPoint = touchingPoint;
        

        
        
        CGPoint  controlPoint = ccpSub(touchingPoint, ccp(950, 0));
         float controlRoot = sqrtf(powf(controlPoint.x, 2.0f) + powf(controlPoint.y, 2.0f));
        
        if (touchesOnScreen == 0) {
            if (controlRoot < 150) {
                
                controlCall = true;
                
                mixusControl = oldPoint;
                touchingPoint = ccpSub(touchingPoint, ccp(512, 384));
                mixusFX = oldPoint.x;
                mixusFY = oldPoint.y;
                [self lateralMoved];
                
                touchesOnScreen = 1;
            }}
        
        touchingPoint = ccpSub(touchingPoint, ccp(512, 384));
        float distex = touchingPoint.x;
        float distey = touchingPoint.y;
        
        
        float root = sqrtf(powf(distex, 2.0f) + powf(distey, 2.0f));
        float angleforth = ccpToAngle(touchingPoint);
        
        angleforth = angleforth + (2 * pi) * (self.rotation / 360);
        
        
        CGPoint newPoint = ccpForAngle(angleforth);
        newPoint.x = 512 + newPoint.x * root;
        newPoint.y = 384 + newPoint.y * root;
        
        
        
        
        ///newpoint termina
        
        float number = + pi / 2 + (2 * pi) * (self.rotation / 360);
        CGPoint rodant = ccpForAngle(number);
        float haut= -[self position].y;
        rodant = ccp(rodant.x *haut ,rodant.y *haut);
        
        touchingPoint = ccpAdd(newPoint, rodant);
       
        mixus = [lh spriteWithUniqueName:@"mixus1"];
        
        
        CGPoint rootex = ccpSub(touchingPoint, [mixus position]);
        
        
        float rootex2 = sqrtf(powf(rootex.x, 2.0f) + powf(rootex.y, 2.0f));
        

        

        if (touchesOnScreen == 0) {
            if (rootex2 < 100) {
                NSLog(@"toque sobre personaje");
                  controlCall = false;
                touchesOnScreen = 1;
            }}
        


    
    }
    
    
////////////////////////////////////////////////////////////////////////////////
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    if(nil != lh)
        [lh release];

	delete world;
	world = NULL;
	
  	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
////////////////////////////////////////////////////////////////////////////////