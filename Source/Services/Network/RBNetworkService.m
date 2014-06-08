#import "RBNetworkService.h"
#import <AFNetworking/AFNetworking.h>
#import "RBURLValidator.h"

@interface RBNetworkService ()

@property (nonatomic) RBURLValidator *validator;

@end

@implementation RBNetworkService

+ (instancetype)networkService {
    RBURLValidator *validator = [[RBURLValidator alloc] init];
    return [[RBNetworkService alloc] initWithValidator:validator];
}

- (id)initWithValidator:(RBURLValidator *)validator {
    self = [super init];
    if (self) {
        _validator = validator;
    }
    return self;
}

- (void)GET:(NSString *)urlAsString completionBlock:(RBJSONCompletionBlock)completionBlock {
    if ([_validator isValidURL:urlAsString]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:urlAsString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completionBlock) {
                completionBlock(responseObject, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completionBlock) {
                completionBlock(nil, error);
            }
        }];
    }
}

@end
