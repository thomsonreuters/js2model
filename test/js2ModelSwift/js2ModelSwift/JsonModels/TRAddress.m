
//
//  TRAddress.m
//
//  Created by js2Model on 2014-11-06.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import "TRAddress.h"
#import "TRJSONModelLoader.h"

#define valueWithSel(sel) [NSValue valueWithPointer: @selector(sel)]
@implementation TRAddressSchema

- (instancetype)init
{
    self = [super init];
    if (self) {




        [self.strings addEntriesFromDictionary: @{
        
                    @"county": [JSONPropertyMeta initWithGetter:@selector(county)
                                                             setter:@selector(setCounty:)],
        
                    @"city": [JSONPropertyMeta initWithGetter:@selector(city)
                                                             setter:@selector(setCity:)],
        
                    @"state": [JSONPropertyMeta initWithGetter:@selector(state)
                                                             setter:@selector(setState:)],
        
                    @"street": [JSONPropertyMeta initWithGetter:@selector(street)
                                                             setter:@selector(setStreet:)],
        
                    @"zip": [JSONPropertyMeta initWithGetter:@selector(zip)
                                                             setter:@selector(setZip:)],
        }];



    }
    return self;
}
@end

static TRAddressSchema *TRAddressSchemaInstance;

@implementation TRAddress{
    NSMutableDictionary *_additionalProperties;
}

+(void)initialize {

    if( self == [TRAddress class] )
    {
        TRAddressSchemaInstance = [TRAddressSchema new];
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

    return [TRAddressSchemaInstance objectForPropertyNamed:propertyName forInstance:self];
}

- (JSONInstanceMeta *)arrayForPropertyNamed:(NSString *)propertyName {
    return [TRAddressSchemaInstance arrayForPropertyNamed:propertyName forInstance:self];
}

- (void)setString:(NSString *)val forProperty:(NSString *)propertyName {
    [TRAddressSchemaInstance setString:val forProperty:propertyName forInstance:self];
}

- (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName {
    [TRAddressSchemaInstance setNumber:val forProperty:propertyName forInstance:self];
}

- (void)setInteger:(NSNumber *)val forProperty:(NSString *)propertyName {
    [TRAddressSchemaInstance setInteger:val forProperty:propertyName forInstance:self];
}

- (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName {
    [TRAddressSchemaInstance setBoolean:val forProperty:propertyName forInstance:self];
}

- (void)setNullForProperty:(NSString *)propertyName {
    [TRAddressSchemaInstance setNullForProperty:propertyName forInstance:self];
}

+(JSONModelSchema *)modelSchema {
    return TRAddressSchemaInstance ;
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
