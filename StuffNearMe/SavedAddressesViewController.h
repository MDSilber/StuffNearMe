//
//  SavedAddressesViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 8/4/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FavoriteAddress.h"
#import "RecentAddress.h"
#import "RecentSearch.h"
#import "StuffNearMeAppDelegate.h"
#import "FavoriteAddViewController.h"
#import "StartPageViewController.h"

@class FavoriteAddress;
@class RecentAddress;
@class RecentSearch;


@interface SavedAddressesViewController : UITableViewController <FavoriteAddDelegate,UIActionSheetDelegate,NSFetchedResultsControllerDelegate>
{
    NSMutableArray *favorites;
    NSMutableArray *recentAddresses;
    NSMutableArray *recentSearches;
    UIBarButtonItem *segmentedControlButton;
    
    IBOutlet UISegmentedControl *segmentedControl;
    NSFetchedResultsController *favoritesFetchedResultsController;
    NSFetchedResultsController *recentAddressFetchedResultsController;
    NSFetchedResultsController *recentSearchFetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    int numberOfRecentAddresses;
    int numberOfRecentSearches;
    NSDateFormatter *formatter;
}

@property (nonatomic, retain) NSMutableArray *favorites;
@property (nonatomic, retain) NSMutableArray *recentAddresses;
@property (nonatomic, retain) NSMutableArray *recentSearches;
@property (nonatomic, retain) NSFetchedResultsController *favoritesFetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *recentAddressFetchedResultsController, *recentSearchFetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(IBAction)segmentedControlIndexChanged;
-(IBAction)addFavoriteAddress:(id)sender;
-(IBAction)clear:(id)sender;
-(IBAction)edit:(id)sender;
-(void)editFavoriteAddress:(FavoriteAddress *)favorite;
-(void)enableEdit;

- (void)favoriteAddViewController:(FavoriteAddViewController *)favoriteAddViewController didAddFavorite:(FavoriteAddress *)favoriteAddress;
-(void)getData;

@end
