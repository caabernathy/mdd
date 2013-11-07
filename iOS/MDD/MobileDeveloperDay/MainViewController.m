#import "MainViewController.h"
#import <Parse/Parse.h>
#import "AddEntryViewController.h"
#import "VoteViewController.h"

// DEMO-STEP 2: Add User Management
@interface MainViewController ()
<PFLogInViewControllerDelegate>

// DEMO-STEP 2: Add User Management
@property (strong, nonatomic) PFLogInViewController *loginViewController;

// DEMO-STEP 3: Query contest data
@property (strong, nonatomic) PFObject *currentContest;

@property (weak, nonatomic) IBOutlet UILabel *contestDetails;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // DEMO-STEP 2: Add User Management
        // Create login view controller
        self.loginViewController = [[PFLogInViewController alloc] init];
        [self.loginViewController setDelegate:self];
        [self.loginViewController setFields:
         //PFLogInFieldsUsernameAndPassword |
         //PFLogInFieldsLogInButton |
         //PFLogInFieldsSignUpButton |
         //PFLogInFieldsTwitter |
         PFLogInFieldsFacebook
         ];
        [self.loginViewController setFacebookPermissions:@[@"email"]];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Photo Contest"];
}

// DEMO-STEP 3: Query contest data
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Load the contest data
    [self readContestData];
}

// DEMO-STEP 2: Add User Management
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Show log out button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Logout"
                                              style:UIBarButtonItemStyleDone
                                              target:self
                                              action:@selector(logout)];
    
    // Show the login view controller if necessary
    if (![PFUser currentUser]) {
        [self presentViewController:self.loginViewController animated:NO completion:nil];
    }
}

// DEMO-STEP 2: Add User Management
#pragma mark - PFLoginViewControllerDelegate
-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {    
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![user isNew]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    // Get user's personal information
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
        if (!error) {
            // Set user's information
            // For contest entry display
            if (user[@"name"]) {
                [PFUser currentUser][@"displayName"] = user[@"name"];
            }
            // For optionally showing the user's profile view
            if (user.id && user.id != 0) {
                [PFUser currentUser][@"facebookId"] = user[@"id"];
            }
            // For re-engagement
            if (user[@"email"]) {
                [PFUser currentUser][@"email"] = user[@"email"];
            }
            // For analytics
            if (user[@"locale"]) {
                [PFUser currentUser][@"country"] = user[@"locale"];
            }
            // Save the user's info on Parse
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        } else {
            NSLog(@"Error getting user info");
        }
    }];
}

// DEMO-STEP 3: Query contest data
- (void) readContestData
{
    // Load the challenges
    PFQuery *query = [PFQuery queryWithClassName:@"Contest"];
    [query selectKeys:@[@"title"]];
    [query whereKey:@"active" equalTo:@YES];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            self.currentContest = result;
            self.contestDetails.text = self.currentContest[@"title"];
        }
    }];
}

- (IBAction)addEntryPressed:(id)sender {
    // DEMO-STEP 4: Add contest entry
    AddEntryViewController *addEntryViewController = [[AddEntryViewController alloc]
                                  initWithContest:self.currentContest];
    [self.navigationController pushViewController:addEntryViewController animated:YES];
}

- (IBAction)votePressed:(id)sender {
    // DEMO-STEP 5: View contest entry info
    VoteViewController *voteViewController = [[VoteViewController alloc]
                                                      initWithContest:self.currentContest];
    [self.navigationController pushViewController:voteViewController animated:YES];
}

// DEMO-STEP 2: Add User Management
- (void) logout
{
    [PFUser logOut];
    [self presentViewController:self.loginViewController animated:NO completion:nil];
}

@end
