//
//  AddEntryViewController.h
//  MobileDeveloperDay
//
//  Created by Christine Abernathy on 10/29/13.
//
//

#import <UIKit/UIKit.h>

// DEMO-STEP 4: Add contest entry
#import <Parse/Parse.h>

@interface AddEntryViewController : UIViewController

// DEMO-STEP 4: Add contest entry
@property (strong, nonatomic) PFObject *selectedContest;
- (id)initWithContest:(PFObject *)contest;

@end
