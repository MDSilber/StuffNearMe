//
//  StartPageViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 7/15/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "StartPageViewController.h"

#define PlacesURLOne @"https://maps.googleapis.com/maps/api/place/search/json?location="//coordinates
#define PlacesURLTwo @"&radius="//radius in meters
#define PlacesURLThree @"&types="//place type
#define PlacesURLFour @"&sensor=true&key=AIzaSyB82DFAyuV8aeLaQ3ubJ-ZYsy6gC6HuX0o"

#define AutocompleteURLOne @"https://maps.googleapis.com/maps/api/place/autocomplete/json?input="//search input
#define AutocompleteURLTwo @"&types=establishment&location="//location (coordinates)
#define AutocompleteURLThree @"&radius="//radius in meters
#define AutocompleteURLFour @"&sensor=true&key=AIzaSyB82DFAyuV8aeLaQ3ubJ-ZYsy6gC6HuX0o"

#define Keyboard_Offset 200


@implementation StartPageViewController

@synthesize placesList;
@synthesize googlePlaces;
@synthesize rangeSlider;
@synthesize rangeLabel;
@synthesize go;
@synthesize locationTextField;
@synthesize searchTextField;
@synthesize goToList;
@synthesize listView;
@synthesize placesListView;
@synthesize currentSelectionLabel;
@synthesize mainDelegate;
@synthesize delegate;
//@synthesize recentAddressDelegate;

