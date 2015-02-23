//
//  ViewController.m
//  testObjc
//
//  Created by Kevin on 2/23/15.
//  Copyright (c) 2015 Thomson Retuers. All rights reserved.
//

#import "ViewController.h"

#import "TRmodels.h"

const NSInteger kLoopCount = 10000;


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadJson];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadJson {
    
    for (int i = 0; i < kLoopCount; i++) {
        [self loadJsonViaJs2Model];
    }
    
    for (int i = 0; i < kLoopCount; i++) {
        [self loadJsonViaNSJSONSeriralization];
    }
}

-(void)loadJsonViaJs2Model {
    
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"js2model-test-data" ofType:@"json"];
    
    //    NSString *jsonFilename = [jsonPath lastPathComponent];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    
    NSError *error;
    NSArray* instances = [TRTestData testDataArrayWithJSONData:jsonData error:&error];
    
    NSAssert(instances, @"No instances found in JSON");
    NSAssert(!error, @"Error parsing JSON: %@", error);
}

-(void)loadJsonViaNSJSONSeriralization {
    
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"js2model-test-data" ofType:@"json"];
    
    //    NSString *jsonFilename = [jsonPath lastPathComponent];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    
    NSError *error;
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    NSAssert(jsonObj, @"No instances found in JSON");
    NSAssert(!error, @"Error parsing JSON: %@", error);
}


@end
