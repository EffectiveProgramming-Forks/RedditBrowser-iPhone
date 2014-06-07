#import <XCTest/XCTest.h>
#import "RBURLValidator.h"

@interface RBURLValidatorTests : XCTestCase

@property (nonatomic) RBURLValidator *validator;

@end

@implementation RBURLValidatorTests

- (void)setUp {
    [super setUp];
    _validator = [[RBURLValidator alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatAValidURLIsConsideredValid {
    NSString *validURL = @"http://www.googl.com";
    BOOL isValid = [_validator isValidURL:validURL];
    
    XCTAssertTrue(isValid);
}

- (void)testThatAnInvalidURLIsConsideredInvalid {
    NSString *invalidURL = @"";
    BOOL isValid = [_validator isValidURL:invalidURL];
    
    XCTAssertFalse(isValid);
}

//
// Could easily write more tests and beef this validator up.
//

@end
