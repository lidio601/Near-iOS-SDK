//
//  NITManagerTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 20/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestCase.h"
#import "NITManager+Tests.h"
#import "NITNetworkMockManger.h"
#import "NITFakeLocationManager.h"

#define APIKEY @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJ0ZXN0TWFuYWdlciIsInJvbGVfa2V5IjoiYXBwIn19fQ.2-xxd79pAtxJ648T9i_3HJzHRaQdZt0JEIHG5Fmiidg"

@interface NITManagerTest : NITTestCase

@property (nonatomic, strong) NITNetworkMockManger *networkManager;

@end

@implementation NITManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.networkManager = [[NITNetworkMockManger alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testManagerID1 {
    NITConfiguration *configuration = [[NITConfiguration alloc] init];
    NITFakeLocationManager *locationManager = [[NITFakeLocationManager alloc] init];
    
    NITManager *manager = [[NITManager alloc] initWithApiKey:APIKEY configuration:configuration networkManager:self.networkManager locationManager:locationManager];
}

@end
