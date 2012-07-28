//
//  PAPFilterPhotoViewController.m
//  Anypic
//
//  Created by James Urquhart on 27/07/2012.
//
//

#import "PAPFilterPhotoViewController.h"
#import "PAPEditPhotoViewController.h"
#import "PAPPhotoDetailsFooterView.h"
#import "FailterButton.h"
#import "Failter.h"

@interface PAPFilterPhotoViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *processedImage;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, strong) UIImageView *failterSelection;

@property (nonatomic, strong) UIImageView *photoImageView;


@property (nonatomic, strong) Failter *currentFailter;
@property (nonatomic, copy) NSString *currentFailterName;
@property (nonatomic, strong) NSArray *failterList;

@end

@implementation PAPFilterPhotoViewController
@synthesize scrollView;
@synthesize image;
@synthesize processedImage;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize failterSelection;
@synthesize photoImageView;
@synthesize currentFailterName;

@dynamic currentFailter;

@synthesize failterList;

- (void)onSelectFailter:(NSString*)failterName transition:(BOOL)doTransition
{
    // Determine failter
    FailterButton *failView = nil;
    for (UIView *view in [scrollView subviews]) {
        if ([view isKindOfClass:[FailterButton class]]) {
            NSString *failName = [(FailterButton*)view failID];
            if ([failName isEqualToString:failterName]) {
                failView = (FailterButton*)view;
                break;
            }
            
        }
    }
    
    if (!failView) {
        return;
    }
    
    // Put underneath the button
    CGPoint buttonPos = failView.center;
    
    if (doTransition) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        failterSelection.center = CGPointMake(buttonPos.x, buttonPos.y + 28);
        [UIView commitAnimations];
    } else {
        failterSelection.center = CGPointMake(buttonPos.x, buttonPos.y + 28);
    }
}

- (void)setCurrentFailter:(Failter *)theFailter
{
    currentFailter = theFailter;
    self.processedImage = theFailter ? [theFailter applyToImage:image] : image;
    
    if (photoImageView) {
        photoImageView.image = processedImage;
    }
}

- (Failter*)currentFailter
{
    return currentFailter;
}

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        
        // Init failters
        
        self.failterList = [NSArray arrayWithObjects:
                            [Failter failterWithRandomOpsCalled:@"FAIL1"],
                            [Failter failterWithRandomOpsCalled:@"FAIL2"],
                            [Failter failterWithRandomOpsCalled:@"FAIL3"],
                            [Failter failterWithRandomOpsCalled:@"FAIL4"],
                            [Failter failterWithRandomOpsCalled:@"FAIL5"],
                            [Failter failterWithRandomOpsCalled:@"FAIL6"],nil];
        
        self.currentFailter = [failterList objectAtIndex:0];
        
    }
    return self;
}

- (void)loadView
{
    CGRect scrollFrame = [[UIScreen mainScreen] applicationFrame];
    
    scrollFrame.origin.y = scrollFrame.size.height - 42 - 68;
    scrollFrame.size.height = 68.0;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor grayColor];
    scrollView.directionalLockEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]];
    
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 32.0f, 280.0f, 280.0f)];
    [photoImageView setBackgroundColor:[UIColor blackColor]];
    [photoImageView setImage:processedImage];
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    CALayer *layer = photoImageView.layer;
    layer.masksToBounds = NO;
    layer.shadowRadius = 3.0f;
    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    layer.shadowOpacity = 0.5f;
    layer.shouldRasterize = YES;
    
    self.failterSelection = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 12.0f, 8.0f)];
    [failterSelection setImage:[UIImage imageNamed:@"failselect.png"]];
    [failterSelection setContentMode:UIViewContentModeCenter];
    
    [self.view addSubview:photoImageView];
    [self.view addSubview:scrollView];
    
    CGRect footerRect = [PAPPhotoDetailsFooterView rectForView];
    footerRect.origin.y = photoImageView.frame.origin.y + photoImageView.frame.size.height;
    
    float failterExtent = 5;
    
    // Add failters
    for (Failter *fail in failterList) {
        FailterButton *failView = [[FailterButton alloc] initWithFrame:CGRectMake(failterExtent, 4, 58, 58)];
        failView.delegate = self;
        failView.failID = fail.name;
        failView.caption.text = fail.name;
        [self.scrollView addSubview:failView];
        failterExtent += 10 + (58);
    }
    [scrollView addSubview:failterSelection];
    
    [self.scrollView setContentSize:CGSizeMake(failterExtent-5, 64.0)];
}

- (void)onFailButton:(id)sender
{
    FailterButton *button = (FailterButton*)sender;
    
    Failter *newFailter = nil;
    for (Failter *fail in failterList) {
        if (fail.name == button.failID) {
            newFailter = fail;
            break;
        }
    }
    self.currentFailter = newFailter;
    [self onSelectFailter:newFailter.name transition:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction:)];
    
    [self onSelectFailter:currentFailter.name transition:NO];
    
    //[self shouldUploadImage:self.image];
}

- (void)doneButtonAction:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionary];
    
    PAPEditPhotoViewController *editController = [[PAPEditPhotoViewController alloc] initWithImage:processedImage];
    [editController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.navigationController pushViewController:editController animated:YES];
}

- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
