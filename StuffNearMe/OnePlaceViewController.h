//
//  OnePlaceViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 7/17/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "MapPin.h"
#import "Place.h"
//#import "DetailsViewController.h"
#import "ActivityIndicatorViewController.h"

@interface OnePlaceViewController : UIViewController <MKMapViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate,UINavigationControllerDelegate>
{
    MKMapView *mapView;
    Place *place;
    MapPin *placePin;
    MapPin *startingLocationPin;
    CLLocation *startingLocation;
    NSArray *mapAnnotations;
    NSString *transportType;
    CLLocationManager *manager;
    UIBarButtonItem *mapType;
    //DetailsViewController *detailsViewController;
    ActivityIndicatorViewController *loading;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlace:(Place *)aPlace andCurrentLocation:(CLLocation *)location;
-(void)zoomToFitMapAnnotations:(MKMapView *)aMapView;
-(IBAction)getDirections:(id)sender;
-(IBAction)changeMapType:(id)sender;
-(IBAction)updateCurrentLocation:(id)sender;
//-(void)pushDetailsPageFromView:(MKAnnotationView *)view;

@end
