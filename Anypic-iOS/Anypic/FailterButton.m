//
//  FailterButton.m
//  Anypic
//
//  Created by James Urquhart on 27/07/2012.
//
//

#import "FailterButton.h"
#import "PAPFilterPhotoViewController.h"

@implementation FailterButton

@synthesize preview;
@synthesize caption;
@synthesize failID;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.caption = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 18.0, frame.size.width, 12.0)];
        
        self.preview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        preview.image = [UIImage imageNamed:@"failterbutton.png"];
        preview.opaque = NO;
        //preview.backgroundColor = [UIColor redColor];
        preview.contentMode = UIViewContentModeCenter;
        
        self.userInteractionEnabled = YES;
        
        [self addSubview:preview];
        [self addSubview:caption];

        caption.textAlignment = UITextAlignmentCenter;
        caption.backgroundColor = [UIColor clearColor];
        caption.text = @"TEST";
        caption.opaque = NO;
        caption.textColor = [UIColor whiteColor];
        caption.shadowColor = [UIColor blackColor];
        caption.shadowOffset = CGSizeMake(1,1);
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //
    [delegate onFailButton:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
