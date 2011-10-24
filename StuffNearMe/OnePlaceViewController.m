//
//  MapViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 7/17/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "OnePlaceViewController.h"
#import "SBJson.h"

#define DetailsURLOne @"https://maps.googleapis.com/maps/api/place/details/json?reference="
#define DetailsURLTwo @"&sensor=false&key=AIzaSyB82DFAyuV8aeLaQ3ubJ-ZYsy6gC6HuX0o"

@implementation CLLocation (NSAddition)
+(void)printLocation:(CLLocation *)location
{
    NSLog(@"Latitude: %f", [location coordinate].latitude);
    NSLog(@"Longitude: %f", [location coordinate].longitude);
}
@end    

@implementation OnePlaceViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlace:(Place *)aPlace andCurrentLocation:(CLLocation *)location
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        place = aPlace;
        startingLocation = location;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidDisappear:(BOOL)animated
{
    if([loading view].superview)
    {
        [[loading view] removeFromSuperview];
    }
    [super viewDidDisappear:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{

    NSLog(@"View did load");
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target: nil action:nil];
    
    UIBarButtonItem *getDirections = [[UIBarButtonItem alloc] init];
    [getDirections setTitle:@"Get Directions"];
    [getDirections setStyle:UIBarButtonItemStyleBordered];
    [getDirections setTarget:self];
    [getDirections setAction:@selector(getDirections:)]; 
    
    mapType = [[UIBarButtonItem alloc] init];
    [mapType setTitle:@"Sattelite"];
    [mapType setStyle: UIBarButtonItemStyleBordered];
    [mapType setTarget:self];
    [mapType setAction:@selector(changeMapType:)];

    
    NSArray *items = [NSArray arrayWithObjects:mapType,flex,getDirections,nil];
    UIColor *color = [UIColor colorWithRed:26/255.0f green:96/255.0f blue:156/255.0f alpha:1.0];
    [[[self navigationController] toolbar] setTintColor:color];
    [self setToolbarItems:items];
    
    [flex release];
    [getDirections release];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    manager = [[CLLocationManager alloc] init];
    [manager setDelegate:self];
    [manager setDistanceFilter:kCLDistanceFilterNone];
    [manager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    [mapView setDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL standard = [defaults boolForKey:@"defaultMapType"];
    
    if(standard)
    {
        [mapView setMapType: MKMapTypeStandard];
    }
    else
    {
        [mapView setMapType: MKMapTypeSatellite];
    }
    
    placePin = [[MapPin alloc] initWithPlace:place];
    startingLocationPin = [[MapPin alloc] initWithName:@"Starting Location" andLocation:[startingLocation coordinate]];
    
    mapAnnotations = [[NSArray alloc] initWithObjects:placePin, startingLocationPin, nil];
    
    for(MapPin *pin in mapAnnotations)
    {
        //NSLog(@"Number of annotations: %d",[mapAnnotations count]);
       // NSLog(@"Location of pin %@: %f,%f", [pin title], [pin coordinate].latitude, [pin coordinate].longitude);
        [mapView addAnnotation:pin];
    }
    
    [self zoomToFitMapAnnotations:mapView];
    
    [[self view] addSubview:mapView];

}


-(void)dealloc
{
    NSLog(@"%@ dealloc called",[self class]);

    [mapView release];
    [placePin release];
    [startingLocationPin release];
    [mapAnnotations release];
    [mapType release];
    [detailsViewController release];

    if(loading)
    {
        [loading release];
    }
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View will appear.");
    [[self navigationController] setToolbarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];

    
    if(pinView == nil)
    {
        pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] autorelease];
        [pinView setAnnotation:annotation];
        [pinView setAnimatesDrop: YES];
        [pinView setCanShowCallout:YES];

        if([[(MapPin *)annotation title] isEqualToString:@"Starting Location"])
        {
            [pinView setPinColor:MKPinAnnotationColorGreen];
            [pinView setRightCalloutAccessoryView:nil];
        }
        else
        {
            [pinView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
            [pinView setPinColor:MKPinAnnotationColorRed];
        }
        
    }
    
    return pinView;
}

-(void)zoomToFitMapAnnotations:(MKMapView *)aMapView
{
    if([[aMapView annotations] count] == 0)
    {
        return;
    }
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = - 90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(MapPin* pin in [mapView annotations])
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude,[pin coordinate].longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [pin coordinate].latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [pin coordinate].longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude,[pin coordinate].latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude-bottomRightCoord.latitude)*0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude)*0.5;

    region.span.latitudeDelta = 1.2*fabs(topLeftCoord.latitude-bottomRightCoord.latitude);
    region.span.longitudeDelta = 1.2*fabs(topLeftCoord.longitude-bottomRightCoord.longitude);
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

-(IBAction)getDirections:(id)sender
{
    UIActionSheet *options = [[UIActionSheet alloc] initWithTitle:@"Choose Transportation Method" 
                                                         delegate:self 
                                                cancelButtonTitle:@"Cancel" 
                                           destructiveButtonTitle:nil 
                                                otherButtonTitles:@"Driving", @"Walking", @"Biking",@"Public Transportation", nil];
    
    [options setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [options showFromToolbar:[[self navigationController] toolbar]];
    [options release];
}

-(IBAction)updateCurrentLocation:(id)sender
{
    [manager startUpdatingLocation];
    //NSLog(@"Location beginning to update");
}

-(IBAction)changeMapType:(id)sender
{
    if([mapView mapType] == MKMapTypeStandard)
    {
        [mapView setMapType:MKMapTypeHybrid];
        [mapType setTitle:@"Map"];
    }
    else
    {
        [mapView setMapType:MKMapTypeStandard];
        [mapType setTitle : @"Satellite"];
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        transportType = @"&dirflg=w";
    }
    else if(buttonIndex == 2)
    {
        transportType = @"&dirflg=b";
    }
    else if(buttonIndex == 3)
    {
        transportType = @"&dirflg=r";
    }
    
    else
    {
        transportType = @"";
        
        if(buttonIndex == [actionSheet cancelButtonIndex])
        {
            return;
        }
    }
    
    NSString *URL = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%f,%f&daddr=%f,%f%@",[startingLocation coordinate].latitude,[startingLocation coordinate].longitude,[place latitude],[place longitude],transportType];
    NSURL *directions = [NSURL URLWithString:URL];
    
    [[UIApplication sharedApplication] openURL:directions];
    
    return;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    loading = [[ActivityIndicatorViewController alloc] init];
    [[self view] addSubview:[loading view]];
    [NSThread detachNewThreadSelector:@selector(pushDetailsPageFromView:) toTarget:self withObject:view];
}

-(void)pushDetailsPageFromView:(MKAnnotationView *)view
{
    NSURL *detailsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",DetailsURLOne,[place reference],DetailsURLTwo]];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *JSON = [[[NSString alloc] initWithContentsOfURL:detailsURL encoding:NSUTF8StringEncoding error:nil] autorelease];
    NSDictionary *result = [[parser objectWithString:JSON error:nil] objectForKey:@"result"];
    
    NSString *phoneNumber = [[result objectForKey:@"formatted_phone_number"] retain];
    NSString *zipCode = [[[[result objectForKey:@"address_components"] lastObject] objectForKey:@"long_name"] substringToIndex:5];
    [parser release];
    
    detailsViewController = [[DetailsViewController alloc] initWithPlace:[(MapPin *)[view annotation] place] andPhoneNumber:phoneNumber andZipCode:zipCode];
    [detailsViewController setTitle:[[view annotation] title]];
    [[self navigationController] pushViewController:detailsViewController animated:YES];
}
@end
