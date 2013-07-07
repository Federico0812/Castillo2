//
//  BuildScene.h
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "LevelHelperLoader.h"
#import "HUDLayer.h"
// Build Layer
@interface BuildScene : CCLayer
{   int element;
    
    float highestDistanceToCenter;
    
    int touchesOnScreen;
    
    bool firstTime;
    
    bool makeStatic;
    LHSprite *static1;
    LHSprite *static2;
    
    LHSprite *mixus;
    
    float mixusFX;
    float mixusFY;
    float mixusDX;
    CGPoint mixusControl;
    
    bool controlCall;
    bool crops;
    bool redder;
    bool destroying;
    bool forcedThree;
    bool forcedFour;
    bool stopAccel;
    NSTimer *Fader;
    NSTimer *Aceler;
    NSTimer *Acepter;
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    b2Fixture* planet; 
    b2PolygonShape* groundBox;	
	LevelHelperLoader* lh;    
    CCMenu *options;
    CCLabelTTF *advert;
     CCLabelTTF *amount1;
     CCLabelTTF *amount2;
     CCLabelTTF *amount3;
     CCLabelTTF *amount4;
     CCLabelTTF *amount5;
    LHSprite *lastvit;
    int intAmount1;
    int intAmount2;
    int intAmount3;
    int intAmount4;
    int intAmount5;
    CCMenuItemImage *option1;
    CCMenuItemImage *option2; 
    CCMenuItemImage *option3; 
    CCMenuItemImage *option4; 
    CCMenuItemImage *option5; 
    CCMenuItemImage *option6; 
    CCMenuItemImage *option7; 
    CCMenuItemImage *option8; 
    CCMenuItemImage *option9; 
    CCMenuItemImage *option10; 
    CCMenuItemImage *option11; 
    CCMenuItemImage *option12; 
}
// returns a Scene that contains the Build as the only child
+(id) scene;


- (void)jumpMixus;

@end
