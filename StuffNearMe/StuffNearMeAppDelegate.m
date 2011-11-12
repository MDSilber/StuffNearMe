//
//  StuffNearMeAppDelegate.m
//  StuffNearMe
//
//  Created by Mason Silber on 8/1/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "StuffNearMeAppDelegate.h"
#import "StartPageViewController.h"

@implementation StuffNearMeAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize tempPlace;
@synthesize placesList, googlePlacesList;

-(void)dealloc
{
    [placesList release];
    [googlePlacesList release];
    [navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    placesList = [[NSArray alloc] initWithObjects:
                                @"Airports", //airport
                                @"ATMs", //atm 
                                @"Bakeries", //bakery
                                @"Banks", //bank
                                @"Bars", //bar
                                @"Book Stores", //book_store
                                @"Bus Stations", //bus_station
                                @"Cafes", //cafe
                                @"Car Repair", //car_repair
                                @"Churches", //church 
                                @"Convenience Stores", //convenience_store
                                @"Department Stores", //department_store (same as shopping malls)
                                @"Doctors", //doctor
                                @"Fire Stations", //fire_station
                                @"Florists", //florist
                                @"Gas Stations", //gas_station 
                                @"Gyms", //gym 
                                @"Hospitals", //hospital
                                @"Laundromats", //laundry
                                @"Libraries", //library (same as book store)
                                @"Liquor Stores", //liquor_store
                                @"Lodging", //lodging 
                                @"Mosques", //mosque 
                                @"Movie Theaters", //movie_theater
                                @"Museums", //museum
                                @"Parking", //parking 
                                @"Parks", //park *
                                @"Pharmacies", //pharmacy
                                @"Police Stations", //police
                                @"Post Offices", //post_office
                                @"Restaurants", //restaurant
                                @"Schools", //school
                                @"Shopping Malls", //shopping_mall 
                                @"Subway Stations", //subway_station (same as train stations)
                                @"Supermarkets", //grocery_or_supermarket 
                                @"Synagogues", //synagogue
                                @"Taxi Stands", //taxi_stand
                                @"Train Stations", //train_station 
                                @"Universities", //university
                                nil];
    googlePlacesList = [[NSArray alloc] initWithObjects:
                        @"airport",
                        @"atm",
                        @"bakery",
                        @"bank",
                        @"bar",
                        @"book_store",
                        @"bus_station",
                        @"cafe",
                        @"car_repair",
                        @"church",
                        @"convenience_store", 
                        @"department_store",
                        @"doctor",
                        @"fire_station",
                        @"florist",
                        @"gas_station",
                        @"gym", 
                        @"hospital",
                        @"laundry",
                        @"library",
                        @"liquor_store",
                        @"lodging",
                        @"mosque",
                        @"movie_theater",
                        @"museum",
                        @"parking",
                        @"park",
                        @"pharmacy",
                        @"police",
                        @"post_office",
                        @"restaurant",
                        @"school",
                        @"shopping_mall",
                        @"subway_station",
                        @"grocery_or_supermarket",
                        @"synagogue",
                        @"taxi_stand",
                        @"train_station",
                        @"university",
                        nil];
    
    StartPageViewController *firstViewController = [[StartPageViewController alloc] initWithNibName:@"StartPageViewController" bundle:[NSBundle mainBundle]];
    [firstViewController setTitle:@"Stuff Near Me"];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    // Override point for customization after application launch.
    [firstViewController release];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    [[self window] addSubview:navigationController.view];
    [[self window] makeKeyAndVisible];
    tempPlace = -1;

    tempPlace = -1;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"defaultMapType"])  {
        
        NSString  *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString  *settingsPropertyListPath = [mainBundlePath
                                               stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
        
        NSDictionary *settingsPropertyList = [NSDictionary 
                                              dictionaryWithContentsOfFile:settingsPropertyListPath];
        
        NSMutableArray      *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
        NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < [preferenceArray count]; i++)  { 
            NSString  *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];
            
            if (key)  {
                id  value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
                [registerableDictionary setObject:value forKey:key];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:registerableDictionary]; 
        [[NSUserDefaults standardUserDefaults] synchronize]; 
    } 
    
    return YES;
}

+(BOOL)connectedToInternet
{
    Reachability *internetTester = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [internetTester currentReachabilityStatus];
    
    return internetStatus != NotReachable;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[(StartPageViewController *)[[navigationController viewControllers] objectAtIndex:0] locationManager] stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [[(StartPageViewController *)[[navigationController viewControllers] objectAtIndex:0] locationManager] startUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StuffNearMe" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"StuffNearMe.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
