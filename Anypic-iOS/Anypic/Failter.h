//
//  Failter.h
//  Anypic
//
//  Created by James Urquhart on 27/07/2012.
//
//

#import <Foundation/Foundation.h>

@interface Failter : NSObject
{
int seed;
void *current_magick;
}

- (id)initWithOperations:(NSArray*)operations;
- (UIImage*)applyToImage:(UIImage*)image;


+ (Failter*)failterWithRandomOpsCalled:(NSString*)name;
+ (Failter*)failterWithOps:(NSArray*)operations called:(NSString*)name;


@property (nonatomic, strong) NSArray *ops;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int seed;

@end
