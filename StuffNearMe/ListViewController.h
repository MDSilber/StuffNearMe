//
//  ListViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 7/16/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSIndexPath *lastIndexPath;
    NSArray *placesList;
    NSString *typeSelected;
    int selectedPlaceIndex;
}

@property (nonatomic, retain) NSArray *placesList;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property (nonatomic, retain) NSString *typeSelected;
@property (nonatomic, readonly) int selectedPlaceIndex;

@end
