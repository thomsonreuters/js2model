

//
//  TRFriends.m
//
//  Created by js2Model on 2015-02-24.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import "TRFriends.h"

@implementation TRFriends{
}


-(instancetype)initWithDict:(NSDictionary *)dict {
    self = [self init];
    if (self) {

        self.name = dict[@"name"];

        self.id_ = dict[@"id"];
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
+(instancetype) friendsWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

+(instancetype) friendsWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error {

    return [[self alloc] initWithJSONData:data error:error];
}

+(instancetype) friendsWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error {

    return [[self alloc] initWithJSONFromFileNamed:filename error:error];
}

+(NSArray*) friendsArrayWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error {

    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];

    NSAssert([jsonObj isKindOfClass:[NSArray class]], @"Expecting a [] as top level of the JSON data.");
    NSAssert(jsonObj, @"No instances found in JSON");
    NSAssert(!*error, @"Error parsing JSON: %@", *error);

    NSMutableArray *array = [NSMutableArray new];

    [jsonObj enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {

        TRFriends *i = [self friendsWithDict:obj];
        [array addObject:i];
    }];

    return array;
}

+(NSArray*) friendsArrayWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error {

    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];

    return [self friendsArrayWithJSONData:jsonData error:error];
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
