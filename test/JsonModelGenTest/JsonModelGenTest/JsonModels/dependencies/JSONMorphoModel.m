
//
//  JSONMorphoModel.m
//
//  Created by js2Model on 2014-11-05.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import "JSONMorphoModel.h"
#import "TRJSONModelLoader.h"
#import "JSONModelSerialize.h"

@implementation JSONMorphoModelSchema

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

@end

static JSONMorphoModelSchema *JSONMorphoModelSchemaInstance;

@implementation JSONMorphoModel{
    NSMutableDictionary *_additionalProperties;
}

+(void)initialize {

    if( self == [JSONMorphoModel class] )
    {
        JSONMorphoModelSchemaInstance = [JSONMorphoModelSchema new];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    	// custom intialization code
        _additionalProperties = [NSMutableDictionary new];
    }
    return self;
}


- (instancetype) initWithJSONData:(NSData *)data
                            error:(NSError* __autoreleasing *)error {
    self = [self init];
    if (self) {
        [TRJSONModelLoader load:self withJSONData:data error:error];
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

    self = [self init];
    if (self) {
        [TRJSONModelLoader load:self withJSONFromFileNamed:filename error:error];
    }
    return self;
}

- (JSONInstanceMeta *)objectForPropertyNamed:(NSString *)propertyName {

    return [JSONMorphoModelSchemaInstance objectForPropertyNamed:propertyName forInstance:self];
}

- (JSONInstanceMeta *)arrayForPropertyNamed:(NSString *)propertyName {
    return [JSONMorphoModelSchemaInstance arrayForPropertyNamed:propertyName forInstance:self];
}

- (void)setString:(NSString *)val forProperty:(NSString *)propertyName {
    [JSONMorphoModelSchemaInstance setString:val forProperty:propertyName forInstance:self];
}

- (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName {
    [JSONMorphoModelSchemaInstance setNumber:val forProperty:propertyName forInstance:self];
}

- (void)setInteger:(NSNumber *)val forProperty:(NSString *)propertyName {
    [JSONMorphoModelSchemaInstance setInteger:val forProperty:propertyName forInstance:self];
}

- (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName {
    [JSONMorphoModelSchemaInstance setBoolean:val forProperty:propertyName forInstance:self];
}

- (void)setNullForProperty:(NSString *)propertyName {
    [JSONMorphoModelSchemaInstance setNullForProperty:propertyName forInstance:self];
}

+(JSONModelSchema *)modelSchema {
    return JSONMorphoModelSchemaInstance;
}

-(NSMutableDictionary*)additionalProperties {
    return _additionalProperties;
}

-(void)setValue:(id)value forAdditionalProperty:(NSString*)propertyName {
    [_additionalProperties setObject:value forKey:propertyName];
}

-(id)valueForAdditionalProperty:(NSString*)propertyName {
    return [_additionalProperties valueForKey:propertyName];
}

@end
