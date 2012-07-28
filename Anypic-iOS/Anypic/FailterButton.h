//
//  FailterButton.h
//  Anypic
//
//  Created by James Urquhart on 27/07/2012.
//
//

#import <UIKit/UIKit.h>

@class PAPFilterPhotoViewController;

@interface FailterButton : UIView
@property (nonatomic, strong) UIImageView *preview;
@property (nonatomic, strong) UILabel *caption;

@property (nonatomic, strong) PAPFilterPhotoViewController *delegate;

@property (nonatomic, copy) NSString *failID;

@end
