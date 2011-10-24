//
//  Place.h
//  StuffNearMe
//
//  Created by Mason Silber on 7/18/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Place : NSObject
{
    NSString *name;
    NSString *address;
    float latitude;
    float longitude;
    float distanceFromStartingPoint;
    CLLocation *location;
    CLLocation *startLocation;
    NSURL *iconURL;
    NSString *reference;
    NSString *type;
    NSDate *dateCreated;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain)NSString *address;
@property (nonatomic, retain) CLLocation *location,*startLocation;
@property float latitude;
@property float longitude;
@property float distanceFromStartingPoint;
@property (nonatomic, retain) NSURL *iconURL;
@property (nonatomic, retain) NSString *reference;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, readonly, retain) NSDate *dateCreated;

-(id)initWithName:(NSString *)aName andAddress:(NSString *)anAddress andLatitude:(float)aLatitude andLongitude:(float)aLongitude andStartingCoordinate:(CLLocation *)start andImage:(UIImage *)image;
-(float)distanceFromStartingPoint:(CLLocation *)startingPoint;
-(void)print;

@end