-(void)dealloc
{
    //NSLog(@"%@ dealloc called",[self class]);
    
    [rangeSlider release];
    [placesList release];
    [googlePlaces release];
    [rangeLabel release];
    [goToList release];
    [go release];
    [locationTextField release];
    [searchTextField release];
    [currentSelectionLabel release];
    [mainDelegate release];
    [delegate release];
    [managedObjectContext release];
    [loading release];
    [locationManager release];
    
    if(placesListView != nil)
    {
        [placesListView release];
    }
    if(listView != nil)
    {
        [listView release];
    }
    
    [goImage release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"EarthBackground.png"]]];
    [locationTextField resignFirstResponder];
    [searchTextField resignFirstResponder];
    [locationTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [searchTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    
    mainDelegate = (StuffNearMeAppDelegate *)[[UIApplication sharedApplication] delegate];
//    if((int)[mainDelegate tempPlace] != -1 && placeSelected)
//    {
//        [currentSelectionLabel setText:[NSString stringWithFormat:@"Current Selection: %@",[placesList objectAtIndex:(unsigned int)[mainDelegate tempPlace]]]];
//    }
//    else
//    {
//        [currentSelectionLabel setText:@"Current Selection: none"];
//    }
    
    if((int)[mainDelegate tempPlace] != -1)
    {
        [searchTextField setText:[placesList objectAtIndex:(unsigned int)[mainDelegate tempPlace]]];
    }
    
    if([[locationTextField text] length] == 0)
    {
        [go setBackgroundImage:[UIImage imageNamed:@"UseCurrentLocation.png"] forState:UIControlStateNormal];
        goName = @"CL";
    }
    else
    {
        [go setBackgroundImage:[UIImage imageNamed:@"UseThisAddress.png"] forState:UIControlStateNormal];
        goName = @"TA";
    }
    
    [locationManager startUpdatingLocation];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    //Hides label
    //[currentSelectionLabel setHidden:YES];
    if(![StuffNearMeAppDelegate connectedToInternet])
    {
        UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" 
                                                                  message:@"Your device has no available internet connection. Please connect to the internet and relaunch app" 
                                                                 delegate:self 
                                                        cancelButtonTitle:@"Exit" 
                                                        otherButtonTitles:nil, nil];
        [noInternetAlert setTag:1];
        [noInternetAlert show];
        [noInternetAlert release];
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    [mainDelegate setTempPlace:-1];
    managedObjectContext =[[(StuffNearMeAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] retain];
    
    //[self setDelegate:recentAddressDelegate];
    
    placeSelected = NO; 
    keyboardOnScreen = NO;
    placesList = [[(StuffNearMeAppDelegate *)[[UIApplication sharedApplication] delegate] placeList] retain];
    googlePlaces = [[(StuffNearMeAppDelegate *)[[UIApplication sharedApplication] delegate] googlePlacesList] retain];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleKeyboardOnScreen) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleKeyboardOnScreen) name:UIKeyboardDidHideNotification object:nil];
    }
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager startUpdatingLocation];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [locationTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    UIColor *color = [UIColor colorWithRed:26/255.0f green:96/255.0f blue:156/255.0f alpha:1.0];
    [[[self navigationController] navigationBar] setTintColor:color];
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(pushAboutPage:)];
    [[self navigationItem] setLeftBarButtonItem:aboutButton];
    [aboutButton release];
    
    UIImage *listImage = [UIImage imageNamed:@"ChooseLocationType.png"];
    goToList = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonRect = CGRectMake(25,94,270,51);
    [goToList setFrame:buttonRect];
    [goToList setBackgroundImage:listImage forState:UIControlStateNormal];
    [goToList setUserInteractionEnabled:YES];
    [goToList addTarget:self action:@selector(choosePlaceType:) forControlEvents:UIControlEventTouchUpInside];
    
    if([[locationTextField text] length] == 0)
    {
        //NSLog(@"Length is zero");
        goImage = [UIImage imageNamed:@"UseCurrentLocation.png"];
        goName = @"CL";
    }
    else
    {
        //NSLog(@"Length is not zero");
        goImage = [UIImage imageNamed:@"UseThisAddress.png"];
        goName = @"TA";
    }
    go = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect goRect = CGRectMake(25, 295, 270, 51);
    [go setFrame:goRect];
    [go setBackgroundImage:goImage forState:UIControlStateNormal];
    [go setUserInteractionEnabled:YES];
    [go addTarget:self action:@selector(getPlacesPressed:) forControlEvents:UIControlEventTouchUpInside];
    [currentSelectionLabel setTextColor:[UIColor whiteColor]];
    
    [[self view] addSubview:goToList];
    [[self view] addSubview:go];
    
    UIBarButtonItem *favorites = [[UIBarButtonItem alloc] initWithTitle:@"Favorites" 
                                                                    style:UIBarButtonItemStyleBordered 
                                                                   target:self 
                                                                   action:@selector(goToSavedAddresses:)];
    
    [[self navigationItem] setRightBarButtonItem:favorites];
    [favorites release];
    
    [super viewDidLoad];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if([[loading view] superview])
    {
        [[loading view] removeFromSuperview];
    }

    [locationManager stopUpdatingLocation];
    [super viewDidDisappear:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) rangeChanged:(UISlider *)sender
{
    int discreteValue = round([sender value]);
    [sender setValue:(float)discreteValue];
    if(discreteValue == 1)
    {
        [rangeLabel setText:[NSString stringWithFormat: @"Within range: %d Mile",discreteValue]];
    }
    else
    {
        [rangeLabel setText:[NSString stringWithFormat: @"Within range: %d Miles",discreteValue]];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    // NSLog(@"Did begin editing.");
    
    
    if(textField == locationTextField)
    {
        [go setBackgroundImage:[UIImage imageNamed:@"UseThisAddress.png"] forState:UIControlStateNormal];
        goName = @"TA";
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseInOut animations:^
         {
             CGRect frame = [[self view] frame];
             frame.origin.y -= Keyboard_Offset;
             [[self view] setFrame:frame];
             
         }
                         completion:NULL];
        

    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == locationTextField)
    {
        //Animation block
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseInOut animations:^
         {
             CGRect frame = [[self view]frame];
             frame.origin.y += Keyboard_Offset;
             [[self view] setFrame:frame];
         }
                         completion:^(BOOL finished)
         {
             if([[textField text] length] == 0)
             {
                 [go setBackgroundImage:[UIImage imageNamed:@"UseCurrentLocation.png"] forState:UIControlStateNormal];
                 goName = @"CL";
             }
             else
             {
                 [go setBackgroundImage:[UIImage imageNamed:@"UseThisAddress.png"] forState:UIControlStateNormal];
                 goName = @"TA";
             }
         }];        
    }
    
    [textField resignFirstResponder];
    return YES;
}

-(void)toggleKeyboardOnScreen
{
    keyboardOnScreen = (keyboardOnScreen)? NO:YES;
}

