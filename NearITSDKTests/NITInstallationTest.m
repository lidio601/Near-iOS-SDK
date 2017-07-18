//
//  NITInstallationTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 06/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "NITTestCase.h"
#import "NITInstallation.h"
#import "Reachability.h"
#import "NITConfiguration.h"
#import "NITJSONAPI.h"
#import "NITConstants.h"
#import "NITJSONAPIResource.h"

@interface NITInstallation (Tests)

- (NITJSONAPIResource*)installationResourceWithInstallationId:(NSString*)installationId;

@end

@interface NITInstallationTest : NITTestCase

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NITConfiguration *configution;
@property (nonatomic, strong) NITNetworkMockManger *networkManager;

@end

@implementation NITInstallationTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.reachability = mock([Reachability class]);
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWWAN];
    self.configution = mock([NITConfiguration class]);
    [given(self.configution.apiKey) willReturn:@"apiKey"];
    [given(self.configution.appId) willReturn:@"appId"];
    [given(self.configution.profileId) willReturn:@"profileId"];
    NITJSONAPI *installationJson = [self jsonApiWithContentsOfFile:@"installation"];
    self.networkManager = [[NITNetworkMockManger alloc] init];
    self.networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return installationJson;
    };
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleRegisterInstallationWithNetwork {
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWWAN];
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configution networkManager:self.networkManager reachability:self.reachability];
    XCTAssertFalse(self.networkManager.isMockCalled);
    // Should do a network request
    [installation registerInstallation];
    XCTAssertFalse(installation.isQueued);
    XCTAssertTrue(self.networkManager.isMockCalled);
}

- (void)testSimpleRegisterInstallationWithoutNetwork {
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:NotReachable];
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configution networkManager:self.networkManager reachability:self.reachability];
    XCTAssertFalse(self.networkManager.isMockCalled);
    // Should not do a network request
    [installation registerInstallation];
    XCTAssertTrue(installation.isQueued);
    XCTAssertFalse(self.networkManager.isMockCalled);
}

- (void)testTwoRegisterInstallationWithoutInstallationId {
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:NotReachable];
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configution networkManager:self.networkManager reachability:self.reachability];
    [installation registerInstallation];
    XCTAssertTrue(installation.isQueued);
    XCTAssertFalse(self.networkManager.isMockCalled);
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWiFi];
    [installation registerInstallation];
    XCTAssertFalse(installation.isQueued);
    XCTAssertTrue(self.networkManager.isMockCalled);
    XCTAssertTrue(self.networkManager.numberOfCalls == 1);
}

- (void)testTwoRegisterInstallationWithInstallationId {
    [given(self.configution.installationId) willReturn:@"installationId"];
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:NotReachable];
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configution networkManager:self.networkManager reachability:self.reachability];
    [installation registerInstallation];
    XCTAssertTrue(installation.isQueued);
    XCTAssertFalse(self.networkManager.isMockCalled);
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWiFi];
    [installation registerInstallation];
    XCTAssertFalse(installation.isQueued);
    XCTAssertTrue(self.networkManager.isMockCalled);
    XCTAssertTrue(self.networkManager.numberOfCalls == 1);
}

- (void)testRegisterInstallationWithErrorIsQueued {
    self.networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil;
    };
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWiFi];
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configution networkManager:self.networkManager reachability:self.reachability];
    [installation registerInstallation];
    XCTAssertTrue(installation.isQueued);
}

- (void)testRegisterInstallationFailedWith404 {
    NSString *installationId404 = @"404-installation-id";
    NSString *fileInstallationId = @"bbaa70c1-9542-4c43-b713-721bcf78fdc6";
    
    NITJSONAPI *installationJson = [self jsonApiWithContentsOfFile:@"installation"];
    
    [[given(self.configution.installationId) willReturn:installationId404] willReturn:nil];
    self.networkManager.mock = nil;
    self.networkManager.mockResponse = ^NITNetworkResponse *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:[NSString stringWithFormat:@"/installations/%@", installationId404]]) {
            NSError *error = [[NSError alloc] initWithDomain:NITNetowkrErrorDomain code:1 userInfo:@{NITHttpStatusCode : [NSNumber numberWithInteger:404]}];
            return [[NITNetworkResponse alloc] initWithError:error];
        } else {
            return [[NITNetworkResponse alloc] initWithJSONApi:installationJson];
        }
        
    };
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWiFi];
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configution networkManager:self.networkManager reachability:self.reachability];
    [installation registerInstallation];
    
    [verifyCount(self.configution, times(1)) setInstallationId:nil];
    [verifyCount(self.configution, times(1)) setInstallationId:fileInstallationId];
    XCTAssertFalse(installation.isQueued);
}

- (void)testRegisterInstallationFailedWith403 {
    NSString *installationId403 = @"403-installation-id";
    NSString *fileInstallationId = @"bbaa70c1-9542-4c43-b713-721bcf78fdc6";
    
    NITJSONAPI *installationJson = [self jsonApiWithContentsOfFile:@"installation"];
    
    [given(self.configution.installationId) willReturn:installationId403];
    self.networkManager.mock = nil;
    self.networkManager.mockResponse = ^NITNetworkResponse *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:[NSString stringWithFormat:@"/installations/%@", installationId403]]) {
            NSError *error = [[NSError alloc] initWithDomain:NITNetowkrErrorDomain code:1 userInfo:@{NITHttpStatusCode : [NSNumber numberWithInteger:403]}];
            return [[NITNetworkResponse alloc] initWithError:error];
        } else {
            return [[NITNetworkResponse alloc] initWithJSONApi:installationJson];
        }
        
    };
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWiFi];
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configution networkManager:self.networkManager reachability:self.reachability];
    [installation registerInstallation];
    
    [verifyCount(self.configution, never()) setInstallationId:nil];
    [verifyCount(self.configution, never()) setInstallationId:fileInstallationId];
    XCTAssertTrue(installation.isQueued);
}

- (void)testVersion {
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configution networkManager:self.networkManager reachability:self.reachability];
    
    NSString *sdkVersion = [[NSBundle bundleWithIdentifier:@"com.nearit.NearITSDK"] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NITJSONAPIResource *resource = [installation installationResourceWithInstallationId:@"installationId"];
    NSString *version = [resource attributeForKey:@"sdk_version"];
    XCTAssertNotNil(version);
    XCTAssertTrue([version isEqualToString:sdkVersion]);
}

@end
