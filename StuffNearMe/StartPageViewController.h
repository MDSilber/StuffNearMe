//
//  StartPageViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 7/15/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

//#import "PlaceTypeListViewController.h"
#import "PlacesListViewController.h"
#import "StuffNearMeAppDelegate.h"
#import "AboutViewController.h"
#import "SavedAddressesViewController.h"
#import "RecentAddress.h"
#import "ActivityIndicatorViewController.h"

@class RecentSearch;
@class RecentAddress;
//@protocol RecentAddressDelegate; 


@interface StartPageViewController : UIViewController<UITextFieldDelegate,CLLocationManagerDelegate,UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UISlider *rangeSlider;
    IBOutlet UILabel *rangeLabel, *enterSearchTermsLabel, *OR;
    IBOutlet UIButton *go;
    UIButton *choicesButton;
    IBOutlet UITextField *locationTextField, *searchTextField;
    NSArray *placesList;
    NSArray *googlePlaces; 
    int range;
    int placeSelection;
    BOOL placeSelected;
    BOOL keyboardOnScreen;
    //PlaceTypeListViewController *listView;
    PlacesListViewController *placesListView;
    StuffNearMeAppDelegate *mainDelegate;
    id delegate;
    UIImage *goImage;
    NSString *goName;
    NSManagedObjectContext *managedObjectContext;
    ActivityIndicatorViewController *loading;
    CLLocationCoordinate2D currentLocation;
    CLLocationManager *locationManager;
    UITableView *choicesTable;
}

@property (nonatomic, retain) IBOutlet UISlider *rangeSlider;
@property (nonatomic, retain) NSArray *placesList;
@property (nonatomic, retain) NSArray *googlePlaces;
@property (nonatomic, retain) IBOutlet UILabel *rangeLabel;
@property (nonatomic, retain) IBOutlet UIButton *go;
@property (nonatomic, retain) UIButton *choicesButton;
@property (nonatomic, retain) IBOutlet UITextField *locationTextField;
@property (nonatomic, retain) IBOutlet UITextField *searchTextField;
//@property (nonatomic, retain) PlaceTypeListViewController *listView;
@property (nonatomic, retain) PlacesListViewController *placesListView;
@property (nonatomic, retain) StuffNearMeAppDelegate *mainDelegate;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain, readonly) CLLocationManager *locationManager;

-(IBAction)rangeChanged:(id)sender;
-(IBAction)getPlacesPressed:(id)sender;
-(void)getPlaces;
//-(IBAction)choosePlaceType:(id)sender;
-(IBAction)pushAboutPage:(id)sender;
-(IBAction)goToSavedAddresses:(id)sender;
-(void)toggleKeyboardOnScreen;
-(void)choicesButtonPressed:(id)sender;

@end