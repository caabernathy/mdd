//
//  VoteViewController.h
//  MobileDeveloperDay
//
//  Created by Christine Abernathy on 10/29/13.
//
//

// DEMO-STEP 5: View contest entry info

#import <Parse/Parse.h>

@interface VoteViewController : PFQueryTableViewController

@property (strong, nonatomic) PFObject *selectedContest;

- (id)initWithContest:(PFObject *)contest;

@end
