//
//  RecentAddress.h
//  StuffNearMe
//
//  Created by Mason Silber on 8/1/11.
//  Copyright (c) 2011 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecentAddress : NSManagedObject {
@private
}

//+(RecentAddress *)recentAddressToDatabaseWithAddress:(NSString *)recentAddress inManagedObjectContext:(NSManagedObjectContext *)context;

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * address;


@end
