//
//  ActivityIndicatorViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 10/20/11.
//  Copyright (c) 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityIndicatorViewController : UIViewController
{
    UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@end
