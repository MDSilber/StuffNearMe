//
//  Place.m
//  StuffNearMe
//
//  Created by Mason Silber on 7/18/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "Place.h"

@implementation Place

@synthesize name,address,latitude,longitude,distanceFromStartingPoint,location,startLocation,iconURL,reference,type,dateCreated;

-(id)initWithName:(NSString *)aName andAddress:(NSString *)anAddress andLatitude:(float)aLatitude andLongitude:(float)aLongitude andStartingCoordinate:(CLLocation *)start andImage:(NSURL *)image
{
    self = [super init];
    if (self) {
        name = aName;
        address = anAddress;
        latitude = aLatitude;
        longitude = aLongitude;
        location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        startLocation = start;
        distanceFromStartingPoint = [location distanceFromLocation:start];
        iconURL = image;
        dateCreated = [NSDate date];
    }

    return self;
}

-(float)distanceFromStartingPoint:(CLLocation *)startingPoint
{
    return [location distanceFromLocation:startingPoint];
}

-(void)print
{
    NSLog(@"Name: %@",[self name]);
    NSLog(@"Address %@",[self address]);
    NSLog(@"Location: %f,%f",[self latitude],[self longitude]);
    NSLog(@"Distance from starting point: %f",[self distanceFromStartingPoint]);
    NSLog(@"Type: %@",type);
}

-(void)dealloc
{
    [location release];
    //NSLog(@"%@ dealloc called",[self class]);

    [super dealloc];
}

-(void)setStartLocation:(CLLocation *)aStartLocation
{
    startLocation = aStartLocation;
    distanceFromStartingPoint = [location distanceFromLocation:startLocation];
}

@end
