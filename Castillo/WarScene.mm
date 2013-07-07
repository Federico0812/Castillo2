//
//  WarScene.mm
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//
// Import the interfaces
#import "WarScene.h"
#import "BuildScene.h"
#define PTM_RATIO 32

#define kRADIAL_GRAVITY_FORCE 250.0f

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;  
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

// War implementation
@implementation WarScene

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
	WarScene *layer = [WarScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
////////////////////////////////////////////////////////////////////////////////
// initialize your instance here
-(id) init
{
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
        
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, 0.0f);
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity);
		
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw();
		world->SetDebugDraw(m_debugDraw);
		/*
		uint32 flags = 0;
		flags += b2Draw::e_shapeBit;
		flags += b2Draw::e_jointBit;
		m_debugDraw->SetFlags(flags);	*/	
				
		[self schedule: @selector(tick:) interval:1.0f/60.0f];
		
        //TUTORIAL - loading one of the levels - test each level to see how it works
        lh = [[LevelHelperLoader alloc] initWithContentOfFile:@"W1.1"];
	        
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
        
        redder = false;
        // Create our static "Planet"
        b2CircleShape shape;
        shape.m_radius = 26.0f;
        shape.m_p.Set(15.0f, 12.2f);
        b2FixtureDef fd;
        fd.shape = &shape;
        planet = groundBody->CreateFixture(&fd);
         redder = false;
        pickedone = false;
        
        options = [CCMenu menuWithItems:nil];
        //setting amounts!!!!
        intAmount1 = 25;
        intAmount2 = 10;
        intAmount3 = 1;
        intAmount4 = 1;
        intAmount5 = 2;
        
        
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
        [advert setString: [NSString stringWithFormat:@"Conquest the world by destroying the opposite empire"]];
        CCMenuItemLabel *labelAdvert = [CCMenuItemLabel itemWithLabel:advert];
        
        [options addChild:labelItem1 z:1];
        [options addChild:labelItem2 z:1];
        [options addChild:labelItem3 z:1];
        [options addChild:labelItem4 z:1];
        [options addChild:labelItem5 z:1];
        [options addChild:labelAdvert z:1];
        
      base = [lh spriteWithUniqueName:@"planet"];
        destroying = false;
        forcedThree = true;
        forcedFour = true;
        stopAccel = false;
        float teppe = 0;
        options.position = ccp(0,teppe);
        NSLog([NSString stringWithFormat:@"posx %f, posy %f",[self position].x, [self position].y]);
         option1 = [CCMenuItemImage itemFromNormalImage:@"warbutShooter.png" selectedImage:@"warbutShooter.png" target:self selector:@selector(onSelection:)];
         option2 = [CCMenuItemImage itemFromNormalImage:@"warbutShooter.png" selectedImage:@"warbutShooter.png" target:self selector:@selector(onSelection:)];
         option3 = [CCMenuItemImage itemFromNormalImage:@"warbutShooter.png" selectedImage:@"warbutShooter.png" target:self selector:@selector(onSelection:)];
         option4 = [CCMenuItemImage itemFromNormalImage:@"warbutShooter.png" selectedImage:@"warbutShooter.png" target:self selector:@selector(onSelection:)];
         option5 = [CCMenuItemImage itemFromNormalImage:@"warbutShooter.png" selectedImage:@"warbutShooter.png" target:self selector:@selector(onSelection:)];
         option6 = [CCMenuItemImage itemFromNormalImage:@"blueSmallShooter.png" selectedImage:@"blueSmallShooter.png" target:self selector:@selector(onSelection:)];
         option7 = [CCMenuItemImage itemFromNormalImage:@"blueSmallShooter.png" selectedImage:@"blueSmallShooter.png" target:self selector:@selector(onSelection:)];
         option8 = [CCMenuItemImage itemFromNormalImage:@"blueSmallShooter.png" selectedImage:@"blueSmallShooter.png" target:self selector:@selector(onSelection:)];
         option9 = [CCMenuItemImage itemFromNormalImage:@"blueSmallShooter.png" selectedImage:@"blueSmallShooter.png" target:self selector:@selector(onSelection:)];
         option10 = [CCMenuItemImage itemFromNormalImage:@"blueSmallShooter.png" selectedImage:@"blueSmallShooter.png" target:self selector:@selector(onSelection:)];
         option11 = [CCMenuItemImage itemFromNormalImage:@"warmode.png" selectedImage:@"warmode.png" target:self selector:@selector(onSelection:)];
         option12 = [CCMenuItemImage itemFromNormalImage:@"virare.png" selectedImage:@"virare.png" target:self selector:@selector(onSelection:)];
        option1.position = ccp(80,1700);  option1.tag = 0;
        option2.position = ccp(80,1550);option2.tag = 1;
        option3.position = ccp(80,1400);option3.tag = 2;
        option4.position = ccp(80,1250);option4.tag = 3;
        option5.position = ccp(80,1100);option5.tag = 4;
        option6.position = ccp(240,1730);option6.tag = 5;
        option7.position = ccp(310,1730);option7.tag = 6;
        option8.position = ccp(380,1730);option8.tag = 7;
        option9.position = ccp(450,1730);option9.tag = 8;
        option10.position = ccp(520,1730); option10.tag = 9;
        option11.position = ccp(810,1713);option11.tag = 10;
        option12.position = ccp(240,1655);option12.tag = 11;
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
        

        
        Fader = [[NSTimer scheduledTimerWithTimeInterval:3.1f target:self selector:@selector(fading) userInfo:nil repeats:NO] retain];
        Pulsor = [[NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(pulsate) userInfo:nil repeats:YES] retain];
        Faller = [[NSTimer scheduledTimerWithTimeInterval:0.83f target:self selector:@selector(faller) userInfo:nil repeats:YES] retain];
       enemyImpulse = [[NSTimer scheduledTimerWithTimeInterval:1.55f target:self selector:@selector(enemyImpulse) userInfo:nil repeats:YES] retain];
        frocs = true;
        setup = true;
       
	}
	return self;
}


