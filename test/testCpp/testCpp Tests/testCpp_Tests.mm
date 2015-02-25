//
//  testCpp_Tests.m
//  testCpp Tests
//
//  Created by Kevin on 2/23/15.
//  Copyright (c) 2015 Thomson Retuers. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "models.h"

using namespace std;
using namespace tr::models;

@interface testCpp_Tests : XCTestCase

@end

@implementation testCpp_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDeserializeJsonData {

    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"js2model-test-data" ofType:@"json"];
//    NSString *jsonFilename = [jsonPath lastPathComponent];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    
    vector<testData_t> instances = tr::models::testDataArrayFromData((const char *)jsonData.bytes, jsonData.length);
    
    XCTAssert(instances.size() == 5);
    
    XCTAssertTrue(instances[0].favoriteFruit == "banana");
    XCTAssertTrue(instances[1].favoriteFruit == "strawberry");
    XCTAssertTrue(instances[2].favoriteFruit == "apple");
    
    const testData_t &testData0 = instances[0];
    
    XCTAssertTrue(testData0.friends[0].name == "Townsend Montoya");
    XCTAssertEqual(testData0.range.size(), 10);
    XCTAssertEqual(testData0.tags.size(), 7);
    XCTAssertFalse(testData0.isActive);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
