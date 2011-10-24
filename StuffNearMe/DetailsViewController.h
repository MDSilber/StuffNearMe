//
//  DetailsViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 7/24/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Place.h"
#import "MapPin.h"

@interface DetailsViewController : UIViewController <UIActionSheetDelegate,MKMapViewDelegate>
{
    Place *place;
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *infoButton;
    UIButton *call;
    NSString *transportType;
    NSString *phoneNumber;
    NSString *zipCode;
    MKMapView *placeView;
    MKCoordinateRegion region;
}

-(id)initWithPlace:(Place *)aPlace andPhoneNumber:(NSString *)aPhoneNumber andZipCode:(NSString *)aZipCode;
-(IBAction)getDirections:(id)sender;
-(IBAction)makeCall:(id)sender;
-(void)createMapView;
@end
