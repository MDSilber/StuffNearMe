//
//  DetailsViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 7/24/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "DetailsViewController.h"

#define DetailsURLOne @"https://maps.googleapis.com/maps/api/place/details/json?reference="
#define DetailsURLTwo @"&sensor=false&key=AIzaSyB82DFAyuV8aeLaQ3ubJ-ZYsy6gC6HuX0o"

@interface NSString (Helpers)

- (NSString*)stringByRemovingCharactersInSet:(NSCharacterSet*)set;

@end

@implementation NSString (Helpers)

- (NSString*)stringByRemovingCharactersInSet:(NSCharacterSet*)set
{
    NSArray* components = [self componentsSeparatedByCharactersInSet:set];
    return [components componentsJoinedByString:@""];
}

@end

@implementation DetailsViewController


-(id)initWithPlace:(Place *)aPlace andPhoneNumber:(NSString *)aPhoneNumber andZipCode:(NSString *)aZipCode
{
    self = [super init];
    if (self) {
        place = aPlace; 
        phoneNumber = aPhoneNumber;
        zipCode = aZipCode;
    }
    return self;
}

//-(void)parseJSON
//{
//    NSURL *detailsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",DetailsURLOne,[place reference],DetailsURLTwo]];
//    
//    SBJsonParser *parser = [[SBJsonParser alloc] init];
//    NSString *JSON = [[[NSString alloc] initWithContentsOfURL:detailsURL encoding:NSUTF8StringEncoding error:nil] autorelease];
//    NSDictionary *result = [[parser objectWithString:JSON error:nil] objectForKey:@"result"];
//    
//    phoneNumber = [[result objectForKey:@"formatted_phone_number"] retain];
//    zipCode = [[[[result objectForKey:@"address_components"] lastObject] objectForKey:@"long_name"] substringToIndex:5];
//    [parser release];
//}

