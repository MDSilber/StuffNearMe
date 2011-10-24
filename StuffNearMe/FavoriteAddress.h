//
//  FavoriteAddress.h
//  StuffNearMe
//
//  Created by Mason Silber on 8/15/11.
//  Copyright (c) 2011 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavoriteAddress : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * index;

@end
