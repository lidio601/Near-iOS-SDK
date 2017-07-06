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

@end
