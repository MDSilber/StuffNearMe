//
//  AboutViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 7/22/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    IBOutlet UIButton *emailMe;
}

-(IBAction)promptEmail:(id)sender;
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;

@end