- (void) enemyImpulse {

    int rander;
    
        NSArray* spritesR = [lh spritesWithTag:SHOOTERRED]; { 
            for (LHSprite* spr in spritesR) {
                
                    rander = arc4random()%13;
                if (rander > 4) {

                    CGPoint locatio = [spr position];
                    NSLog([NSString stringWithFormat:@"locatio (%f,%f)",locatio.x,locatio.y]);
                    
                    float xdist = locatio.x - [base position].x;
                    float ydist = locatio.y - [base position].y;
                    
                    float pi = 3.1415926535897;
                    float RotatePi;
                    RotatePi = -ccpToAngle(ccp(xdist, ydist));
                    
                    float nextAngle = RotatePi + pi;
                    nextAngle = nextAngle / (2 * pi);
                    nextAngle = 360 * nextAngle - 90;
                    
                    NSLog([NSString stringWithFormat:@"ANGULO %f",nextAngle]);            
                    float postangle;
                    
                    bool virato = [spr body] -> IsBullet();
                    if (virato) {    postangle = -nextAngle - 0;}
                    else        {     postangle = -nextAngle + 180;}
                    CGPoint positio = ccpForAngle(2 * pi * (postangle/360));
                    positio = ccp (100 * positio.x, 100 * positio.y);
                    
                    locatio = ccpAdd(locatio, positio);    
                    LHSprite*troop = [lh newPhysicalBatchSpriteWithUniqueName:[NSString stringWithFormat:@"redRobotRoll"]];
                    troop.scale = .4f;
                    [troop startAnimationNamed:@"redRobotRoll"];
                    [troop transformPosition:locatio];        
                    [troop transformRotation:nextAngle];
                    if (virato) {[troop body] -> SetGravityScale(1.0f);}
                    else {[troop body] -> SetGravityScale(-1.0f);}
                    [troop setTag:7];
                    
                }}}}



- (void) guicontroller {
    
    
    
    option6.visible = false;
    option7.visible = false;
    option8.visible = false;
    option9.visible = false;
    option10.visible = false;
    

    NSArray* spritesJ = [lh spritesWithTag:SHOOTER]; { 
        for (LHSprite* spr in spritesJ) {countforshooter++;}}

    if (countforshooter<5) {option5.visible = false;}
    if (countforshooter<4) {option4.visible = false;}
    if (countforshooter<3) {option3.visible = false;}
    if (countforshooter<2) {option2.visible = false;}
    if (countforshooter<1) {option1.visible = false;}
    
    amount1.visible = false;
    amount2.visible = false;
    amount3.visible = false;
    amount4.visible = false;
    amount5.visible = false;
    
    NSArray* spritesR = [lh spritesWithTag:SHOOTERRED]; { 
        for (LHSprite* spr in spritesR) {
            countforredshooter++;
        }}
        NSLog([NSString stringWithFormat:@"count shooter %i and red %i ",countforshooter,countforredshooter]);
}

