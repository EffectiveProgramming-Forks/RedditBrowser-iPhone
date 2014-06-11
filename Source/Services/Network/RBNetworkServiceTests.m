#import <XCTest/XCTest.h>
#import "RBURLValidator.h"
#import "RBNetworkService.h"
#import <OHHTTPStubs/OHHTTPStubs.h>

/**
 * Possible outcomes
 * - html content
 * - 40*, 50*
 * - 200
 */
@interface RBNetworkServiceTests : XCTestCase

@property (nonatomic) RBNetworkService *testObject;
@property (nonatomic) NSString *signal;
@property (nonatomic) NSData *jsonData;
@property (nonatomic) NSDictionary *jsonHeaders;

@end

@implementation RBNetworkServiceTests

static NSInteger kHTTPCODE_SUCCESS = 200;
static NSInteger kHTTPCODE_NOT_AUTHORIZED = 401;
static NSInteger kHTTPCODE_SERVER_ERROR = 500;
static NSInteger kAsyncSignalTimeOut = 1.0;

- (void)setUp {
    [super setUp];
    _jsonData = [@"{ \"testKey\" : \"testValue\" }" dataUsingEncoding:NSUTF8StringEncoding];
    _jsonHeaders = @{ @"Content-Type" : @"application/json" };
    _signal = @"AsyncSignal";
    RBURLValidator *urlValidator = [[RBURLValidator alloc] init];
    _testObject = [[RBNetworkService alloc] initWithValidator:urlValidator];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Client Error

- (void)testThatNothingFiresIfURLIsNotValid {
    [_testObject GET:nil completionBlock:^(id response, NSError *error) {
        [self asySignal:_signal];
    }];
    
    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertFalse(signaled);
}

#pragma mark - HTTPCODE_SUCCESS

- (void)testThatCompletionBlockIsInvokedWithDictionaryAndNoErrorOnHTTP_SUCCESS {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:_jsonData
                                                statusCode:kHTTPCODE_SUCCESS
                                                   headers:_jsonHeaders];
    }];
    
    [_testObject GET:@"http://www.yahoo.com/" completionBlock:^(id response, NSError *error) {
        if (response && !error) {
            [self asySignal:_signal];
        }
    }];

    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertTrue(signaled);
}

- (void)testThatCompletionBlockIsNotInvokedOnSuccessIfItIsNil {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:_jsonData
                                          statusCode:kHTTPCODE_SUCCESS
                                             headers:_jsonHeaders];
    }];
    
    [_testObject GET:@"http://www.yahoo.com/" completionBlock:nil];
    
    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertFalse(signaled);
}

#pragma mark - HTTPCODE_ERROR

- (void)testThatCompletionBlockIsInvokedWithDictionaryAndNoErrorOnHTTP_NOT_AUTHORIZED {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:kHTTPCODE_NOT_AUTHORIZED
                                             headers:nil];
    }];
    
    [_testObject GET:@"http://www.yahoo.com/" completionBlock:^(id response, NSError *error) {
        if (!response && error) {
            [self asySignal:_signal];
        }
    }];
    
    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertTrue(signaled);
}

- (void)testThatCompletionBlockIsInvokedWithDictionaryAndNoErrorOnHTTP_SERVER_ERROR {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:kHTTPCODE_SERVER_ERROR
                                             headers:nil];
    }];
    
    [_testObject GET:@"http://www.yahoo.com/" completionBlock:^(id response, NSError *error) {
        if (!response && error) {
            [self asySignal:_signal];
        }
    }];
    
    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertTrue(signaled);
}

- (void)testThatCompletionBlockIsNotInvokedOnFailureIfItIsNil {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:_jsonData
                                          statusCode:kHTTPCODE_SERVER_ERROR
                                             headers:_jsonHeaders];
    }];
    
    [_testObject GET:@"http://www.yahoo.com/" completionBlock:nil];
    
    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertFalse(signaled);
}

#pragma mark - URLs

- (void)testThatCorrectHostIsHit {
    __block NSString *actualHost = nil;
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        actualHost = request.URL.host;
        return [OHHTTPStubsResponse responseWithData:_jsonData
                                          statusCode:kHTTPCODE_SUCCESS
                                             headers:_jsonHeaders];
    }];
    
    NSString *expectedHost = @"www.reddit.com";
    NSString *subreddit = @"/r/ListenToThis";
    NSString *urlAsString = [NSString stringWithFormat:@"http://%@%@", expectedHost, subreddit];
    [_testObject GET:urlAsString
     completionBlock:^(id response, NSError *error) {
         if (response && !error) {
             if ([actualHost isEqualToString:expectedHost]) {
                 [self asySignal:_signal];
             }
         }
     }];
    
    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertTrue(signaled);
}

- (void)testThatCorrectPathIsUsed {
    __block NSString *actualURL = nil;
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        actualURL = [request.URL absoluteString];
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:_jsonData
                                          statusCode:kHTTPCODE_SUCCESS
                                             headers:_jsonHeaders];
    }];
    
    NSString *host = @"www.reddit.com";
    NSString *subreddit = @"/r/ListenToThis";
    NSString *expectedURL = [NSString stringWithFormat:@"http://%@%@", host, subreddit];
    [_testObject GET:expectedURL
     completionBlock:^(id response, NSError *error) {
         if (response && !error) {
             if ([actualURL isEqualToString:expectedURL]) {
                 [self asySignal:_signal];
             }
         }
     }];
    
    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertTrue(signaled);
}

#pragma mark - Return Values

- (void)testThatAProperDictionaryIsCreated {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:_jsonData
                                          statusCode:kHTTPCODE_SUCCESS
                                             headers:_jsonHeaders];
    }];
    
    NSString *host = @"www.reddit.com";
    NSString *subreddit = @"/r/ListenToThis";
    NSString *expectedURL = [NSString stringWithFormat:@"http://%@%@", host, subreddit];
    [_testObject GET:expectedURL
     completionBlock:^(NSDictionary *jsonResponse, NSError *error) {
         if (jsonResponse && !error) {
             if ([[jsonResponse allKeys] count] == 1) {
                 NSString *key = [jsonResponse allKeys][0];
                 NSString *val = jsonResponse[key];
                 if ([key isEqualToString:@"testKey"] &&
                     [val isEqualToString:@"testValue"]) {
                     [self asySignal:_signal];
                 }
             }
         }
     }];
    
    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertTrue(signaled);
}

@end
