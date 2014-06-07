#import "RBURLValidator.h"

@implementation RBURLValidator

- (BOOL)isValidURL:(NSString *)urlAsString {
    // This is intentionally simplistic!
    return [urlAsString length] > 0;
}

@end
