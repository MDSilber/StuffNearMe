//
//  WholeMapViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 7/23/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "MapPin.h"
#import "Place.h"
#import "DetailsViewController.h"
#import "ActivityIndicatorViewController.h"
#import "Json.h"

@interface WholeMapViewController : UIViewController<MKMapViewDelegate>
{
    NSArray *places;
    CLLocation *currentLocation;
    MKMapView *map;
    NSMutableArray *placePins;
    MapPin *currentLocationPin;
    UIBarButtonItem *mapType;
    ActivityIndicatorViewController *loading;
    
}
- (id)initWithPlaces:(NSArray *)placesArray andCurrentLocation:(CLLocation *)aLocation;
-(void)plotPlaces;
-(void)zoomToFitMapAnnotations:(MKMapView *)aMapView;
-(IBAction)changeMapType:(id)sender;
-(void)pushDetailsPageFromView:(NSArray *)objects;

@end
