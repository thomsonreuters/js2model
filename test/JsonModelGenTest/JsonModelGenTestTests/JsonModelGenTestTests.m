//
//  JsonModelGenTestTests.m
//  JsonModelGenTestTests
//
//  Created by Kevin on 9/26/14.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TRJsonLoader.h"

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

-(void)testLoadJson {
    
    NSArray *jsonPaths = [[NSBundle bundleForClass:[self class] ] pathsForResourcesOfType:@"json" inDirectory:nil];

    for (NSString *jsonPath in jsonPaths) {
        
        NSString *jsonFilename = [jsonPath lastPathComponent];
        
        NSString *baseName = [jsonFilename stringByDeletingPathExtension];
        
        NSString *className = [NSString stringWithFormat:@"TR%@%@", [[baseName substringToIndex:1] capitalizedString], [baseName substringFromIndex:1]];
        
        Class cls = NSClassFromString(className);
        
        XCTAssertNotNil(cls, "Class %@ not found",  className);
        
        if( cls ) {
            id object = [[cls alloc] init];
            
            NSError *error;
            [TRJsonLoader load:object withJSONFromFileNamed:jsonFilename error:&error];

            XCTAssertNil(error, @"Error while loading %@",jsonFilename);
        }
    }
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
