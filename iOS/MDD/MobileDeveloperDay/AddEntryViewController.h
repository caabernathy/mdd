//
//  AddEntryViewController.h
//  MobileDeveloperDay
//
//  Created by Christine Abernathy on 10/29/13.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddEntryViewController : UIViewController

@property (strong, nonatomic) PFObject *selectedContest;

- (id)initWithContest:(PFObject *)contest;

@end
