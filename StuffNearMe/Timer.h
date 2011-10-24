//
//  Timer.h
//  TAC
//
//  Created by Mason Silber on 6/16/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Timer : NSObject {
    NSDate *start;
    BOOL running;
    double totalTimeElapsed;
}

@property BOOL running;
@property double totalTimeElapsed;

-(void)startTimer;
-(double)timeElapsedInSeconds;
-(double)timeElapsedInMilliseconds;

@end
