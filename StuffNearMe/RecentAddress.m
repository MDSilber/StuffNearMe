//
//  RecentAddress.m
//  StuffNearMe
//
//  Created by Mason Silber on 8/1/11.
//  Copyright (c) 2011 Columbia University. All rights reserved.
//

#import "RecentAddress.h"


@implementation RecentAddress

//+(RecentAddress *)recentAddressToDatabaseWithAddress:(NSString *)recentAddress inManagedObjectContext:(NSManagedObjectContext *)context
//{
//    RecentAddress *recent = nil;
//    //    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    //    request.entity = [NSEntityDescription entityForName:@"FavoriteAddress" inManagedObjectContext:context];
//    //    request.predicate = [NSPredicate predicateWithFormat:@"Name = %@",[recent Name]];
//    //    
//    //    NSError *error = nil;
//    //    recent = [[context executeFetchRequest:request error:&error] lastObject];
//    //    
//    //    if(!error && recent == nil)
//    //    {
//    
//    recent = [NSEntityDescription insertNewObjectForEntityForName:@"RecentAddress" inManagedObjectContext:context];
//    recent.date = [NSDate date];
//    recent.address = recentAddress;
//    //    }
//    
//    return recent;
//}

@dynamic date;
@dynamic address;

@end
