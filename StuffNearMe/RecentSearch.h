//
//  RecentSearch.h
//  StuffNearMe
//
//  Created by Mason Silber on 8/14/11.
//  Copyright (c) 2011 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecentSearch : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;

@end