-(void) faller {
    if (setup) {[self setupCollisionHandling]; setup = false;}
    
    NSArray* Grenade = [lh spritesWithTag:GRANADE]; { 
        for (LHSprite* drop in Grenade) {
            float num;
            num = [drop body] -> GetGravityScale();
            if (num == 15.5f)
            {[lh markSpriteForRemoval:drop];
           
            }}}}


-(void) pulsate {
        
    
    NSArray* Roboti = [lh spritesWithTag:ROBOTBLUE]; { 
        for (LHSprite* Robot in Roboti) {   

            CGPoint locatione = [Robot position];
            float xdist = locatione.x - [base position].x;
            float ydist = locatione.y - [base position].y;
            
            float pi = 3.1415926535897;
            float RotatePi;
            RotatePi = -ccpToAngle(ccp(xdist, ydist));
            
            float nextAngle = RotatePi + pi;
            nextAngle = nextAngle / (2 * pi);
            nextAngle = 360 * nextAngle - 90;
            
            bool continua; continua = true;
            float eliminator = nextAngle - Robot.rotation;
            float virante = [Robot body] -> GetGravityScale();            
            
            if (virante == 10.0f) {
                [lh markSpriteForRemoval:Robot];
                continua = false;
            }
            if (eliminator < 405) {if (eliminator > 315) {eliminator = eliminator - 360;}}
            if (eliminator > -405) {if (eliminator < -315) {eliminator = eliminator + 360;}}
                

                if (eliminator > 45.0f) {
                                NSLog([NSString stringWithFormat:@"eliminator %f",eliminator]);
                [Robot startAnimationNamed:@"robotDie"];
                [Robot body] -> SetGravityScale(10.0f);
                continua = false;
            }
            if (eliminator < -45.0f) {
                            NSLog([NSString stringWithFormat:@"eliminator %f", eliminator]);
                [Robot startAnimationNamed:@"robotDie"];
                [Robot body] -> SetGravityScale(10.0f);
                continua = false;
            }    
            
            
                if (continua) {
            float postangle;
            
             if (virante == 1.0f) {    postangle = -nextAngle + 180;}
             if (virante == -1.0f)        {     postangle = -nextAngle - 0;}
                    if (virante == 0.0f) {} else {
            CGPoint velotio = ccpForAngle(2 * pi * (postangle/360));
             b2Vec2 velotie (8 * velotio.x, 8 * velotio.y);
            [Robot body] -> SetLinearVelocity(velotie);
            
                    }
                }}}
    
    
    NSArray* RobotiRed = [lh spritesWithTag:ROBOTRED]; { 
        for (LHSprite* Robot in RobotiRed) {   
            
            CGPoint locatione = [Robot position];
            float xdist = locatione.x - [base position].x;
            float ydist = locatione.y - [base position].y;
            
            float pi = 3.1415926535897;
            float RotatePi;
            RotatePi = -ccpToAngle(ccp(xdist, ydist));
            
            float nextAngle = RotatePi + pi;
            nextAngle = nextAngle / (2 * pi);
            nextAngle = 360 * nextAngle - 90;
            
            bool continua; continua = true;
            float eliminator = nextAngle - Robot.rotation;
            float virante = [Robot body] -> GetGravityScale();            
            
            if (virante == 10.0f) {
                [lh markSpriteForRemoval:Robot];
                continua = false;
            }
            if (eliminator < 405) {if (eliminator > 315) {eliminator = eliminator - 360;}}
            if (eliminator > -405) {if (eliminator < -315) {eliminator = eliminator + 360;}}
            
            
            if (eliminator > 45.0f) {
                NSLog([NSString stringWithFormat:@"eliminator %f",eliminator]);
                [Robot startAnimationNamed:@"robotDie"];
                [Robot body] -> SetGravityScale(10.0f);
                continua = false;
            }
            if (eliminator < -45.0f) {
                NSLog([NSString stringWithFormat:@"eliminator %f", eliminator]);
                [Robot startAnimationNamed:@"robotDie"];
                [Robot body] -> SetGravityScale(10.0f);
                continua = false;
            }    
            
            
            if (continua) {
                float postangle;
                
                if (virante == -1.0f) {    postangle = -nextAngle + 180;}
                if (virante == 1.0f)        {     postangle = -nextAngle - 0;}
                if (virante == 0.0f) {} else {
                    CGPoint velotio = ccpForAngle(2 * pi * (postangle/360));
                    b2Vec2 velotie (8 * velotio.x, 8 * velotio.y);
                    [Robot body] -> SetLinearVelocity(velotie);
                    
                }
            }}}

}