-(void)dealloc
{
    [call release];
    [phoneNumber release];
    [imageView release];    
    NSLog(@"%@ dealloc called",[self class]);
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{   
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[place type]]]];
  
    if(![imageView image])
    {
        NSLog(@"Image not available.");
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImageNotAvailable.jpg b"]];
    }
    
    [imageView setFrame:CGRectMake(10, 10, 138, 138)];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setBackgroundColor:[UIColor underPageBackgroundColor]];//[UIColor colorWithRed:158/255.0f green:158/255.0f blue:158/255.0f alpha:1.0];
    [imageView setClipsToBounds:NO];
    
    [[imageView layer] setMasksToBounds:YES];
    [[imageView layer] setCornerRadius:12.0f];
    [[imageView layer] setBorderColor:[[UIColor scrollViewTexturedBackgroundColor] CGColor]];
    [[imageView layer] setBorderWidth:2.0];
    [[imageView layer] setShadowColor:[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor]];
    [[imageView layer] setShadowOffset:CGSizeMake(-3.0, 3.0)];
    [[imageView layer] setShadowRadius:2.0];
    [[imageView layer] setShadowOpacity:1.0];
    
    [[self view] addSubview:imageView];
    
    UIBarButtonItem *getDirections = [[UIBarButtonItem alloc] initWithTitle:@"Get Directions" style:UIBarButtonItemStyleBordered target:self action:@selector(getDirections:)];
    
    call = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];

    //Check to see if the phone number is null
    NSLog(@"%@",phoneNumber);
    
    if(phoneNumber)
    {
        [call addTarget:self action:@selector(makeCall:) forControlEvents:UIControlEventTouchUpInside];
        [call setFrame:CGRectMake(32, 292, 256, 37)];
        [call setTitle:[NSString stringWithFormat:@"Call: %@",phoneNumber] forState:UIControlStateNormal];
        [[self view] addSubview:call];
    }
    else
    {
        UIButton *noPhoneNumber = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [noPhoneNumber setFrame:CGRectMake(32, 292, 256, 37)];
        [noPhoneNumber setTitle:@"No phone number available" forState:UIControlStateNormal];
        [noPhoneNumber setEnabled:NO];
        [[self view] addSubview:noPhoneNumber];
    }
        
    UIColor *color = [UIColor colorWithRed:26/255.0f green:96/255.0f blue:156/255.0f alpha:1.0];
    [[[self navigationController] toolbar] setTintColor:color];
    NSArray *items = [NSArray arrayWithObjects:getDirections, nil];
    
    [[self navigationController] setToolbarHidden:NO animated:YES];
    [self setToolbarItems:items];
    
    [getDirections release];

    NSArray *addressParts = [[place address] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    
    NSRange range;
    range = [[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:[[NSString stringWithFormat:@"iphone"] lowercaseString]];
    
    [[infoButton titleLabel] setLineBreakMode:UILineBreakModeWordWrap];
    [infoButton setEnabled:NO];
    if(range.location != NSNotFound)
    {
        [[infoButton titleLabel] setNumberOfLines:4];
        [infoButton setTitle:[NSString stringWithFormat:@"%@\n%@\n%@\n%@",[place name], [addressParts objectAtIndex:0],[[addressParts objectAtIndex:1]substringFromIndex:1],zipCode] forState:UIControlStateNormal];
        [call setHidden:NO];
    }
    else
    {
        [[infoButton titleLabel] setNumberOfLines:5];
        [infoButton setTitle:[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",[place name], [addressParts objectAtIndex:0],[[addressParts objectAtIndex:1]substringFromIndex:1],zipCode, phoneNumber] forState:UIControlStateNormal];
        [call setHidden:YES];
    }
        
    region.span.longitudeDelta = 0.002;
    region.span.latitudeDelta = 0.002;
    region.center.latitude = [place latitude];
    region.center.longitude = [place longitude];
    
    [self performSelectorOnMainThread:@selector(createMapView) withObject:nil waitUntilDone:NO];
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void)createMapView
{
    MapPin *placePin = [[MapPin alloc] initWithPlace:place];
    placeView = [[MKMapView alloc] initWithFrame:CGRectMake(172, 10, 138, 138)];
    [placeView setRegion:region];
    
    [[placeView layer] setCornerRadius:12.0f];
    [placeView setDelegate:self];
    [placeView setScrollEnabled:NO];
    [placeView setZoomEnabled:NO];
    [placeView addAnnotation:placePin];
    [placePin release];
    [[self view] addSubview:placeView];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //NSLog(@"Delegate method called");
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    [pinView setAnnotation:annotation];
    [pinView setPinColor:MKPinAnnotationColorRed];
    [pinView setCanShowCallout:NO];
    [pinView setAnimatesDrop:NO];
    return pinView;
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)getDirections:(id)sender
{
    UIActionSheet *options = [[UIActionSheet alloc] initWithTitle:@"Choose Transportation Method" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Driving", @"Walking", @"Biking",@"Public Transportation", nil];
    
    [options setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [options showFromToolbar:[[self navigationController]toolbar]];
    [options release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        transportType = @"&dirflg=w";
    }
    else if(buttonIndex == 2)
    {
        transportType = @"&dirflg=b";
    }
    else if(buttonIndex == 3)
    {
        transportType = @"&dirflg=r";
    }
    
    else
    {
        transportType = @"";
        
        if(buttonIndex == [actionSheet cancelButtonIndex])
        {
            return;
        }
    }
    
    NSString *URL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f%@",[[place startLocation] coordinate].latitude,[[place startLocation] coordinate].longitude,[place latitude],[place longitude],transportType];
    //NSLog(@"%@",URL);
    NSURL *directions = [NSURL URLWithString:URL];
    
    [[UIApplication sharedApplication] openURL:directions];
    
    //NSLog(@"Transportation type: %@",transportType);
    return;
}

-(IBAction)makeCall:(id)sender
{
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneNumber = [@"tel://" stringByAppendingString:phoneNumber];
    
    //NSLog(@"Phone number: %@",phoneNumber);

    NSURL *makeCall = [NSURL URLWithString:phoneNumber];
    [[UIApplication sharedApplication] openURL:makeCall];
}

@end
