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
    RobotStateSearching
};

@implementation SimpleRobot {
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
}

- (void)run {
    while (true) {
        if (_currentRobotState == RobotStateFiring) {
            
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateSearching;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:20];
                } else {
                    [self turnGunLeft:20];
                }
                [self shoot];
            }
        }
        
        if (_currentRobotState == RobotStateSearching) {
            [self moveAhead:50];
            [self turnRobotLeft:20];
            [self moveAhead:50];
            [self turnRobotRight:20];
        }
        
        if (_currentRobotState == RobotStateDefault) {
            [self moveAhead:100];
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
}


// method is called when other robot is scannned
- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    // if my robot is not shooting then stop all other tasks
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
        
        
        // always turn to head straight away from the wall
        if (angle >= 0) {
            [self turnRobotLeft:abs(angle)];
        } else {
            [self turnRobotRight:abs(angle)];
            
        }
        
        [self moveAhead:20];
        
        _currentRobotState = previousState;
    }
}

@end
