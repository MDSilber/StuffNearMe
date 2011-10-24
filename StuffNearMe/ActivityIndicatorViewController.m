//
//  ActivityIndicatorViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 10/20/11.
//  Copyright (c) 2011 Columbia University. All rights reserved.
//

#import "ActivityIndicatorViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ActivityIndicatorViewController
@synthesize spinner;

-(void)dealloc
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [spinner release];
    spinner = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self view] setBackgroundColor:[UIColor blackColor]];
        [[self view] setAlpha:0.8];
        [[self view] setFrame:CGRectMake(85, 100, 150, 150)];
        [[[self view] layer] setCornerRadius:12.0];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinner setFrame:CGRectMake(50, 25, 50, 50)];
        [[self view] addSubview:spinner];
        
        UILabel *loadingLabel = [[UILabel alloc] init];
        [loadingLabel setText:@"Loading..."];
        [loadingLabel setFrame:CGRectMake(25, 85, 100, 20)];
        [[self view] addSubview:loadingLabel];
        [loadingLabel setBackgroundColor:[UIColor clearColor]];
        [loadingLabel setTextColor:[UIColor whiteColor]];
        [loadingLabel setTextAlignment:UITextAlignmentCenter];
        [loadingLabel release];
        
        [spinner performSelectorInBackground:@selector(startAnimating) withObject:nil];
    }
    return self;
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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

@end
