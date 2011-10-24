//
//  SavedAddressesViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 8/4/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "SavedAddressesViewController.h"

@implementation SavedAddressesViewController
@synthesize favorites, recentAddresses, favoritesFetchedResultsController, recentAddressFetchedResultsController, recentSearchFetchedResultsController, managedObjectContext, recentSearches;

-(void)dealloc
{
    [favorites release];
    [recentAddresses release];
    [recentSearches release];
    [segmentedControl release];
    [segmentedControlButton release];
    [formatter release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        managedObjectContext = [(StuffNearMeAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, h:m a"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        numberOfRecentAddresses = [defaults integerForKey:@"recentAddressNumber"];
        numberOfRecentSearches = [defaults integerForKey:@"recentSearchNumber"];
                
        NSLog(@"Recent address number: %d",numberOfRecentAddresses);
        NSLog(@"Recent search number: %d", numberOfRecentSearches);
        
        [self getData];
    }
    return self;
}

-(void)getData
{
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sorters = [NSArray arrayWithObjects:sorter, nil];

    [request setEntity:[NSEntityDescription entityForName:@"FavoriteAddress" inManagedObjectContext:managedObjectContext]];
    
    NSArray *tempArray = [managedObjectContext executeFetchRequest:request error:nil];
    favorites = [[[tempArray sortedArrayUsingDescriptors:sorters] mutableCopy] retain];
    tempArray = nil;
    
    [sorter release];
    sorter = nil;
    sorter = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    sorters = [NSArray arrayWithObjects:sorter, nil];
    
    BOOL changeMade = NO;
    
    [request setEntity:[NSEntityDescription entityForName:@"RecentAddress" inManagedObjectContext:managedObjectContext]];
    
    tempArray = [managedObjectContext executeFetchRequest:request error:nil];
    recentAddresses = [[[tempArray sortedArrayUsingDescriptors:sorters] mutableCopy] retain];
    tempArray = nil;
    
    [request setEntity:[NSEntityDescription entityForName:@"RecentSearch" inManagedObjectContext:managedObjectContext]];
    
    tempArray = [managedObjectContext executeFetchRequest:request error:nil];
    recentSearches = [[tempArray sortedArrayUsingDescriptors:sorters] mutableCopy];
    //recentSearches = [[NSMutableArray arrayWithObjects:@"One",@"Two",@"Three",@"Four",@"Five",@"Six",@"Seven",@"Eight",@"Nine",@"Ten",@"Eleven",@"Twelve",@"Thirteen", nil] retain];
    
    [sorter release];
    
    if([recentAddresses count] > numberOfRecentAddresses)
    {
        NSLog(@"%d",[recentAddresses count]);
        changeMade = YES;
        NSMutableArray *toBeDeleted = [[NSMutableArray alloc] init];
        for(int i = numberOfRecentAddresses; i < [recentAddresses count]; i++)
        {
            [toBeDeleted addObject:[recentAddresses objectAtIndex:i]];
        }
        
        NSArray *temp = recentAddresses;
        
        [recentAddresses release];
        recentAddresses = nil;
        recentAddresses = [[NSMutableArray arrayWithArray:[temp objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfRecentAddresses-1)]]] retain];
        
        for(RecentAddress *recent in toBeDeleted)
        {
            [managedObjectContext deleteObject:recent];
        }
        [toBeDeleted release];
    }
    
    if([recentSearches count] > numberOfRecentSearches)
    {
        changeMade = YES;
        NSLog(@"%d",[recentSearches count]);
        NSMutableArray *toBeDeleted = [[NSMutableArray alloc] init];
        for(int i = numberOfRecentSearches; i < [recentSearches count]; i++)
        {
            [toBeDeleted addObject:[recentSearches objectAtIndex:i]];
        }        
        
        NSArray *temp = recentSearches;

        [recentSearches release];
        recentSearches = nil;
        recentSearches = [[NSMutableArray arrayWithArray:[temp objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfRecentSearches-1)]]] retain];

        for(RecentSearch *recent in toBeDeleted)
        {
            [managedObjectContext deleteObject:recent];
        }
        [toBeDeleted release];
    }
    
    if(changeMade)
    {
        if(![managedObjectContext save:&error])
        {
            NSLog(@"Not saved. Error: %@",[error description]);
        }
        else
        {
            NSLog(@"Saved");
        }
    }
        
    [request release];
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
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addFavoriteAddress:)];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clear:)];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Favorites", @"Recent",nil]];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl setSelectedSegmentIndex:0];
    
    segmentedControlButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl addTarget:self action:@selector(segmentedControlIndexChanged) forControlEvents:UIControlEventValueChanged];
    
    [self setToolbarItems:[NSArray arrayWithObjects:editButton, flex, segmentedControlButton, flex, clearButton, nil]];
    [[[self toolbarItems] objectAtIndex:4] setEnabled:NO];
    
    [[self navigationItem] setRightBarButtonItem:addButton];
    
    [[self navigationController] setToolbarHidden:NO animated:YES];
    
    [addButton release];
    [editButton release];
    [clearButton release];
    [flex release];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"View will appear");
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
    if([segmentedControl selectedSegmentIndex] == 1)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([segmentedControl selectedSegmentIndex] == 0)
    {
        return [favorites count];
    }
    else
    {
        if(section == 0)
        {
            return [recentAddresses count];
        }
        else
        {
            return [recentSearches count];
        }
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([segmentedControl selectedSegmentIndex] == 1)
    {
        if(section == 0)
        {
            return @"Recent Addresses";
        }
        else if (section == 1)
        {
            return @"Recent Searches";
        }
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    if([segmentedControl selectedSegmentIndex] == 0)
    {
        //NSLog(@"Favorites are being loaded");
        
        [[cell textLabel] setText:[[favorites objectAtIndex:indexPath.row] name]];
        [[cell detailTextLabel] setText:(NSString *)[[favorites objectAtIndex:indexPath.row] address]];
    }
    else
    {
        if([indexPath section] == 0)
        {
                [[cell textLabel] setText:(NSString *)[[recentAddresses objectAtIndex:indexPath.row] address]];
                [[cell detailTextLabel] setText:[formatter stringFromDate:[[recentAddresses objectAtIndex:indexPath.row] date]]];
        }
        else
        {

                [[cell textLabel] setText:[[recentSearches objectAtIndex:indexPath.row] name]];
                [[cell detailTextLabel] setText:[formatter stringFromDate:[[recentSearches objectAtIndex:indexPath.row] date]]];
        }
    }

    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSError *error = nil;
        
        if([segmentedControl selectedSegmentIndex] == 0)
        {
            FavoriteAddress *deleteFavorite = [favorites objectAtIndex:[indexPath row]];
            [managedObjectContext deleteObject:(NSManagedObject *)deleteFavorite];
            [favorites removeObject:deleteFavorite];
        }
        else
        {
            if([indexPath section] == 0)
            {
                RecentAddress *deleteAddress = [recentAddresses objectAtIndex:[indexPath row]];
                [managedObjectContext deleteObject:deleteAddress];
                [recentAddresses removeObject:deleteAddress];
            }
            else
            {
                RecentSearch *deleteSearch = [recentSearches objectAtIndex:[indexPath row]];
                [managedObjectContext deleteObject:deleteSearch];
                [recentSearches removeObject:deleteSearch];
            }
        }
        
        if(![managedObjectContext save:&error])
        {
            NSLog(@"Not saved. Error: %@",[error description]);
        }
        else
        {
            NSLog(@"Saved");
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    FavoriteAddress *tempFavorite = [favorites objectAtIndex:[fromIndexPath row]];
    [favorites removeObject:tempFavorite];
    [favorites insertObject:tempFavorite atIndex:[toIndexPath row]];
    
    int i = 0;
    for(FavoriteAddress *f in favorites)
    {
        [f setValue:[NSNumber numberWithInt:i++] forKey:@"index"];
    }
    
    NSError *error = nil;
    
    if(![managedObjectContext save:&error])
    {
        NSLog(@"Objects not deleted. Error: %@", [error description]);
    }
    else
    {
        NSLog(@"Objects deleted.");
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([segmentedControl selectedSegmentIndex] == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StartPageViewController *startPage = [[[[self navigationController] viewControllers] objectAtIndex:0] retain];
    
    //Favorites
    if([segmentedControl selectedSegmentIndex] == 0)
    {
        [[startPage locationTextField] setText:(NSString *)[[favorites objectAtIndex:[indexPath row]] address]];
        [[startPage go] setBackgroundImage:[UIImage imageNamed:@"UseThisAddress.png"] forState:UIControlStateNormal];
        
    }
    //Recents
    else
    {
        //Recent Addresses
        if([indexPath section] == 0)
        {
            [[startPage locationTextField] setText:(NSString *)[[recentAddresses objectAtIndex:[indexPath row]] address]];
            [[startPage go] setBackgroundImage:[UIImage imageNamed:@"UseThisAddress.png"] forState:UIControlStateNormal];
        }
        //Recent Searches
        else
        {
            [[startPage searchTextField] setText:[[recentSearches objectAtIndex:[indexPath row]] name]];
        }
    }
    
    [startPage release];
    [[self navigationController] popViewControllerAnimated:YES];
}

-(IBAction)segmentedControlIndexChanged
{
    //NSLog(@"Table changed");
    
    if([segmentedControl selectedSegmentIndex] == 0)
    {
        [self setTitle:@"Favorites"];
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
        [[[self toolbarItems] objectAtIndex:4] setEnabled:NO];
    }
    else
    {
        [self setTitle:@"Recent"];
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
        [[[self toolbarItems] objectAtIndex:4] setEnabled:YES];
        
    }
    
    [[self tableView] reloadData];
}

-(IBAction)addFavoriteAddress:(id)sender
{
    FavoriteAddViewController *favoriteAddViewController = [[FavoriteAddViewController alloc] init];    
    [favoriteAddViewController setDelegate:self];
    
    FavoriteAddress *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteAddress" inManagedObjectContext:[self managedObjectContext]];
    [favoriteAddViewController setFavorite:favorite];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:favoriteAddViewController];
    [[nav navigationBar] setTintColor:[UIColor colorWithRed:26/255.0f green:96/255.0f blue:156/255.0f alpha:1.0]];
    [[self navigationController] presentModalViewController:nav animated:YES];
    [favoriteAddViewController release];
    [nav release];
}

-(IBAction)edit:(id)sender
{
    UIBarButtonItem *editButton = [[self toolbarItems] objectAtIndex:0];
    if(![[self tableView] isEditing])
    {
        [editButton setTitle:@"Done"];
        [editButton setStyle:UIBarButtonItemStyleDone];
        [[self tableView] setEditing:YES];
    }
    else
    {
        [editButton setTitle:@"Edit"];
        [editButton setStyle:UIBarButtonItemStyleBordered];
        [[self tableView] setEditing:NO];
    }
}

-(IBAction)clear:(id)sender
{
    UIActionSheet *clear = [[UIActionSheet alloc] initWithTitle:@"Are you sure?" 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                         destructiveButtonTitle:@"Clear All" 
                                              otherButtonTitles:nil, nil];
    [clear setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [clear showFromToolbar:[[self navigationController] toolbar]];
    [clear release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSError *error;
    
    if(buttonIndex == [actionSheet destructiveButtonIndex])
    {
        for(RecentSearch *search in recentSearches)
        {
            [managedObjectContext deleteObject:search];
        }
        for(RecentAddress *address in recentAddresses)
        {
            [managedObjectContext deleteObject:address];
        }
        
        if(![managedObjectContext save:&error])
        {
            NSLog(@"Objects not deleted. Error: %@", [error description]);
        }
        else
        {
            NSLog(@"Objects deleted.");
        }
        
        [self getData];
        [[self tableView] reloadData];
    }
    else
    {
        return;
    }
}

- (void)favoriteAddViewController:(FavoriteAddViewController *)favoriteAddViewController didAddFavorite:(FavoriteAddress *)favoriteAddress
{
    [self dismissModalViewControllerAnimated:YES];
    [self getData];
    [[self tableView] reloadData];
}

#pragma mark -
#pragma mark Fetched results controller

-(NSFetchedResultsController *)favoritesFetchedResultsController
{
    //NSLog(@"Favorites Fetched Results Controller called");
    if(favoritesFetchedResultsController == nil)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FavoriteAddress" inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"FavoritesCache"];
        
        [aFetchedResultsController setDelegate:self];
        [self setFavoritesFetchedResultsController:aFetchedResultsController];
        
        [aFetchedResultsController release];
        [request release];
        
    }
    
    return favoritesFetchedResultsController;
}

-(NSFetchedResultsController *)recentAddressFetchedResultsController
{
    //NSLog(@"Recent Address Fetched Results Controller called");
    
    if(recentAddressFetchedResultsController == nil)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecentAddress" inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"RecentAddressCache"];
        [aFetchedResultsController setDelegate:self];
        [self setRecentAddressFetchedResultsController:aFetchedResultsController];
        
        [aFetchedResultsController release];
        [request release];
    }
    
    return recentAddressFetchedResultsController;
}

-(NSFetchedResultsController *)recentSearchFetchedResultsController
{
    //NSLog(@"Recent Search Fetched Results Controller Called");
    
    if(recentSearchFetchedResultsController == nil)
    {
        NSFetchRequest *request =[[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecentSearch" inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"RecentSearchCache"];
        [aFetchedResultsController setDelegate:self];
        [self setRecentSearchFetchedResultsController:aFetchedResultsController];
        
        [aFetchedResultsController release];
        [request release];
    }
    
    return recentSearchFetchedResultsController;
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = [self tableView];
    //NSLog(@"DidChangeObject atIndexPath forChangeType newIndexPath called");
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        case NSFetchedResultsChangeUpdate:
            [tableView cellForRowAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        default:
            break;
    }
}


-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    //NSLog(@"DidChangeSection atIndex forChangeType called");
    switch(type) {
		case NSFetchedResultsChangeInsert:
			[[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

@end
