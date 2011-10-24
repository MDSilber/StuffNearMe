//
//  PlacesListViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 7/16/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "JSON.h"
#import "Place.h"
#import "OnePlaceViewController.h"
#import "WholeMapViewController.h"

@interface PlacesListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate,UIAlertViewDelegate>
{
    NSMutableArray *finalPlaceArray;
    
    CLLocation *startingCoordinate;
    
    __block NSMutableArray *addressOutputArray;
    
    NSString *URL;
    BOOL firstCall;
    
    UIView *loadingView;
    UIActivityIndicatorView *activityIndicator;
    
    NSString *placeType;
    int range;
    SBJsonParser *parser;
    WholeMapViewController *wholeMap;
}

-(void)parseJSONOfGooglePlacesAPI;
-(void)parseJSONOfGoogleAutocompleteAPI;
- (id)initWithStyle:(UITableViewStyle)style andURL:(NSString *)placesURL andCoordinate:(CLLocationCoordinate2D)coordinate andPlaceType:(NSString *)type andRange:(int)range;
-(IBAction)viewMap:(id)sender;

@end
