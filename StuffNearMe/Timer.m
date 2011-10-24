//
//  Timer.m
//  TAC
//
//  Created by Mason Silber on 6/16/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "Timer.h"


@implementation Timer

@synthesize running;
@synthesize totalTimeElapsed;

//Initializes the timer
-(id)init
{
    self = [super init];
    if(self != nil)
    {
        start = nil;
    }
    self.running = NO;
    return self;
}

-(void)startTimer
{
    start = [[NSDate date] retain];
    running = YES;
}

-(double)timeElapsedInSeconds
{
    totalTimeElapsed = [[NSDate date] timeIntervalSinceDate:start];
    return totalTimeElapsed;
}

-(double)timeElapsedInMilliseconds
{
    return 1000.0f*totalTimeElapsed;
}

-(void)dealloc
{
    [start release];
    [super dealloc];
}

@end
