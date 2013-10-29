//
//  AddEntryViewController.m
//  MobileDeveloperDay
//
//  Created by Christine Abernathy on 10/29/13.
//
//

#import "AddEntryViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface AddEntryViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *savingEntryView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation AddEntryViewController

- (id)initWithContest:(PFObject *)contest {
    self = [self initWithNibName:@"AddEntryViewController" bundle:nil];
    if (self) {
        self.selectedContest = contest;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"Add Entry"];
    
    self.imageView.image = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.savingEntryView.hidden = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveEntry
{
    // Show progress info
    self.savingEntryView.hidden = NO;
    [self.progressView setProgress:0.0];
    
    // Resize the image
    UIImage *resizedImage = [self.imageView.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    // Get the data representaion of the image
    NSData *imageData = UIImagePNGRepresentation(resizedImage);
    PFFile *imageFile = [PFFile fileWithName:@"entry.png" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // Hide progress info
        self.savingEntryView.hidden = YES;
        if (error) {
            NSLog(@"Error saving new photo: %@", error.localizedDescription);
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Could not save data"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
        } else {
            PFObject *entry = [PFObject objectWithClassName:@"Entry"];
            entry[@"contest"] = self.selectedContest;
            entry[@"enteredBy"] = [PFUser currentUser];
            entry[@"image"] = imageFile;
            [entry saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
                                                message:@"Entry saved"
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil]
                     show];
                }
            }];
        }
    } progressBlock:^(int percentDone) {
        // Update progress info
        [self.progressView setProgress:(percentDone / 100.0)];
    }];
}

- (void) showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) saveButton:(BOOL)show
{
    if (show) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Save"
                                                  style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(saveEntry)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (IBAction)addPhotoPressed:(id)sender {
    if(TARGET_IPHONE_SIMULATOR){
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Camera", @"Photo Library", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // If user presses cancel, do nothing
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if (buttonIndex == 0) {
        [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
    } else if (buttonIndex == 1) {
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    [self saveButton:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // Go back to the root view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
