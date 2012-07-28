//
//  PAPFilterPhotoViewController.h
//  Anypic
//
//  Created by James Urquhart on 27/07/2012.
//
//

@class Failter;

@interface PAPFilterPhotoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate> {
   Failter *currentFailter;
}

- (id)initWithImage:(UIImage *)aImage;

- (void)onFailButton:(id)sender;

@end
