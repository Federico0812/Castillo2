//
//  GameScene.mm
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	info@gamextar.com
//	http://www.gamextar.com - iPhone Development 
//
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "BuildScene.h"


@class BuildScene;

@interface GameHUD : CCLayer
{
  BuildScene* game;
  CGSize size;

}


+ (GameHUD *)sharedManager;
- (void) setGame: (BuildScene*)game;

- (void) showHUD;


@end
