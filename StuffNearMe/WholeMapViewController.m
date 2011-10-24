//
//  WholeMapViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 7/23/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "WholeMapViewController.h"

#define DetailsURLOne @"https://maps.googleapis.com/maps/api/place/details/json?reference="
#define DetailsURLTwo @"&sensor=false&key=AIzaSyB82DFAyuV8aeLaQ3ubJ-ZYsy6gC6HuX0o"

@implementation WholeMapViewController

-(void)dealloc
{
    //NSLog(@"%@ dealloc called",[self class]);

    [currentLocationPin release];
    [placePins release];
    
    if(loading)
    {
        [loading release];
    }
    
    [super dealloc];
}
- (id)initWithPlaces:(NSArray *)placesArray andCurrentLocation:(CLLocation *)aLocation
{
    self = [super init];
    if (self) {
        places = placesArray;
        currentLocation = aLocation;
        map = [[MKMapView alloc] initWithFrame:[[self view] frame]];
        [map setDelegate:self];

    }
    [self plotPlaces];
    return self;
}

-(void)plotPlaces
{
    placePins = [[NSMutableArray alloc] init];
    currentLocationPin = [[MapPin alloc] initWithName:@"Starting Location" andLocation:[currentLocation coordinate]];
    
    for(Place *place in places)
    {
        MapPin *tempPin = [[MapPin alloc] initWithPlace:place];
        [placePins addObject:tempPin];
        [tempPin release];
    } 
    for(MapPin *pin in placePins)
    {
        [map addAnnotation:pin];
    }
    [map addAnnotation:currentLocationPin];
    

    [self zoomToFitMapAnnotations:map];
    [[self view] addSubview:map];
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];

    if(pinView == nil)
    {
        pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] autorelease];
        [pinView setAnimatesDrop:YES];
        [pinView setCanShowCallout:YES];
    }
    else
    {
        [pinView setAnnotation:annotation];
    }
    
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
    
    return pinView;
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

-(void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setToolbarHidden:NO animated:YES];
    mapType = [[UIBarButtonItem alloc] init];
    [mapType setTitle:@"Satellite"];
    [mapType setStyle:UIBarButtonItemStyleBordered];
    [mapType setTarget:self];
    [mapType setAction:@selector(changeMapType:)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL standard = [defaults boolForKey:@"defaultMapType"];
    
    if(standard)
    {
        [map setMapType:MKMapTypeStandard];
    }
    else
    {
        [map setMapType:MKMapTypeSatellite];
    }
    
    [self setToolbarItems:[NSArray arrayWithObjects:mapType, nil]];

}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    
    for(MapPin* pin in [aMapView annotations])
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude,pin.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, pin.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, pin.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude,pin.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude-bottomRightCoord.latitude)*0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude)*0.5;
   // NSLog(@"Region center: %f,%f",region.center.latitude,region.center.longitude);
    region.span.latitudeDelta = 1.1*fabs(topLeftCoord.latitude-bottomRightCoord.latitude);
    region.span.longitudeDelta = 1.1*fabs(topLeftCoord.longitude-bottomRightCoord.longitude);
   // NSLog(@"Region span: %f, %f", region.span.latitudeDelta, region.span.longitudeDelta);
    
    region = [aMapView regionThatFits:region];
    [aMapView setRegion:region animated:YES];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    loading = [[ActivityIndicatorViewController alloc] init];
    [[self view] addSubview:[loading view]];
    Place *place = [(MapPin *)[view annotation] place];
    [NSThread detachNewThreadSelector:@selector(pushDetailsPageFromView:) toTarget:self withObject:[NSArray arrayWithObjects:view, place, nil]];
}

-(void)pushDetailsPageFromView:(NSArray *)objects
{
    MKAnnotationView *view = [objects objectAtIndex:0];
    Place *place = [objects objectAtIndex:1];
    
    NSURL *detailsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",DetailsURLOne,[place reference],DetailsURLTwo]];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *JSON = [[[NSString alloc] initWithContentsOfURL:detailsURL encoding:NSUTF8StringEncoding error:nil] autorelease];
    NSDictionary *result = [[parser objectWithString:JSON error:nil] objectForKey:@"result"];
    
    NSString *phoneNumber = [[result objectForKey:@"formatted_phone_number"] retain];
    NSString *zipCode = [[[[result objectForKey:@"address_components"] lastObject] objectForKey:@"long_name"] substringToIndex:5];
    [parser release];
    
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithPlace:[(MapPin *)[view annotation] place] andPhoneNumber:phoneNumber andZipCode:zipCode];
    [detailsViewController setTitle:[[view annotation] title]];
    [[self navigationController] pushViewController:detailsViewController animated:YES];
    [detailsViewController release];
}

-(IBAction)changeMapType:(id)sender
{
    if([map mapType] == MKMapTypeStandard)
    {
        [map setMapType:MKMapTypeHybrid];
        [mapType setTitle:@"Map"];
    }
    else
    {
        [map setMapType:MKMapTypeStandard];
        [mapType setTitle:@"Satellite"];
    }
}

@end
