#import "MainViewController.h"
#import <Parse/Parse.h>
#import "AddEntryViewController.h"
#import "VoteViewController.h"

// 2. TO-DO: Add PFLoginViewController
@interface MainViewController ()
<PFLogInViewControllerDelegate>

@property (strong, nonatomic) PFLogInViewController *loginViewController;
@property (strong, nonatomic) PFObject *currentContest;
@property (weak, nonatomic) IBOutlet UILabel *contestDetails;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // 2. TO-DO: Add PFLoginViewController
        // Create login view controller
        self.loginViewController = [[PFLogInViewController alloc] init];
        [self.loginViewController setDelegate:self];
        [self.loginViewController setFields:
         //PFLogInFieldsUsernameAndPassword |
         //PFLogInFieldsLogInButton |
         //PFLogInFieldsSignUpButton |
         PFLogInFieldsFacebook
         //PFLogInFieldsTwitter
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Load the contest data
    [self readContestData];
}

// 2. TO-DO: Add PFLoginViewController
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

// 2. TO-DO: Add PFLoginViewController
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
            if (user[@"name"]) {
                [PFUser currentUser][@"displayName"] = user[@"name"];
            }
            if (user.id && user.id != 0) {
                [PFUser currentUser][@"facebookId"] = user[@"id"];
                //self.profilePictureView.profileID = user[@"id"];
            }
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        } else {
            NSLog(@"Error getting user info");
        }
    }];
}

// 3. TO-DO: Add contest entry
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

// 3. TO-DO: Add contest entry
- (IBAction)addEntryPressed:(id)sender {
    AddEntryViewController *addEntryViewController = [[AddEntryViewController alloc]
                                  initWithContest:self.currentContest];
    [self.navigationController pushViewController:addEntryViewController animated:YES];
}

// 4. TO-DO: Add voting flow
- (IBAction)votePressed:(id)sender {
    VoteViewController *voteViewController = [[VoteViewController alloc]
                                                      initWithContest:self.currentContest];
    [self.navigationController pushViewController:voteViewController animated:YES];
}

- (void) logout
{
    [PFUser logOut];
    [self presentViewController:self.loginViewController animated:NO completion:nil];
}

@end
