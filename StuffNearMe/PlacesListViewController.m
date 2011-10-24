//
//  PlacesListViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 7/16/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "PlacesListViewController.h"
#import "MapKit/MapKit.h"
#import "StuffNearMeAppDelegate.h"

#define DetailsURLOne @"https://maps.googleapis.com/maps/api/place/details/json?reference="
#define DetailsURLTwo @"&sensor=false&key=AIzaSyB82DFAyuV8aeLaQ3ubJ-ZYsy6gC6HuX0o"

@implementation NSString (NSAddition)

-(NSString *)stringBetweenFirstString:(NSString *)firstString andSecondString:(NSString *)secondString
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:firstString intoString:NULL];
    if([scanner scanString:firstString intoString:NULL])
    {
        NSString *result = nil;
        if([scanner scanUpToString:secondString intoString:&result])
        {
            return result;
        }
    }
    return nil;
}

@end

@implementation CLLocation (NSAddition)

-(BOOL)isEqual:(id)otherObject
{
    if([self coordinate].latitude == [otherObject coordinate].latitude && [self coordinate].longitude == [otherObject coordinate].longitude)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end

@implementation PlacesListViewController

-(void)dealloc
{
    //NSLog(@"%@ dealloc called",[self class]);
    
    [addressOutputArray release];
    [finalPlaceArray release];
    [startingCoordinate release];
    [URL release];
    [parser release];
    
    if(wholeMap)
    {
        [wholeMap release];
    }
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style andURL:(NSString *)placesURL andCoordinate:(CLLocationCoordinate2D)coordinate andPlaceType:(NSString *)type andRange:(int)aRange
{
    self = [super initWithStyle:style];
    UIBarButtonItem *viewMap = [[UIBarButtonItem alloc] initWithTitle:@"View Map" style:UIBarButtonItemStyleBordered target:self action:@selector(viewMap:)];
    [self setToolbarItems:[NSArray arrayWithObjects: viewMap,nil]];
    [viewMap release];
    parser = [[SBJsonParser alloc] init];
    placeType = type;
    
    range = aRange;
    
    loadingView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [loadingView setBackgroundColor:[UIColor blackColor]];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(135, 185, 50, 50)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [[self tableView] addSubview:loadingView];
    [loadingView addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    firstCall = YES;
    URL = placesURL;
    [URL retain];
    startingCoordinate = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    if (self) {
        addressOutputArray = [[NSMutableArray alloc] init];
        finalPlaceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)parseJSONOfGooglePlacesAPI
{
    firstCall = NO;
    
    //NSLog(@"URL from Places List:%@",URL);
    NSURL *googlePlacesURL = [NSURL URLWithString:URL];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:googlePlacesURL] returningResponse:&response error:&error];
    NSString *JSON = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSArray *JSONResults = [[parser objectWithString:JSON error:nil] objectForKey:@"results"];
    
    if([JSONResults count] == 0)
    {
        UIAlertView *noResults = [[UIAlertView alloc] initWithTitle:@"No results"
                                                            message:[NSString stringWithFormat:@"There are no %@ within %d miles of your selected location",placeType, range] 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil, nil];
        [noResults setTag:1];
        [noResults show];
        [noResults release];
    }
    
    for(NSDictionary *dict in JSONResults)
    {
        //Create places and add to final place array
        
        Place *place = [[Place alloc] init];
        [place setName:[dict objectForKey:@"name"]];
        [place setLatitude:[[[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue]];
        [place setLongitude:[[[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:place.latitude longitude:place.longitude];
        [place setLocation:location];
        [location release];
        
        [place setStartLocation:startingCoordinate];
        [place setReference:[dict objectForKey:@"reference"]];
        [place setType:[self title]];
        [place setIconURL:[NSURL URLWithString:[dict objectForKey:@"icon"]]];
        
        [finalPlaceArray addObject:place];
        [place release];
        
    }
    
    //NSLog(@"***************************************");
    
    for(Place *place in finalPlaceArray)
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[place location] completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if(placemarks && [placemarks count] > 0)
             {
                 CLPlacemark *topResult = [placemarks objectAtIndex:0];
                 
                 NSString *address = [[NSString stringWithFormat:@"%@ %@, %@ %@", [topResult subThoroughfare],[topResult thoroughfare],[topResult locality], [topResult administrativeArea]]retain];
                 
                 [addressOutputArray addObject:address];
                 
                 [place setAddress: address];
                 [address release];
                 
                 //only call if it's the last call
                 if([addressOutputArray count] == [finalPlaceArray count])
                 {
                     //NSLog(@"Sorting");
                     NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distanceFromStartingPoint" ascending:YES];
                     [finalPlaceArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
                     [sort release];
                     
                     [activityIndicator removeFromSuperview];
                     [loadingView removeFromSuperview];
                     [[self tableView] reloadData];
                 }
             }
             
         }];
        
        [geocoder release];
    }
    
}

-(void)parseJSONOfGoogleAutocompleteAPI
{
    firstCall = NO;
    
    //NSLog(@"URL from Places list: %@", URL);
    
    NSURL *googleAutocompleteURL = [NSURL URLWithString:URL];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:googleAutocompleteURL] returningResponse:&response error:&error];
    NSString *JSON = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary *JSONResults = [parser objectWithString:JSON error:nil];
    
    if([(NSString *)[JSONResults objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"])
    {
        UIAlertView *noResults = [[UIAlertView alloc] initWithTitle:@"No Results"
                                                            message:@"There were no results for your search." 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil, nil];
        [noResults setTag:2];
        [noResults show];
        [noResults release];
    }
    
    NSArray *predictions = [JSONResults objectForKey:@"predictions"];
    NSMutableArray *references = [[NSMutableArray alloc] init];
    
    for(NSDictionary *prediction in predictions)
    {
        [references addObject:[prediction objectForKey:@"reference"]];
    }
    
    for(NSString *reference in references)
    {
        NSURL *detailsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",DetailsURLOne,reference,DetailsURLTwo]];
        //NSLog(@"%@",[detailsURL absoluteString]);
        
        NSString *JSON = [[[NSString alloc] initWithContentsOfURL:detailsURL encoding:NSUTF8StringEncoding error:nil] autorelease];
        NSDictionary *result = [[parser objectWithString:JSON error:nil] objectForKey:@"result"];
        
        Place *place = [[Place alloc] init];
        [place setName:[result objectForKey:@"name"]];
        [place setReference:reference];
        [place setType:[[result objectForKey:@"types"] objectAtIndex:0]];
        [place setIconURL:[result objectForKey:@"icon"]];
        
        [place setLatitude:[[[[result objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue]];
        [place setLongitude:[[[[result objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[place latitude] longitude:[place longitude]];
        [place setLocation:location];
        [location release];
        [place setStartLocation:startingCoordinate];
        
        [finalPlaceArray addObject:place];
        [place release];
    }
    
    [references release];
    
    for(Place *place in finalPlaceArray)
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[place location] completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if(placemarks && [placemarks count] > 0)
             {
                 CLPlacemark *topResult = [placemarks objectAtIndex:0];
                 
                 NSString *address = [NSString stringWithFormat:@"%@ %@, %@ %@", [topResult subThoroughfare],[topResult thoroughfare],[topResult locality], [topResult administrativeArea]];
                 
                 [addressOutputArray addObject:address];
                 
                 [place setAddress: address];
                 
                 if([addressOutputArray count] == [finalPlaceArray count])//finalplacearray was locationoutputarray
                 {
                     //NSLog(@"Sorting");
                     NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distanceFromStartingPoint" ascending:YES];
                     [finalPlaceArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
                     [sort release];
                     
                     [[self tableView] reloadData];
                     [activityIndicator removeFromSuperview];
                     [loadingView removeFromSuperview];
                 }
             }
             
         }];
        
        [geocoder release];
    }    
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
    UIImageView *google = [[UIImageView alloc] initWithFrame:CGRectMake(215, 0, 100, 15)];
    [google setImage: [UIImage imageNamed:@"GoogleWhite.png"]];
    UIBarButtonItem *googleButton = [[UIBarButtonItem alloc] initWithCustomView:google];
    [[self navigationItem] setRightBarButtonItem:googleButton];
    [google release];
    [googleButton release];
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[[self navigationController] toolbar] setTintColor:[UIColor colorWithRed:26/255.0f green:96/255.0f blue:156/255.0f alpha:1.0]];
    [[self navigationController] setToolbarHidden:NO animated:YES];
    
    if(firstCall)
    {
        if(placeType != nil)
        {
            [self parseJSONOfGooglePlacesAPI];
        }
        else
        {
            [self parseJSONOfGoogleAutocompleteAPI];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [finalPlaceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if([finalPlaceArray count] > 0 && [finalPlaceArray count] > [indexPath row])
    {
        [[cell textLabel] setText:[[[finalPlaceArray objectAtIndex:[indexPath row]] name] capitalizedString]];
        [[cell detailTextLabel] setText: [(NSString *)[[finalPlaceArray objectAtIndex:[indexPath row]] address] capitalizedString]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OnePlaceViewController *mapView = [[OnePlaceViewController alloc] initWithNibName:nil bundle:nil andPlace:[finalPlaceArray objectAtIndex:[indexPath row]] andCurrentLocation:startingCoordinate];
    [[finalPlaceArray objectAtIndex:[indexPath row]] print];
    
    [mapView setTitle :[[finalPlaceArray objectAtIndex:[indexPath row]] name]];
    [[self navigationController] pushViewController:mapView animated:YES];
    
    [[[self tableView] cellForRowAtIndexPath:indexPath] setSelected:NO];
    [mapView release];
}

#pragma mark - Table view delegate

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 1 || [alertView tag] == 2)
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else
    {
        return;
    }
}

-(IBAction)viewMap:(id)sender
{
    wholeMap = [[WholeMapViewController alloc] initWithPlaces:finalPlaceArray andCurrentLocation:startingCoordinate];
    [wholeMap setTitle:[self title]];
    [[self navigationController] pushViewController:wholeMap animated:YES];
}


@end

