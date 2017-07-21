//
//  NITManagerTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 20/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestCase.h"
#import "NITGeopolisManager+Tests.h"
#import "NITNetworkMockManger.h"
#import "NITCacheManager.h"
#import "NITGeopolisNodesManager.h"
#import "NITRecipesManager.h"
#import "NITNode.h"
#import "NITUserProfile.h"
#import "NITSimpleNotification.h"
#import "NITTrackManager.h"
#import "NITReaction.h"
#import "NITSimpleNotificationReaction.h"
#import "NITContentReaction.h"
#import "NITCouponReaction.h"
#import "NITCustomJSONReaction.h"
#import "NITFeedbackReaction.h"
#import <CoreLocation/CoreLocation.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define APIKEY @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJ0ZXN0TWFuYWdlciIsInJvbGVfa2V5IjoiYXBwIn19fQ.2-xxd79pAtxJ648T9i_3HJzHRaQdZt0JEIHG5Fmiidg"
#define APPID @"testManager"

typedef void (^SetUserDataBlock)(NSError* error);
typedef void (^ReactionContentWithRecipeBlock)(id content, NSError * error);

@interface NITManager (Tests)

- (instancetype _Nonnull)initWithConfiguration:(NITConfiguration* _Nonnull)configuration application:(UIApplication*)application networkManager:(id<NITNetworkManaging> _Nonnull)networkManager cacheManager:(NITCacheManager* _Nonnull)cacheManager bluetoothManager:(CBCentralManager* _Nonnull)bluetoothManager profile:(NITUserProfile*)profile trackManager:(NITTrackManager*)trackManager recipesManager:(NITRecipesManager*)recipesManager geopolisManager:(NITGeopolisManager*)geopolisManager reactions:(NSMutableDictionary<NSString*, NITReaction*>*)reactions;

+ (NSMutableDictionary<NSString*, NITReaction*>*)makeReactionsWithConfiguration:(NITConfiguration*)configuration cacheManager:(NITCacheManager*)cacheManager networkManager:(id<NITNetworkManaging>)networkManager;

- (void)recipesManager:(NITRecipesManager *)recipesManager gotRecipe:(NITRecipe *)recipe;

@end

@interface NITManagerTest : NITTestCase<NITManagerDelegate>

@property (nonatomic, strong) NITNetworkMockManger *networkManager;
@property (nonatomic, strong) NITConfiguration *configuration;
@property (nonatomic, strong) NITUserProfile *profile;
@property (nonatomic, strong) NITTrackManager *trackManager;
@property (nonatomic, strong) NITRecipesManager *recipesManager;
@property (nonatomic, strong) NITGeopolisManager *geopolisManager;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NITReaction*> *reactions;
@property (nonatomic, strong) UIApplication *application;
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
    self.reactions = [[NSMutableDictionary alloc] init];
    self.configuration = mock([NITConfiguration class]);
    [given(self.configuration.apiKey) willReturn:APIKEY];
    [given(self.configuration.appId) willReturn:APPID];
    self.cacheManager = mock([NITCacheManager class]);
    [given([self.cacheManager loadArrayForKey:anything()]) willReturn:nil];
    self.bluetoothManager = mock([CBCentralManager class]);
    [given([self.bluetoothManager state]) willReturnInteger:CBManagerStatePoweredOn];
    
    self.profile = mock([NITUserProfile class]);
    [givenVoid([self.profile setUserDataWithKey:anything() value:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
        SetUserDataBlock block = [invocation mkt_arguments][2];
        block(nil);
        return nil;
    }];
    
    self.trackManager = mock([NITTrackManager class]);
    self.recipesManager = mock([NITRecipesManager class]);
    self.geopolisManager = mock([NITGeopolisManager class]);
    
    self.application = mock([UIApplication class]);
    [given([self.application applicationState]) willReturnInteger:UIApplicationStateActive];
    
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
    __weak NITManagerTest *weakSelf = self;
    [self.networkManager setMock:^NITJSONAPI *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:@"/data_points"]) {
            return [weakSelf jsonApiWithContentsOfFile:@"manager_datapoint"];
        }
        return nil;
    } forKey:@"dataPoint"];
    
    NITManager *manager = [[NITManager alloc] initWithConfiguration:self.configuration application:self.application networkManager:self.networkManager cacheManager:self.cacheManager bluetoothManager:self.bluetoothManager profile:self.profile trackManager:self.trackManager recipesManager:self.recipesManager geopolisManager:self.geopolisManager reactions:self.reactions];
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
    
    [verifyCount(self.profile, times(2)) setUserDataWithKey:anything() value:anything() completionHandler:anything()];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testMakeReactions {
    NITConfiguration *configuration = mock([NITConfiguration class]);
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    NSMutableDictionary<NSString*, NITReaction*> *reactions = [NITManager makeReactionsWithConfiguration:configuration cacheManager:cacheManager networkManager:self.networkManager];
    
    NITReaction *simple = [reactions objectForKey:NITSimpleNotificationPluginName];
    XCTAssertNotNil(simple);
    XCTAssertTrue([simple isKindOfClass:[NITSimpleNotificationReaction class]]);
    
    NITReaction *content = [reactions objectForKey:NITContentPluginName];
    XCTAssertNotNil(content);
    XCTAssertTrue([content isKindOfClass:[NITContentReaction class]]);
    
    NITReaction *coupon = [reactions objectForKey:NITCouponPluginName];
    XCTAssertNotNil(coupon);
    XCTAssertTrue([coupon isKindOfClass:[NITCouponReaction class]]);
    
    NITReaction *customJson = [reactions objectForKey:NITCustomJSONPluginName];
    XCTAssertNotNil(customJson);
    XCTAssertTrue([customJson isKindOfClass:[NITCustomJSONReaction class]]);
    
    NITReaction *feedback = [reactions objectForKey:NITFeedbackPluginName];
    XCTAssertNotNil(feedback);
    XCTAssertTrue([feedback isKindOfClass:[NITFeedbackReaction class]]);
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
