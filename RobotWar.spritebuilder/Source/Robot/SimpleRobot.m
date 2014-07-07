//
//  SimpleRobot.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SimpleRobot.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching,
    RobotStateRunningAway
    
    #define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))
};

@implementation SimpleRobot {
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    BOOL firstMovement;
    CGPoint positionOne;
    CGPoint positionNext;
    CGFloat movementTime;
}


- (void)run {
    
    while (true) {
        // if robot is shooting, do all this stuff
        if (_currentRobotState == RobotStateFiring) {
            // if 1 second has elapsed

            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                // start searching
                _currentRobotState = RobotStateSearching;
            } else {
                [self shoot];
                NSLog (@"position 1 :%f",positionOne.x);
                NSLog (@"position 1 :%f",positionOne.y);
                
                _lastKnownPosition.x = (positionOne.x)*2  - positionNext.x;
                _lastKnownPosition.y = (positionOne.y)*2 - positionNext.y;
                NSLog (@"last known :%f",_lastKnownPosition.x);
                NSLog (@"last knonw :%f",_lastKnownPosition.y);
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else {
                    [self turnGunLeft:abs(angle)];
                }
                [self shoot];
            }
        }
        
        if (_currentRobotState == RobotStateSearching) {
//            if (firstMovement) {
                [self moveAhead:50];
                //[self turnRobotLeft: RAND_FROM_TO(15, 30)];
                [self moveAhead:50];
                //[self turnRobotRight:RAND_FROM_TO(15, 30)];
                //firstMovement = false;
                _currentRobotState = RobotStateDefault;
//            }
        }
        
        if (_currentRobotState == RobotStateDefault) {

            if  (firstMovement == TRUE) {
                int decideLR = RAND_FROM_TO(1, 2);
                if (decideLR == 1) {
                [self turnRobotLeft: RAND_FROM_TO(15, 30)];
                } else {
                [self turnRobotRight:RAND_FROM_TO(15, 30)];
                }
                firstMovement = FALSE;
            }
            
            [self moveAhead:RAND_FROM_TO(15, 30)];
        }
        if (_currentRobotState == RobotStateRunningAway){
            
            [self turnRobotLeft: RAND_FROM_TO(15, 30)];
            [self moveAhead:RAND_FROM_TO(15, 30)];
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
}


// method is called when other robot is scannned
- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    // if my robot is not shooting then stop all other tasks
    positionOne = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    
    if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 0.1f) {
        positionNext = position;
    }
    
    if (_currentRobotState != RobotStateFiring) {
        [self cancelActiveAction];
    }
    
    // change last known pos variable to the new detected position
    _lastKnownPosition = position;
    // idk (reset timer)
    _lastKnownPositionTimestamp = self.currentTimestamp;
    // start shooting
    _currentRobotState = RobotStateFiring;
}

// method is called when robot hits a wall
// paramaters are direction of wall and angle of collision
- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    // if my robot is not turning around, stop doing tasks
    if (_currentRobotState != RobotStateTurnaround) {
        [self cancelActiveAction];
        
        // save what my robot was just doing (before i stoped it)
        RobotState previousState = _currentRobotState;
        // set new state to turn around
        _currentRobotState = RobotStateTurnaround;
        
        
        if (angle >= 0) {
            // if angle is greater than 0 then turn left
            [self turnRobotLeft: RAND_FROM_TO(100, 180)];
        } else {
            // if angle is less than 0 then turn right
            [self turnRobotRight: RAND_FROM_TO(100, 180)];
        }
        
        [self moveAhead:40];
        
        _currentRobotState = previousState;
    }
}

//- (void)_gotHit
//{
//    if (_currentRobotState != RobotStateRunningAway) {
//        [self cancelActiveAction];
//    }
//    _currentRobotState = RobotStateDefault;
//}
//
//
//- (void)_bulletHitEnemy:(Bullet*)bullet {
//    
//    if (_currentRobotState != RobotStateFiring) {
//        [self cancelActiveAction];
//    }
//    //RobotState previousState = _currentRobotState;
//    _currentRobotState = RobotStateFiring;
//    _currentRobotState = RobotStateSearching;
//}

@end
