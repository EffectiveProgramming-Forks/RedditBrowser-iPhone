#import <Foundation/Foundation.h>

@class RBURLValidator;

typedef void (^RBJSONCompletionBlock)(id response, NSError *error);

@interface RBNetworkService : NSObject

- (id)initWithValidator:(RBURLValidator *)validator;
- (void)GET:(NSString *)urlAsString completionBlock:(RBJSONCompletionBlock)completionBlock;

@end
