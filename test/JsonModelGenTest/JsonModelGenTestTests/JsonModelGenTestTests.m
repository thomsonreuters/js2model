//
//  JsonModelGenTestTests.m
//  JsonModelGenTestTests
//
//  Created by Kevin on 9/26/14.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TRJSONModelLoader.h"
#import "TRModels.h"

@interface JsonModelGenTestTests : XCTestCase

@end

@implementation JsonModelGenTestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

-(void)_testLoadJson {
    
    NSArray *jsonPaths = [[NSBundle bundleForClass:[self class] ] pathsForResourcesOfType:@"json" inDirectory:nil];

    [self measureBlock:^{
        
        for (NSString *jsonPath in jsonPaths) {
    
            NSString *jsonFilename = [jsonPath lastPathComponent];
            
            NSString *baseName = [jsonFilename stringByDeletingPathExtension];
            
            NSString *className = [NSString stringWithFormat:@"TR%@%@", [[baseName substringToIndex:1] capitalizedString], [baseName substringFromIndex:1]];
            
            Class cls = NSClassFromString(className);

            XCTAssertNotNil(cls, "Class %@ not found",  className);
            
            if( cls ) {

                NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
                
                NSError *error;
                id<JSONModelSerialize> object = [ ((id<JSONModelSerialize>)[cls alloc]) initWithJSONData:jsonData error:&error];
                
                [TRJSONModelLoader load:object withJSONFromFileNamed:jsonFilename error:&error];

                XCTAssertNil(error, @"Error while loading %@",jsonFilename);

                if (!error) {
//                    if (cls == [TRLicenseResultWrapper class]) {
//
//                        TRLicenseResultWrapper *licenseResultWrapper = (TRLicenseResultWrapper*)object;
//                        
//                        XCTAssertEqualObjects(licenseResultWrapper.searchResult.driver.name.firstName, @"JANE");
//                        XCTAssertEqualObjects(licenseResultWrapper.searchResult.driver.name.lastName, @"SAMPLE");
//                        XCTAssertEqualObjects(licenseResultWrapper.incarcerationHistory.foundIncarcerationHistory, @YES);
//                        XCTAssertEqual(licenseResultWrapper.incarcerationHistory.incarcerationRecords.count, 5);
//                        
//                        TRIncarcerationRecord *incarcerationRecord = licenseResultWrapper.incarcerationHistory.incarcerationRecords[0];
//                        
//                        XCTAssertEqual(incarcerationRecord.charges.count, 0);
//                        XCTAssertEqualObjects(incarcerationRecord.bookingInfo.arrestAgency, @"Florida Dept  Of Corrections");
//                        XCTAssertEqualObjects(incarcerationRecord.bookingInfo.arrestedDate, @"2007-08-27");
//                        XCTAssertEqualObjects(incarcerationRecord.bookingInfo.state, @"FL");
//                        
//                        incarcerationRecord = licenseResultWrapper.incarcerationHistory.incarcerationRecords[1];
//                        XCTAssertEqual(incarcerationRecord.charges.count, 5);
//                        XCTAssertEqualObjects(incarcerationRecord.bookingInfo.arrestAgency, @"Citrus Co Sheriffs Office");
//                        XCTAssertEqualObjects(incarcerationRecord.bookingInfo.arrestedDate, @"2007-03-15");
//                        XCTAssertEqualObjects(incarcerationRecord.bookingInfo.state, @"FL");
//                        TRCharges *charges = incarcerationRecord.charges[0];
//                        XCTAssertEqualObjects(charges.crimeSeverity, @"Felony");
//                        charges = incarcerationRecord.charges[4];
//                        XCTAssertEqualObjects(charges.crimeSeverity, @"Misdemeanor");
//                        
//                        id<JSONModelSerialize> additionalObject = [licenseResultWrapper.additionalProperties valueForKey:@"unknownObject"];
//                        XCTAssertNotNil(additionalObject);
//                        
//                        id unknowDescription = [[additionalObject additionalProperties] valueForKey:@"comment"];
//                        XCTAssertNotNil(unknowDescription);
//
//                        id unknowInteger = [[additionalObject additionalProperties] valueForKey:@"integerProperty"];
//                        XCTAssertNotNil(unknowInteger);
//                    }
                }
            }
        }
    }];
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
        // Put the code you want to measure the time of here.
    }];
}

@end
