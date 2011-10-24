//
//  MapPin.m
//  StuffNearMe
//
//  Created by Mason Silber on 7/18/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin
@synthesize title, subtitle,place;

-(id)initWithName:(NSString *)name andLocation:(CLLocationCoordinate2D)location
{
    title = name;
    coordinate = location;
    return self;
}

-(id)initWithPlace:(Place *)aPlace
{
    place = aPlace;
    title = [place name];
    coordinate = [[place location] coordinate];
    subtitle = [place address];
    return self;
}


-(CLLocationCoordinate2D)coordinate
{
    return coordinate;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

@end
