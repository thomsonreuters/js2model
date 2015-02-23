//
//  testObjcTests.m
//  testObjcTests
//
//  Created by Kevin on 2/23/15.
//  Copyright (c) 2015 Thomson Retuers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TRmodels.h"

@interface testObjcTests : XCTestCase

@end

@implementation testObjcTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testLoadJsonArray {
    
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"js2model-test-data" ofType:@"json"];
    
    NSString *jsonFilename = [jsonPath lastPathComponent];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    
    NSError *error = nil;
    NSArray* instances = [TRTestData testDataArrayWithJSONData:jsonData error:&error];
    
    XCTAssertNotNil(instances, @"Error while loading %@",jsonFilename);
    XCTAssertNil(error, @"Error while loading %@",jsonFilename);
    
    if (!error) {
        XCTAssertEqualObjects(((TRTestData*)instances[0]).favoriteFruit, @"banana");
        XCTAssertEqualObjects(((TRTestData*)instances[1]).favoriteFruit, @"strawberry");
        XCTAssertEqualObjects(((TRTestData*)instances[2]).favoriteFruit, @"apple");
        
        TRTestData *testData0 = (TRTestData*)instances[0];
        
        XCTAssertEqualObjects([testData0.friends[0] name], @"Townsend Montoya");
        XCTAssertEqual([testData0.range count], 10);
        XCTAssertEqual([testData0.tags count], 7);
        XCTAssertFalse([testData0.isActive boolValue]);
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"js2model-test-data" ofType:@"json"];
        
        NSString *jsonFilename = [jsonPath lastPathComponent];
        
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
        
        NSError *error = nil;
        NSArray* instances = [TRTestData testDataArrayWithJSONData:jsonData error:&error];

        XCTAssertNotNil(instances, @"Error while loading %@",jsonFilename);
        XCTAssertNil(error, @"Error while loading %@",jsonFilename);
    }];
}

@end