-(void) fading {
    if (advert.opacity != 0) {
    CCAction *fadeOut = [CCFadeOut actionWithDuration:0.5];
        [advert runAction:fadeOut];
        [Fader invalidate];
        
    }}



-(void)onSelection:(CCMenuItemImage *) sender {
    NSLog(@"selecciona");

    if (sender.tag >= 0 ) {if (sender.tag <= 4 ) {
        
        
        NSArray* spritesR = [lh spritesWithTag:SHOOTER]; { 
            for (LHSprite* spr in spritesR) {
                NSString * flet =  [NSString stringWithFormat:@"emiterFire%i",sender.tag + 1];
                
                if ([spr.uniqueName isEqualToString:flet]){
        CGPoint locatio = [spr position];
         NSLog([NSString stringWithFormat:@"locatio (%f,%f)",locatio.x,locatio.y]);
                    
                    float xdist = locatio.x - [base position].x;
                    float ydist = locatio.y - [base position].y;
                    
                    float pi = 3.1415926535897;
                    float RotatePi;
                    RotatePi = -ccpToAngle(ccp(xdist, ydist));
                    
                    float nextAngle = RotatePi + pi;
                    nextAngle = nextAngle / (2 * pi);
                    nextAngle = 360 * nextAngle - 90;
                    
                    NSLog([NSString stringWithFormat:@"ANGULO %f",nextAngle]);            
                    float postangle;
                    
                    bool virato = [spr body] -> IsBullet();
                    if (virato) {    postangle = -nextAngle + 180;}
                    else        {     postangle = -nextAngle - 0;}
                    CGPoint positio = ccpForAngle(2 * pi * (postangle/360));
                    positio = ccp (100 * positio.x, 100 * positio.y);
                    
        locatio = ccpAdd(locatio, positio);    
LHSprite*troop = [lh newPhysicalBatchSpriteWithUniqueName:[NSString stringWithFormat:@"blueRobotRoll"]];
                    troop.scale = .4f;
                    [troop startAnimationNamed:@"blueRobotRoll"];
                    [troop transformPosition:locatio];        
                    [troop transformRotation:nextAngle];
                    if (virato) {[troop body] -> SetGravityScale(1.0f);}
                    else {[troop body] -> SetGravityScale(-1.0f);}
                    [troop setTag:6];
                    
                }}}}}

    if (sender.tag == 5) {
        destroying = true;
    }
    if (sender.tag == 6) {element = 6;}
    if (sender.tag == 7) {element = 7;}
    if (sender.tag == 8) {element = 8;}
    if (sender.tag == 9) {element = 9;}
    if (sender.tag == 10) {
    
[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.2 scene:[BuildScene scene] withColor:ccWHITE]];
        
    }
    if (sender.tag == 11) {
      
             NSArray* spritesR = [lh spritesWithTag:SHOOTER]; { 
                    for (LHSprite* spr in spritesR) {
                
                        bool wayover;
                        wayover = [spr body] -> IsBullet();
                        
                        if (wayover) {
                        
                        spr.scaleX = 0.4f;
                        [spr body] -> SetBullet(NO);
                        } else {
                        spr.scaleX = -0.4f;
                        [spr body] -> SetBullet(YES);
                        }}}}   
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
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
     
    if (world -> IsLocked()==false) {[lh removeMarkedSprites];}
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		b2Body* ground = planet->GetBody();
        b2CircleShape* circle = (b2CircleShape*)planet->GetShape();
        // Get position of our "Planet" - Nick
        b2Vec2 center = ground->GetWorldPoint(circle->m_p);
        // Get position of our current body in the iteration - Nick
        b2Vec2 position = b->GetPosition();
        // Get the distance between the two objects. - Nick
        b2Vec2 d = center - position;
        // The further away the objects are, the weaker the gravitational force is - Nick
        float force = 2.0 * d.LengthSquared(); // 150 can be changed to adjust the amount of force - Nick
        d.Normalize();

        
        b2Vec2 F = force * d;
        // Finally apply a force on the body in the direction of the "Planet" - Nick
        b->ApplyForce(F, position);
		
        if (frocs) {
        [self chargelevel];
            frocs = false;
             [self guicontroller];
        }
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}
//FIX TIME STEPT<<<<<<<<<<<<<<<----------------------
////////////////////////////////////////////////////////////////////////////////
- (void) chargelevel {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *BoxNowUsed = [currentDefaults objectForKey:[NSString stringWithFormat:@"DirectCastle"]];
    
    if (BoxNowUsed != nil)
    {NSMutableArray *elementor = [NSKeyedUnarchiver unarchiveObjectWithData:BoxNowUsed];
        int counter = [elementor count];
        counter = counter / 5;
        NSLog([NSString stringWithFormat:@"cuenta da %i",counter]);
        int emiterfire;
    
    for(int i = 0; i < counter; i++) {
        

        int meta = 5 * i;
        int sprtag =  [[elementor objectAtIndex:meta + 0] intValue];
        int evolution =  [[elementor objectAtIndex:meta + 1] intValue];
        float positionx = [[elementor objectAtIndex:meta + 2] floatValue];
        float positiony = [[elementor objectAtIndex:meta + 3] floatValue];
        float rotationer = [[elementor objectAtIndex:meta + 4] floatValue];
        
        
                NSLog([NSString stringWithFormat:@"sprite numero %i, tag %i, evolution %i, pos (%f,%f) rot %f",i,sprtag,evolution,positionx,positiony,rotationer]);
        
        
        bool changename;changename = false;
        LHSprite *apple;
        NSString *former;
        NSString *name;
        
        
        if (sprtag == 1) {former = [NSString stringWithFormat:@"block1"];}
        if (sprtag == 2) {former = [NSString stringWithFormat:@"block2"];
        }
        if (sprtag == 3) {former = [NSString stringWithFormat:@"king"];
            name = [NSString stringWithFormat:@"kingNox"]; changename = true;
        }
        if (sprtag == 4) {former = [NSString stringWithFormat:@"emiter"];
            emiterfire ++; changename = true;
            name = [NSString stringWithFormat:@"emiterFire%i",emiterfire];
        
        }
        if (sprtag == 5) {former = [NSString stringWithFormat:@"door1"];}
        
        
       apple = [lh newPhysicalBatchSpriteWithUniqueName:[NSString stringWithFormat:@"%@",former]];
        if (changename) {apple.uniqueName = name; }
         NSLog([NSString stringWithFormat:@"sop se llama: %@",apple.uniqueName]);
        apple.tag = sprtag;
        CGPoint space = ccp(positionx, positiony);
        [apple transformPosition:space];
        [apple transformRotation: rotationer];
// NSLog([NSString stringWithFormat:@"apple del apple pos (%f,%f) rot %f",[apple position].x, [apple position].y, apple.rotation]);
        apple.opacity = 225;
    }

        
    }}


- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
    
    if (stopAccel) {NSLog(@"se frena accelerometro");} else {
      
        
	// static float prevX=0, prevY=0;
	
	//#define kFilterFactor 1.0f
	
    float pi = 3.14159265589793f;
    
	// float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	// float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
    
	float accelX = (float) acceleration.x + .25f * acceleration.z;
	float accelY = (float) acceleration.y;
    
    double currentRawReading = atan2(accelY, accelX);
    currentRawReading = currentRawReading * 180/pi;
    
    
 
    //self.position = ccpAdd(self.position,  ccp(10 * -accelY,0));
    
    self.rotation = self.rotation - 5 * accelY;
     self.position = ccpAdd(self.position,  ccp(0,20 * accelX));
    options.rotation = options.rotation + 5 * accelY;
    option1.position = ccpAdd(option1.position,  ccp(0,-20 * accelX));
    option2.position = ccpAdd(option2.position,  ccp(0,-20 * accelX));
    option3.position = ccpAdd(option3.position,  ccp(0,-20 * accelX));
    option4.position = ccpAdd(option4.position,  ccp(0,-20 * accelX));
    option5.position = ccpAdd(option5.position,  ccp(0,-20 * accelX));
    option6.position = ccpAdd(option6.position,  ccp(0,-20 * accelX));
    option7.position = ccpAdd(option7.position,  ccp(0,-20 * accelX));
    option8.position = ccpAdd(option8.position,  ccp(0,-20 * accelX));
    option9.position = ccpAdd(option9.position,  ccp(0,-20 * accelX));
    option10.position = ccpAdd(option10.position,  ccp(0,-20 * accelX));
    option11.position = ccpAdd(option11.position,  ccp(0,-20 * accelX));
    option12.position = ccpAdd(option12.position,  ccp(0,-20 * accelX));
    amount1.position = ccpAdd(amount1.position,  ccp(0,-20 * accelX));
    amount2.position = ccpAdd(amount2.position,  ccp(0,-20 * accelX));
    amount3.position = ccpAdd(amount3.position,  ccp(0,-20 * accelX));
    amount4.position = ccpAdd(amount4.position,  ccp(0,-20 * accelX));
    amount5.position = ccpAdd(amount5.position,  ccp(0,-20 * accelX));
    advert.position = ccpAdd(advert.position,  ccp(0,-20 * accelX));
    //down
    if ([option1 position].y < 1700) {option1.position = ccp([option1 position].x, 1700);}
    if ([ option2 position].y < 1550) { option2.position = ccp([ option2 position].x, 1550);}
    if ([ option3 position].y < 1400) { option3.position = ccp([ option3 position].x, 1400);}
    if ([ option4 position].y < 1250) { option4.position = ccp([ option4 position].x, 1250);}
    if ([ option5 position].y < 1100) { option5.position = ccp([ option5 position].x, 1100);}
    if ([ option6 position].y < 1730) { option6.position = ccp([ option6 position].x, 1730);}
    if ([ option7 position].y < 1730) { option7.position = ccp([ option7 position].x, 1730);}
    if ([ option8 position].y < 1730) { option8.position = ccp([ option8 position].x, 1730);}
    if ([ option9 position].y < 1730) { option9.position = ccp([ option9 position].x, 1730);}
    if ([ option10 position].y < 1730) { option10.position = ccp([ option10 position].x, 1730);}
    if ([ option11 position].y < 1713) { option11.position = ccp([ option11 position].x, 1713);}
    if ([ option12 position].y < 1655) { option12.position = ccp([ option12 position].x, 1655);}
    if ([ amount1 position].y < 1700) { amount1.position = ccp([ amount1 position].x, 1700);}
    if ([ amount2 position].y < 1550) { amount2.position = ccp([ amount2 position].x, 1550);}
    if ([ amount3 position].y < 1400) { amount3.position = ccp([ amount3 position].x, 1400);}
    if ([ amount4 position].y < 1250) { amount4.position = ccp([ amount4 position].x, 1250);}
    if ([ amount5 position].y < 1100) { amount5.position = ccp([ amount5 position].x, 1100);}
    if ([ advert position].y < 1378) { advert.position = ccp([advert position].x, 1378);}
    
    ///upper
    if ([option1 position].y > 2700) {option1.position = ccp([option1 position].x, 2700);}
    if ([ option2 position].y > 2550) { option2.position = ccp([ option2 position].x, 2550);}
    if ([ option3 position].y > 2400) { option3.position = ccp([ option3 position].x, 2400);}
    if ([ option4 position].y > 2250) { option4.position = ccp([ option4 position].x, 2250);}
    if ([ option5 position].y > 2100) { option5.position = ccp([ option5 position].x, 2100);}
    if ([ option6 position].y > 2730) { option6.position = ccp([ option6 position].x, 2730);}
    if ([ option7 position].y > 2730) { option7.position = ccp([ option7 position].x, 2730);}
    if ([ option8 position].y > 2730) { option8.position = ccp([ option8 position].x, 2730);}
    if ([ option9 position].y > 2730) { option9.position = ccp([ option9 position].x, 2730);}
    if ([ option10 position].y > 2730) { option10.position = ccp([ option10 position].x, 2730);}
    if ([ option11 position].y > 2713) { option11.position = ccp([ option11 position].x, 2713);}
    if ([ option12 position].y > 2655) { option12.position = ccp([ option12 position].x, 2655);}
    if ([ amount1 position].y > 2730) { amount1.position = ccp([ amount1 position].x, 2730);}
    if ([ amount2 position].y > 2550) { amount2.position = ccp([ amount2 position].x, 2550);}
    if ([ amount3 position].y > 2400) { amount3.position = ccp([ amount3 position].x, 2400);}
    if ([ amount4 position].y > 2250) { amount4.position = ccp([ amount4 position].x, 2250);}
    if ([ amount5 position].y > 2100) { amount5.position = ccp([ amount5 position].x, 2100);}
    if ([ advert position].y > 2378) { advert.position = ccp([ advert position].x, 2378);}
    if ([self position].y >-1000) {self.position = ccp (0,-1000);}
        if ([self position].y <-2000) {self.position = ccp (0,-2000);}
    //NSLog(@"VALOR %f", currentRawReading);
    
    
    //	prevX = accelX;
    //	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
    
	// 0.5
	//
	//
	
	if (!((accelX<0.05 and accelX > -0.05) and (accelY<0.25 and accelY > -0.25))) 
	{
		b2Vec2 gravity( -accelX *-24, accelY *24);
		//world->SetGravity( gravity );
	}
    

        
        
    }}