-(IBAction)getPlacesPressed:(id)sender
{
    loading = [[ActivityIndicatorViewController alloc] init];
    if(keyboardOnScreen)
    {
        [[loading view] setFrame:CGRectMake([loading view].frame.origin.x, [loading view].frame.origin.y + 120, [loading view].frame.size.width, [loading view].frame.size.height)];
    }
    [[self view] addSubview:[loading view]];
    [NSThread detachNewThreadSelector:@selector(getPlaces) toTarget:self withObject:nil];
}

-(void)getPlaces
{            
    if(((int)mainDelegate.tempPlace == -1 || !placeSelected) && [[searchTextField text] length] == 0)
    {
        UIAlertView *noSelectionAlert = [[UIAlertView alloc] 
                                         initWithTitle:@"Error" 
                                         message:@"Please select a type of place"
                                         delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
        [noSelectionAlert show];
        [noSelectionAlert release];
        if([[loading view] superview])
        {
            [[loading view] removeFromSuperview];
        }
        return;
    }
    
    __block float latitude;
    __block float longitude;
    range = 1600*[rangeSlider value];
    
    __block NSString *URL = nil;
    
    if([goName isEqualToString:@"CL"])
    {
        //if([[searchTextField text] length] == 0)
        if([placesList containsObject:[searchTextField text]])
        {
            URL = [NSString stringWithFormat:@"%@%f%@%f%@%d%@%@%@",PlacesURLOne,currentLocation.latitude, @",", currentLocation.longitude,PlacesURLTwo,range,PlacesURLThree,[googlePlaces objectAtIndex:(unsigned int)[mainDelegate tempPlace]],PlacesURLFour];

            placesListView = [[PlacesListViewController alloc] initWithStyle:UITableViewStylePlain andURL:URL andCoordinate:currentLocation andPlaceType:(NSString *)[[placesList objectAtIndex:(unsigned int)[mainDelegate tempPlace]] lowercaseString] andRange:range/1600];
            
            placeSelection = [listView selectedPlaceIndex];
            
            [placesListView setTitle:[NSString stringWithFormat:@"%@",[placesList objectAtIndex:(unsigned int)[mainDelegate tempPlace]]]];
            
            [[self navigationController] pushViewController:placesListView animated:YES];
            
        }
        else
        {
            NSLog(@"EEEEE");
            //Core data
            NSError *error = nil;
            RecentSearch *recentSearch = [NSEntityDescription insertNewObjectForEntityForName:@"RecentSearch" inManagedObjectContext:managedObjectContext];
            [recentSearch setName:[[searchTextField text] capitalizedString]];
            [recentSearch setDate:[NSDate date]];
            NSManagedObjectContext *context = [(StuffNearMeAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
            
            if(![context save:&error])
            {
                NSLog(@"Not saved. Error: %@",[error description]);
            }
            else
            {
                NSLog(@"Saved");
            }
            
            //Processing
            //NSLog(@"Current Location, Search");
            //NSLog(@"Latitude: %f",currentCoordinate.latitude);
            //NSLog(@"Longitude: %f",currentCoordinate.longitude);
            
            URL = [NSString stringWithFormat:@"%@%@%@%f%@%f%@%d%@",AutocompleteURLOne,[searchTextField text],AutocompleteURLTwo,currentLocation,@",",currentLocation,AutocompleteURLThree,range,AutocompleteURLFour];
            
            placesListView = [[PlacesListViewController alloc] initWithStyle:UITableViewStylePlain andURL:URL andCoordinate:currentLocation andPlaceType:nil andRange:range/1600];
            [placesListView setTitle:@"Results"];
            
            [[self navigationController] pushViewController:placesListView animated:YES];
            
        }
        
    }
    else
    {        
        //Core data analysis
        NSString *address = [locationTextField text];
        NSError *error = nil;
        RecentAddress *recentAddress = [NSEntityDescription insertNewObjectForEntityForName:@"RecentAddress" inManagedObjectContext:managedObjectContext];
        [recentAddress setDate:[NSDate date]];
        [recentAddress setAddress:[address capitalizedString]];
        NSManagedObjectContext *context = [(StuffNearMeAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
        
        if(![context save:&error])
        {
            NSLog(@"Not saved. Error: %@",[error description]);
        }
        else
        {
            NSLog(@"Saved");
        }
        
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
         {
             CLPlacemark *topResult;
             if(placemarks && [placemarks count] > 0)
             {
                 topResult = [placemarks objectAtIndex:0];
                 latitude = [[topResult location] coordinate].latitude;
                 longitude = [[topResult location] coordinate].longitude;
                 //NSLog(@"Latitude: %f, Longitude: %f",latitude,longitude);
             }
             else
             {
                 topResult = nil;
                 return;
             }
             
             //if([[searchTextField text] length] == 0)
             if([placesList containsObject:[searchTextField text]])
             {
                 //NSLog(@"Inputted Address, No Search");
                 URL = [NSString stringWithFormat:@"%@%f%@%f%@%d%@%@%@",PlacesURLOne,latitude, @",", longitude,PlacesURLTwo,range,PlacesURLThree,[googlePlaces objectAtIndex:(unsigned int)[mainDelegate tempPlace]],PlacesURLFour];
                 //NSLog(@"URL from Start Page:%@",URL);
                 
                 placesListView = [[PlacesListViewController alloc] initWithStyle:UITableViewStylePlain andURL:URL andCoordinate:[[topResult location] coordinate] andPlaceType:(NSString *)[[placesList objectAtIndex:(unsigned int)[mainDelegate tempPlace]] lowercaseString] andRange:range/1600];
                 
                 placeSelection = [listView selectedPlaceIndex];
                 
                 [placesListView setTitle:[NSString stringWithFormat:@"%@",[placesList objectAtIndex:(unsigned int)[mainDelegate tempPlace]]]];

                 [[self navigationController] pushViewController:placesListView animated:YES];
             }
             else
             {
                 //Core data
                 NSError *error = nil;
                 
                 RecentSearch *recentSearch = [NSEntityDescription insertNewObjectForEntityForName:@"RecentSearch" inManagedObjectContext:managedObjectContext];
                 [recentSearch setName:[[searchTextField text] capitalizedString]];
                 [recentSearch setDate:[NSDate date]];
                 NSManagedObjectContext *context = [(StuffNearMeAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
                 
                 if(![context save:&error])
                 {
                     NSLog(@"Not saved. Error: %@",[error description]);
                 }
                 else
                 {
                     NSLog(@"Saved");
                 }
                 
                 //NSLog(@"Inputted Address, Search");
                 URL = [NSString stringWithFormat:@"%@%@%@%f%@%f%@%d%@",AutocompleteURLOne,[searchTextField text],AutocompleteURLTwo,latitude,@",",longitude,AutocompleteURLThree,range,AutocompleteURLFour];
                 placesListView = [[PlacesListViewController alloc] initWithStyle:UITableViewStylePlain andURL:URL andCoordinate:[[topResult location] coordinate] andPlaceType:nil andRange:range/1600];
                 
                 [placesListView setTitle:@"Results"];

                 [[self navigationController] pushViewController:placesListView animated:YES];
             }
         }];

        [geocoder release];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation.coordinate;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}

-(IBAction)choosePlaceType:(id)sender
{   
    placeSelected = YES;
    
    if(!listView)
    {
        listView = [[PlaceTypeListViewController alloc] init];
    }
    [listView setTitle:@"Place Types"];
    
    if([[locationTextField text] length] != 0)
    {
        [go setBackgroundImage:[UIImage imageNamed:@"UseThisAddress.png"] forState:UIControlStateNormal];
        goName = @"TA";
        
    }
    
    [[self navigationController] pushViewController:listView animated:YES];
}

-(IBAction)pushAboutPage:(id)sender
{
    AboutViewController *aboutPage = [[AboutViewController alloc] init];
    [aboutPage setTitle:@"About"];
    [[self navigationController] pushViewController:aboutPage animated:YES];
    [aboutPage release];
}

-(IBAction)goToSavedAddresses:(id)sender
{
    SavedAddressesViewController *favorites = [[SavedAddressesViewController alloc] init];
    [favorites setTitle:@"Favorites"];
    [self setDelegate:favorites];
    [[self navigationController] pushViewController:favorites animated:YES];
    [favorites release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 1)
    {
        exit(1);
    }
}

@end
