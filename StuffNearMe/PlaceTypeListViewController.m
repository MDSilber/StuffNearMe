//
//  ListViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 7/16/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "PlaceTypeListViewController.h"
#import "StuffNearMeAppDelegate.h"

@implementation PlaceTypeListViewController

@synthesize placesList;
@synthesize lastIndexPath;
@synthesize typeSelected;
@synthesize selectedPlaceIndex;

-(void)dealloc
{
    //NSLog(@"%@ dealloc called",[self class]);

    [placesList release];
    [lastIndexPath release];
    [typeSelected release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{    
    selectedPlaceIndex = -1;
    placesList = [[[NSArray alloc] initWithObjects:
                   @"Airport", //airport
                   @"ATM", //atm
                   @"Bakery", //bakery
                   @"Bank", //bank
                   @"Bar", //bar
                   @"Book Store", //book_store
                   @"Bus Station", //bus_station
                   @"Cafe", //cafe
                   @"Car Repair", //car_repair
                   @"Church", //church
                   @"Convenience Store", //convenience_store
                   @"Department Store", //department_store
                   @"Doctor", //doctor
                   @"Fire Station", //fire_station
                   @"Florist", //florist
                   @"Gas Station", //gas_station
                   @"Gym", //gym
                   @"Hospital", //hospital
                   @"Laundromat", //laundry
                   @"Library", //library
                   @"Liquor Store", //liquor_store
                   @"Lodging", //lodging
                   @"Mosque", //mosque
                   @"Movie Theater", //movie_theater
                   @"Museum", //museum
                   @"Parking", //parking
                   @"Parks", //park
                   @"Pharmacy", //pharmacy
                   @"Police", //police
                   @"Post Office", //post_office
                   @"Restaurant", //restaurant
                   @"School", //school
                   @"Shopping Mall", //shopping_mall
                   @"Subway Station", //subway_station
                   @"Supermarket", //grocery_or_supermarket
                   @"Synagogue", //synagogue
                   @"Taxi Stand", //taxi_stand
                   @"Train Station", //train_station
                   @"University", //university
                   nil] retain];
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
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
    [super viewDidLoad];
    [[self navigationController] setTitle:@"Place Options"];

    // Uncomment the following line to preserve selection between presentations.
    [self setClearsSelectionOnViewWillAppear:NO];
    [[self tableView] reloadData];
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
    [[self navigationController] setToolbarHidden:YES animated:YES];

    [super viewWillAppear:animated];
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
    return [placesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    

    [[cell textLabel] setText:[placesList objectAtIndex:indexPath.row]];
    
//    if([[self lastIndexPath] isEqual:indexPath])
//    {
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//    }
//    else
//    {
//        [cell setAccessoryType:UITableViewCellAccessoryNone];
//    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    StuffNearMeAppDelegate *mainDelegate = (StuffNearMeAppDelegate *)[[UIApplication sharedApplication] delegate];

//    if([self lastIndexPath])
//    {
//        UITableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:[self lastIndexPath]];
//        [uncheckCell setAccessoryType:UITableViewCellAccessoryNone];
//        selectedPlaceIndex = -1;
//        [mainDelegate setTempPlace:selectedPlaceIndex];
//    }
//    
//    if([[self lastIndexPath] isEqual:indexPath])
//    {
//        [self setLastIndexPath: nil];
//    }
//    else
//    {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//        [self setLastIndexPath: indexPath];
//        selectedPlaceIndex = [placesList indexOfObject:[[cell textLabel]text]];
//        
//        [mainDelegate setTempPlace:selectedPlaceIndex];
//        //NSLog(@"Selected place index: %d",(int)mainDelegate.UtempPlace);
//    }
    
    selectedPlaceIndex = [placesList indexOfObject:[[[tableView cellForRowAtIndexPath:indexPath] textLabel]text]];
    [mainDelegate setTempPlace:selectedPlaceIndex];
    NSLog(@"%d",selectedPlaceIndex);

    [self.navigationController popViewControllerAnimated:YES];

}

@end
