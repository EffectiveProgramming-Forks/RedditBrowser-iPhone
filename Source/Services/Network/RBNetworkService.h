#import <Foundation/Foundation.h>
#import "RBNetworkBlocks.h"

@class RBURLValidator;

@interface RBNetworkService : NSObject

- (id)initWithValidator:(RBURLValidator *)validator;
- (void)GET:(NSString *)urlAsString completionBlock:(RBJSONCompletionBlock)completionBlock;

@end