-(void) setupCollisionHandling {
    
    [lh useLevelHelperCollisionHandling];
    
   [lh registerBeginOrEndCollisionCallbackBetweenTagA:GRANADE andTagB: STRUCTORED idListener:self selListener:
     @selector(grenadeRobot:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:GRANADE andTagB: ROBOTRED idListener:self selListener:
     @selector(grenadeRobot:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:GRANADE andTagB: SHOOTER idListener:self selListener:
     @selector(grenadeRobot:)];
     [lh registerBeginOrEndCollisionCallbackBetweenTagA:GRANADE andTagB: BASE idListener:self selListener:
     @selector(grenadeVoid:)];
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:ROBOTBLUE andTagB: ROBOTRED idListener:self selListener:
     @selector(bothkill:)];
}

-(void)bothkill:(LHContactInfo*)contact{
    NSLog(@"se da contact both");
    LHSprite* roboblu = [contact spriteA];
    [roboblu startAnimationNamed:@"blueRobotKill"];
       
    LHSprite* robored = [contact spriteB];
   bool mate = [robored body] -> IsBullet();
    
    
    if (mate == false) {[robored body] -> SetBullet(YES);[robored startAnimationNamed:@"redRobotKill"];}
    
    
    }


-(void)grenadeRobot:(LHContactInfo*)contact{
    NSLog(@"se da contact robot");
            LHSprite* grenade = [contact spriteA];
    
 
    bool mate = [grenade body] -> IsBullet();
    if (mate == false) {[grenade body] -> SetBullet(YES); 
        [grenade body] -> SetGravityScale(15.5f);
       [grenade startAnimationNamed:@"blueGranadeFall"];
    
            LHSprite* robot = [contact spriteB];
    mate = [robot body] -> IsBullet();

    
        if (mate == false) {[robot body] -> SetBullet(YES);[lh markSpriteForRemoval:robot];}}
}

-(void)grenadeVoid:(LHContactInfo*)contact{
    NSLog(@"se da contact void");
    LHSprite* grenade = [contact spriteA];
   
    float trope =  [grenade body] -> GetGravityScale();
    if (trope == 7.6f) {
        
        
        NSLog(@"se da contact entrada");
        
        
        
        bool mate = [grenade body] -> IsBullet();
        
        if (mate == false) {[grenade body] -> SetBullet(YES); 
            [grenade body] -> SetGravityScale(15.5f); 
            [grenade startAnimationNamed:@"blueGranadeFall"];
        }} else { 
            if (trope != 15.5f) {[grenade body] -> SetGravityScale(7.6f);}}
    
    
    

    }    


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{   

    float pi = 3.14159f;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint touchingPoint = [[CCDirector sharedDirector] convertToGL:location];
    touchingPoint = ccpSub(touchingPoint, ccp(512, 384));
    float distex = touchingPoint.x;
    float distey = touchingPoint.y;
    
    
    float root = sqrtf(powf(distex, 2.0f) + powf(distey, 2.0f));
    NSLog([NSString stringWithFormat:@"distex %f, %f, %f",distex, distey, root]);
    float angleforth = ccpToAngle(touchingPoint);
    
    angleforth = angleforth + (2 * pi) * (self.rotation / 360);
    
    
    CGPoint newPoint = ccpForAngle(angleforth);
    newPoint.x = 512 + newPoint.x * root;
    newPoint.y = 384 + newPoint.y * root;
    
    
    
    NSLog([NSString stringWithFormat:@"ccp es %f, %f, %f",newPoint.x, newPoint.y, root]);
    
    ///newpoint termina
    
    float number = + pi / 2 + (2 * pi) * (self.rotation / 360);
    CGPoint rodant = ccpForAngle(number);
    float haut= -[self position].y;
    rodant = ccp(rodant.x *haut ,rodant.y *haut);
    
    touchingPoint = ccpAdd(newPoint, rodant);
    pickedone = false;
    
    
    NSArray* spritesR = [lh spritesWithTag:ROBOTBLUE]; { 
        for (LHSprite* spr in spritesR) {
            float distancex =  touchingPoint.x - [spr position].x;
            float distancey =  touchingPoint.y - [spr position].y;
            NSLog([NSString stringWithFormat:@"distancia de kill %f,%f",distancex, distancey]);
            bool dojump;
            dojump = true;
            float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
            if (rooter > 50) {dojump = false;}
            if (dojump) {
                [spr body] -> SetGravityScale(0.0f);
                b2Vec2 zero (0,0);
                [spr body] -> SetLinearVelocity(zero);
                if (pickedone == false) {
                    firstPoint = [spr position];
                    catapulted = spr;
                    pickedone = true;
                }}}}
    
    NSArray* spritesD = [lh spritesWithTag:DOOR]; { 
        for (LHSprite* spr in spritesD) {
            float distancex =  touchingPoint.x - [spr position].x;
            float distancey =  touchingPoint.y - [spr position].y;
            NSLog([NSString stringWithFormat:@"distancia de kill %f,%f",distancex, distancey]);
            bool doopen;
            doopen = true;
            float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
            if (rooter > 150) {doopen = false;}
            if (doopen) {
                bool isClosed = [spr body] -> IsActive();
                if (isClosed)
         {[spr body] -> SetActive(NO);
            [spr startAnimationNamed:@"doorOpen"];
         }
                else
         {[spr body] -> SetActive(YES);
            [spr startAnimationNamed:@"doorClose"];
         }
            
            
                    }}}
    
    NSArray* spritesS = [lh spritesWithTag:SHOOTER]; { 
        for (LHSprite* spr in spritesS) {
            float distancex =  touchingPoint.x - [spr position].x;
            float distancey =  touchingPoint.y - [spr position].y;
            NSLog([NSString stringWithFormat:@"distancia de kill %f,%f",distancex, distancey]);
            bool doopen;
            doopen = true;
            float rooter = sqrtf(powf(distancex, 2.0f) + powf(distancey, 2.0f));
            if (rooter > 100) {doopen = false;}
            if (doopen) {
                bool isClosed = [spr body] -> IsBullet();
                if (isClosed)
                {[spr body] -> SetBullet(NO);
                     spr.scaleX = 0.4f;
                }
                else
                {[spr body] -> SetBullet(YES);
                     spr.scaleX = -0.4f;
                }
                
                
            }}}
}


////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
    { float pi = 3.14159f;
        if (pickedone) {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:[touch view]];
        CGPoint secondPoint = [[CCDirector sharedDirector] convertToGL:location];
        secondPoint = ccpSub(secondPoint, ccp(512, 384));
        float distex = secondPoint.x;
        float distey = secondPoint.y;
        
        
        float root = sqrtf(powf(distex, 2.0f) + powf(distey, 2.0f));
        NSLog([NSString stringWithFormat:@"distex %f, %f, %f",distex, distey, root]);
        float angleforth = ccpToAngle(secondPoint);
        
        angleforth = angleforth + (2 * pi) * (self.rotation / 360);
        
        
        CGPoint newPoint = ccpForAngle(angleforth);
        newPoint.x = 512 + newPoint.x * root;
        newPoint.y = 384 + newPoint.y * root;
        
        float number = + pi / 2 + (2 * pi) * (self.rotation / 360);
        CGPoint rodant = ccpForAngle(number);
        float haut= -[self position].y;
        rodant = ccp(rodant.x *haut ,rodant.y *haut);
        
        secondPoint = ccpAdd(newPoint, rodant);
        NSLog([NSString stringWithFormat:@"first (%f,%f) second (%f,%f)",firstPoint.x,firstPoint.y,secondPoint.x,secondPoint.y]);    
    
        CGPoint vectorThrow = ccpSub(secondPoint, firstPoint);
        b2Vec2 fire (.12f * vectorThrow.x,.12f *  vectorThrow.y);
       
            if (catapulted!=nil) {   
                [catapulted startAnimationNamed:@"blueGranadeMaker"];
                [catapulted body] -> SetLinearVelocity(fire); 
                catapulted.opacity = 180;
                [catapulted setTag:8];
                
            }}}
    
    
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