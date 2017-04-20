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
#import "NITFakeLocationManager.h"
#import "NITGeopolisNodesManager.h"
#import "NITRecipesManager.h"

#define APIKEY @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJ0ZXN0TWFuYWdlciIsInJvbGVfa2V5IjoiYXBwIn19fQ.2-xxd79pAtxJ648T9i_3HJzHRaQdZt0JEIHG5Fmiidg"
#define APPID @"testManager"

@interface NITManagerTest : NITTestCase<NITManagerDelegate>

@property (nonatomic, strong) NITNetworkMockManger *networkManager;
@property (nonatomic) NSInteger contentIndex;

@end

@implementation NITManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.networkManager = [[NITNetworkMockManger alloc] init];
    self.contentIndex = 0;
    
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

- (void)testManagerID1 {
    NITConfiguration *configuration = [[NITConfiguration alloc] init];
    NITFakeLocationManager *locationManager = [[NITFakeLocationManager alloc] init];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:APPID];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [cacheManager removeAllItemsWithCompletionHandler:^{
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC));
    
    NITManager *manager = [[NITManager alloc] initWithApiKey:APIKEY configuration:configuration networkManager:self.networkManager cacheManager:cacheManager locationManager:locationManager];
    
    NITGeopolisManager *geopolis = [manager geopolisManager];
    XCTAssertTrue([[[geopolis nodesManager] roots] count] == 2);
    XCTAssertTrue([[manager recipes] count] == 6);
    
    [configuration clear];
    
    dispatch_semaphore_t semaphore2 = dispatch_semaphore_create(0);
    
    [cacheManager removeAllItemsWithCompletionHandler:^{
        dispatch_semaphore_signal(semaphore2);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC));
}

// MARK: - NITManager delegate

- (void)manager:(NITManager *)manager eventWithContent:(id)content recipe:(NITRecipe *)recipe {
    if ([[self name] isEqualToString:@"testManagerID1"]) {
        
    }
}

- (void)manager:(NITManager *)manager eventFailureWithError:(NSError *)error recipe:(NITRecipe *)recipe {
    
}

@end
