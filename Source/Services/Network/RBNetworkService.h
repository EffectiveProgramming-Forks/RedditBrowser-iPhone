#import <Foundation/Foundation.h>

typedef void (^RBJSONCompletionBlock)(id response, NSError *error);

@class RBURLValidator;

@interface RBNetworkService : NSObject

+ (instancetype)networkService;

- (id)initWithValidator:(RBURLValidator *)validator;
- (void)GET:(NSString *)urlAsString completionBlock:(RBJSONCompletionBlock)completionBlock;

@end
