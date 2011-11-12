//
//  FavoriteAddViewController.h
//  StuffNearMe
//
//  Created by Mason Silber on 8/4/11.
//  Copyright 2011 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoriteAddress;
@protocol FavoriteAddDelegate;

@interface FavoriteAddViewController : UIViewController <UITextFieldDelegate>
{
    @private
        UITextField *nameTextField;
        UITextField *addressTextField;
        FavoriteAddress *favorite;
        id <FavoriteAddDelegate> delegate;
@public BOOL editing;
}

@property (nonatomic, retain) FavoriteAddress *favorite;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *addressTextField;
@property (nonatomic, assign) id <FavoriteAddDelegate> delegate;

-(void)save;
-(void)cancel;
-(id)initWithFavoriteToEdit:(FavoriteAddress *)aFavorite;

@end

@protocol FavoriteAddDelegate <NSObject> 
-(void)favoriteAddViewController: (FavoriteAddViewController *)favoriteAddViewController didAddFavorite:(FavoriteAddress *)favoriteAddress;
@end