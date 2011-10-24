//
//  MapPin.h
//  StuffNearMe
//
//  Created by Mason Silber on 7/18/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"
#import "Place.h"

@interface MapPin : NSObject <MKAnnotation>
{
    NSString *title;
    NSString *subtitle;
    CLLocationCoordinate2D coordinate;
    Place *place;
}

@property (readonly,nonatomic,copy)NSString *title;
@property (readonly,nonatomic,copy)Place *place;
@property (readonly,nonatomic,copy)NSString *subtitle;

-(id)initWithName:(NSString *)name andLocation:(CLLocationCoordinate2D)location;
-(id)initWithPlace:(Place *)aPlace;

@end
