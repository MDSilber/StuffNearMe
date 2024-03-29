//
//  StuffNearMeAppDelegate.h
//  StuffNearMe
//
//  Created by Mason Silber on 8/1/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface StuffNearMeAppDelegate : UIResponder <UIApplicationDelegate>
{
    int tempPlace;
    UINavigationController *navigationController;
    NSArray *placesList;
    NSArray *googlePlacesList;
}

@property (strong, nonatomic) UIWindow *window;
@property int tempPlace;
@property (readonly, nonatomic) NSArray *placesList;
@property (readonly, nonatomic) NSArray *googlePlacesList;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+(BOOL)connectedToInternet;

@end
