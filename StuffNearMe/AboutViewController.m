//
//  AboutViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 7/22/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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
    [[self view] setBackgroundColor:[UIColor underPageBackgroundColor]];
    emailMe = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonRect = CGRectMake(25, 320, 270, 51);
    UIImage *emailMeImage = [UIImage imageNamed:@"EmailMe.png"];
    
    [emailMe setFrame:buttonRect];
    [emailMe setBackgroundImage:emailMeImage forState:UIControlStateNormal];
    [emailMe setUserInteractionEnabled:YES];
    [emailMe addTarget:self action:@selector(promptEmail:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:emailMe];
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

-(IBAction)promptEmail:(id)sender
{
    Class mailClass = NSClassFromString(@"MFMailComposeViewController");
    
    if(mailClass != nil)
    {
        if([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}

-(void)displayComposerSheet
{
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    [mail setMailComposeDelegate:self];
    
    [mail setSubject:@"Suggestions about StuffNearMe"];
     
    [mail setToRecipients:[NSArray arrayWithObjects:@"StuffNearMeSuggestions@gmail.com", nil]];
    [self presentModalViewController:mail animated:YES];
    [mail release];
}

-(void)launchMailAppOnDevice
{
    NSString *recepient = [NSString stringWithFormat:@"mailto:MDSilber1@gmail.com"];
    recepient = [recepient stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:recepient]];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
