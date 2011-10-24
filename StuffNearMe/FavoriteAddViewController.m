//
//  FavoriteAddViewController.m
//  StuffNearMe
//
//  Created by Mason Silber on 8/4/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import "FavoriteAddViewController.h"
#import "FavoriteAddress.h"

@implementation FavoriteAddViewController

@synthesize nameTextField,addressTextField,delegate,favorite;

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
    [[self navigationItem] setTitle:@"Add Favorite"];
    [self setDelegate:delegate];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    [[self navigationItem ] setLeftBarButtonItem:cancelButton];
    [cancelButton release];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle: @"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(save)];
    [[self navigationItem] setRightBarButtonItem:saveButton];
    [saveButton release];
    
    [nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [addressTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    
    [nameTextField becomeFirstResponder];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setAddressTextField:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    if(textField == nameTextField)
    {
        [addressTextField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)save
{
    [favorite setName:[nameTextField text]];
    [favorite setAddress:[addressTextField text]];
                                                                                                                        
    NSManagedObjectContext *context = [favorite managedObjectContext];

    //Add it to database
    
    NSError *error = nil;
    
    if(![context save:&error])
    {
        NSLog(@"Not saved.");
    }
    else
    {
        NSLog(@"Saved");
    }
    
    [[self delegate] favoriteAddViewController:self didAddFavorite:favorite];
}

-(void)cancel
{
    //NSLog(@"Cancel called");
    [[favorite managedObjectContext] deleteObject:favorite];
    
    [[self delegate] favoriteAddViewController:self didAddFavorite:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    //NSLog(@"%@ dealloc called",[self class]);

    [nameTextField release];
    [addressTextField release];
    [favorite release];
    
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated
{

}

@end
