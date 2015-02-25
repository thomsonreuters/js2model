

//
//  TRTestData.m
//
//  Created by js2Model on 2015-02-24.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import "TRTestData.h"
#import "TRFriends.h"
#import "TRName.h"

@implementation TRTestData{
}


-(instancetype)initWithDict:(NSDictionary *)dict {
    self = [self init];
    if (self) {

        self.guid = dict[@"guid"];

        self.index = dict[@"index"];

        self.favoriteFruit = dict[@"favoriteFruit"];

        self.latitude = dict[@"latitude"];

        self.email = dict[@"email"];

        self.picture = dict[@"picture"];

        [dict[@"tags"] enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
            [self.tags addObject:obj];
        }];

        self.company = dict[@"company"];

        self.eyeColor = dict[@"eyeColor"];

        self.phone = dict[@"phone"];

        self.address = dict[@"address"];

        [dict[@"friends"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            [self.friends addObject: [[TRFriends alloc] initWithDict:obj]];
        }];

        self.isActive = dict[@"isActive"];

        self.about = dict[@"about"];

        self.balance = dict[@"balance"];

        self.name = [[TRName alloc] initWithDict:dict[@"name"]];

        self.age = dict[@"age"];

        self.registered = dict[@"registered"];

        self.greeting = dict[@"greeting"];

        self.longitude = dict[@"longitude"];

        [dict[@"range"] enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
            [self.range addObject:obj];
        }];

        self.Id = dict[@"_id"];
    }
    return self;
}

- (instancetype) initWithJSONData:(NSData *)data
                            error:(NSError* __autoreleasing *)error {

    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];

    NSAssert(jsonObj, @"No instances found in JSON");
    NSAssert(!*error, @"Error parsing JSON: %@", *error);

    self = [self initWithDict:jsonObj];

    if (self) {
    }
    return self;
}

/** Parses JSON data and creates an Objective-C instance.

@param cls Class type of top-most instance.
@param filename Name of file with JSON data to be parsed.
@param error Non-nil if any parsings errors occured.
*/
- (instancetype) initWithJSONFromFileNamed:(NSString *)filename
                                     error:(NSError* __autoreleasing *)error {

    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    self = [self initWithJSONData:jsonData error:error];
    if (self) {
    }
    return self;
}
+(instancetype) testDataWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

+(instancetype) testDataWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error {

    return [[self alloc] initWithJSONData:data error:error];
}

+(instancetype) testDataWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error {

    return [[self alloc] initWithJSONFromFileNamed:filename error:error];
}

+(NSArray*) testDataArrayWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error {

    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];

    NSAssert([jsonObj isKindOfClass:[NSArray class]], @"Expecting a [] as top level of the JSON data.");
    NSAssert(jsonObj, @"No instances found in JSON");
    NSAssert(!*error, @"Error parsing JSON: %@", *error);

    NSMutableArray *array = [NSMutableArray new];

    [jsonObj enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {

        TRTestData *i = [self testDataWithDict:obj];
        [array addObject:i];
    }];

    return array;
}

+(NSArray*) testDataArrayWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error {

    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];

    return [self testDataArrayWithJSONData:jsonData error:error];
}
-(NSMutableArray *) tags {

    if( ! _tags ) {
        _tags = [NSMutableArray new];
    }

    return _tags;
}
-(NSMutableArray *) friends {

    if( ! _friends ) {
        _friends = [NSMutableArray new];
    }

    return _friends;
}
-(NSMutableArray *) range {

    if( ! _range ) {
        _range = [NSMutableArray new];
    }

    return _range;
}

-(NSMutableDictionary*)additionalProperties {
    [NSException raise:@"Method not implemented" format:@"additionalProperties is not implemented. Additional property support was disabled when generating this class."];
    return nil;
}

-(void)setValue:(id)value forAdditionalProperty:(NSString*)propertyName {
    [NSException raise:@"Method not implemented" format:@"setValue:forAdditionalProperty: is not implemented. Additional property support was disabled when generating this class."];
}

-(id)valueForAdditionalProperty:(NSString*)propertyName {
    [NSException raise:@"Method not implemented" format:@"valueForAdditionalProperty is not implemented. Additional property support was disabled when generating this class."];
    return nil;
}
@end
