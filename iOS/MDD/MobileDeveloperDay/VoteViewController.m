//
//  VoteViewController.m
//  MobileDeveloperDay
//
//  Created by Christine Abernathy on 10/29/13.
//
//

#import "VoteViewController.h"

@interface VoteViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableArray *voteSelections;
@end

@implementation VoteViewController

- (id)initWithContest:(PFObject *)contest {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.selectedContest = contest;
        // This table displays items in the Entry class
        self.parseClassName = @"Entry";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        [self tableView].allowsMultipleSelection = YES;
        self.voteSelections = [@[] mutableCopy];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setTitle:@"Vote"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"contest" equalTo:self.selectedContest];
    
    // Can't vote for oneself?
    //[query whereKey:@"enteredBy" notEqualTo:[PFUser currentUser]];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    static NSString *cellIdentifier = @"Cell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell to show entry info
    PFUser *enteredBy = object[@"enteredBy"];
    [enteredBy fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        cell.textLabel.text = enteredBy[@"displayName"];
    }];
    
    PFFile *thumbnail = object[@"image"];
    cell.imageView.file = thumbnail;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    PFObject *selectedEntry = [self objects][indexPath.row];
    [self.voteSelections addObject:selectedEntry];
    [self saveButton:YES];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    PFObject *selectedEntry = [self objects][indexPath.row];
    [self.voteSelections removeObject:selectedEntry];
    if ([self.voteSelections count] ==0) {
        [self saveButton:NO];
    }
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // Go back to the root view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) saveButton:(BOOL)show
{
    if (show) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Save"
                                                  style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(saveVotes)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) saveVotes
{
    for (PFObject *entry in self.voteSelections) {
        // Increment by 5
        [entry incrementKey:@"score" byAmount:[NSNumber numberWithInt:5]];
    }
    [PFObject saveAllInBackground:self.voteSelections block:^(BOOL succeeded, NSError *error) {
        if (error) {
            // Notify the user of the error
            NSLog(@"Error saving new entry info: %@", error.localizedDescription);
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Could not save data"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
        } else {
            // Notify the user of the success
            [[[UIAlertView alloc] initWithTitle:@"Success"
                                        message:@"Votes saved"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
        }
    }];
}

@end
