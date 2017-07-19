//
//  NITManagerTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 20/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestCase.h"
#import "NITManager+Tests.h"
#import "NITGeopolisManager+Tests.h"
#import "NITNetworkMockManger.h"
#import "NITCacheManager.h"
#import "NITGeopolisNodesManager.h"
#import "NITRecipesManager.h"
#import "NITNode.h"
#import "NITSimpleNotification.h"
#import <CoreLocation/CoreLocation.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define APIKEY @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJ0ZXN0TWFuYWdlciIsInJvbGVfa2V5IjoiYXBwIn19fQ.2-xxd79pAtxJ648T9i_3HJzHRaQdZt0JEIHG5Fmiidg"
#define APPID @"testManager"

@interface NITManagerTest : NITTestCase<NITManagerDelegate>

@property (nonatomic, strong) NITNetworkMockManger *networkManager;
@property (nonatomic) NSInteger contentIndex;
@property (nonatomic, strong) NSMutableDictionary<NSString*, XCTestExpectation*> *expectations;

@end

@implementation NITManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.networkManager = [[NITNetworkMockManger alloc] init];
    self.contentIndex = 0;
    self.expectations = [[NSMutableDictionary alloc] init];
    
    __weak NITManagerTest *weakSelf = self;
    [self.networkManager setMock:^NITJSONAPI *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:@"/plugins/congrego/profiles"] && [request.HTTPMethod.lowercaseString isEqualToString:@"post"]) {
            return [weakSelf jsonApiWithContentsOfFile:@"fake_new_profile"];
        }
        return nil;
    } forKey:@"new-profile"];
    [self.networkManager setMock:^NITJSONAPI *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:@"/installations"] && ([request.HTTPMethod.lowercaseString isEqualToString:@"post"] || [request.HTTPMethod.lowercaseString isEqualToString:@"put"])) {
            return [weakSelf jsonApiWithContentsOfFile:@"fake_installation"];
        }
        return nil;
    } forKey:@"installation"];
    [self.networkManager setMock:^NITJSONAPI *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:@"/plugins/geopolis/nodes"]) {
            return [weakSelf jsonApiWithContentsOfFile:@"manager_config_22"];
        }
        return nil;
    } forKey:@"geopolis"];
    [self.networkManager setMock:^NITJSONAPI *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:@"/recipes/process"]) {
            return [weakSelf jsonApiWithContentsOfFile:@"manager_recipes"];
        }
        return nil;
    } forKey:@"recipes"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testManagerDataPoint {
    NITConfiguration *configuration = [[NITConfiguration alloc] init];
    [configuration setApiKey:APIKEY];
    CLLocationManager *locationManager = mock([CLLocationManager class]);
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    [given([cacheManager loadArrayForKey:anything()]) willReturn:nil];
    CBCentralManager *bluetoothManager = mock([CBCentralManager class]);
    [given([bluetoothManager state]) willReturnInteger:CBManagerStatePoweredOn];
    
    __weak NITManagerTest *weakSelf = self;
    [self.networkManager setMock:^NITJSONAPI *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:@"/data_points"]) {
            return [weakSelf jsonApiWithContentsOfFile:@"manager_datapoint"];
        }
        return nil;
    } forKey:@"dataPoint"];
    
    NITManager *manager = [[NITManager alloc] initWithConfiguration:configuration networkManager:self.networkManager cacheManager:cacheManager locationManager:locationManager bluetoothManager:bluetoothManager];
    manager.delegate = self;
    
    XCTestExpectation *expOne = [self expectationWithDescription:@"One"];
    
    [manager setUserDataWithKey:@"test" value:@"test-value" completionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        
        [expOne fulfill];
    }];
    
    XCTestExpectation *expTwo = [self expectationWithDescription:@"Two"];
    
    [manager setUserDataWithKey:@"test-null" value:nil completionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        
        [expTwo fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

// MARK: - NITManager delegate

- (void)manager:(NITManager *)manager eventWithContent:(id)content recipe:(NITRecipe *)recipe {
    NSString *testName = [self name];
    if ([testName isEqualToString:@"-[NITManagerTest testManagerID1]"]) {
        if (self.contentIndex == 0) {
            XCTestExpectation *expectation = [self.expectations objectForKey:@"r1_notification"];
            XCTAssertTrue([content isKindOfClass:[NITSimpleNotification class]]);
            if ([content isKindOfClass:[NITSimpleNotification class]]) {
                NITSimpleNotification *notification = (NITSimpleNotification*)content;
                XCTAssertTrue([notification.notificationTitle isEqualToString:@"Hello world!"]);
                XCTAssertTrue([notification.message isEqualToString:@"Be happy and stay green"]);
            }
            self.contentIndex++;
            [expectation fulfill];
        } else if (self.contentIndex == 1) {
            XCTestExpectation *expectation = [self.expectations objectForKey:@"n1r1_notification"];
            XCTAssertTrue([content isKindOfClass:[NITContent class]]);
            if ([content isKindOfClass:[NITContent class]]) {
                NITContent *ctnt = (NITContent*)content;
                XCTAssertTrue([ctnt.content containsString:@"<h2>​Benvenuto</h2>"]);
            }
            self.contentIndex++;
            [expectation fulfill];
        }
    }
}

- (void)manager:(NITManager *)manager eventFailureWithError:(NSError *)error recipe:(NITRecipe *)recipe {
    XCTAssertNil(error);
}

@end
