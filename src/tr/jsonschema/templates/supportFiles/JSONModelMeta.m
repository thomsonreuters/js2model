//
// Created by Kevin on 10/25/14.
// Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import "JSONModelMeta.h"

@implementation JSONPropertyMeta

-(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter initBlock:(initBlockType) initBlock {
    
    self = [super init];
    if (self) {
        _getter = getter;
        _setter = setter;
        self.initBlock = initBlock;
    }
    return self;
}

-(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter {
    return [self initWithGetter:getter setter:setter initBlock:nil];
}

+(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter initBlock:(initBlockType) initBlock {
    return [[JSONPropertyMeta alloc] initWithGetter:getter setter:setter initBlock:initBlock];
}

+(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter {
    return [[JSONPropertyMeta alloc] initWithGetter:getter setter:setter];
}

@end

@implementation JSONModelMeta {

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _objects = [NSMutableDictionary new];

        _arrays = [NSMutableDictionary new];

        _strings = [NSMutableDictionary new];

        _booleans = [NSMutableDictionary new];

        _integers = [NSMutableDictionary new];

        _numbers = [NSMutableDictionary new];
    }
    return self;
}

-(BOOL)propertyIsObject:(NSString *)propertyName {
    return [self.objects valueForKey:propertyName] != nil ? YES : NO;
}

-(BOOL)propertyIsArray:(NSString *)propertyName {
    return [self.arrays valueForKey:propertyName] != nil ? YES : NO;
}

-(SEL)getterForProperty:(NSString *)propertyName from:(NSDictionary*)propertieSet {
    JSONPropertyMeta *propMeta = [propertieSet valueForKey:propertyName];
    return propMeta ?  propMeta.getter : NULL;
}

-(SEL)setterForProperty:(NSString *)propertyName from:(NSDictionary*)propertieSet {
    JSONPropertyMeta *propMeta = [propertieSet valueForKey:propertyName];
    return propMeta ?  propMeta.setter : NULL;
}

-(SEL)setterForProperty:(NSString *)propertyName {
    
    for (NSDictionary *props in @[self.objects, self.arrays, self.integers, self.numbers, self.booleans, self.strings] ) {
        
        JSONPropertyMeta *propMeta = [props valueForKey:propertyName];
        return propMeta ?  propMeta.setter : NULL;
    }
    
    return NULL;
}

//-(SEL)objectGetterForProperty:(NSString *)propertyName {
//
//    return [self getterForProperty:propertyName from:self.objects];
//}
//
//-(SEL)arrayGetterForProperty:(NSString *)propertyName {
//
//    return [self getterForProperty:propertyName from:self.arrays];
//}
//
//-(SEL)numberSetterForProperty:(NSString *)propertyName {
//
//    return [self setterForProperty:propertyName from:self.numbers];
//}
//
//-(SEL)stringSetterForProperty:(NSString *)propertyName {
//
//    return [self setterForProperty:propertyName from:self.strings];
//}
//
//-(SEL)booleanSetterForProperty:(NSString *)propertyName {
//
//    return [self setterForProperty:propertyName from:self.booleans];
//}
//
//-(SEL)integerSetterForProperty:(NSString *)propertyName {
//
//    return [self setterForProperty:propertyName from:self.integers];
//}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (id)objectForPropertyNamed:(NSString *)propertyName forInstance:(id)instance from:(NSDictionary *)propertySet {
    
    JSONPropertyMeta *propMeta = [propertySet valueForKey:propertyName];
    
    NSAssert(propMeta.getter, @"Expecting a getter for %@", propertyName);
    
    if (propMeta.getter) {
        
        id obj = [instance performSelector:propMeta.getter];
        
        if( !obj ) {
            obj = [propMeta initBlock];

            NSAssert(propMeta.setter, @"Expecting a getter for %@", propertyName);
            
            if(propMeta.setter) {
                [instance performSelector:propMeta.setter withObject:obj];
            }
        }
        
        return obj;
        
    }
    else {
        NSLog(@"Object for property named '%@' not found.", propertyName);
    }
    return nil;
}

- (id <JSONModelSerialize>)objectForPropertyNamed:(NSString *)propertyName forInstance:(id)instance {

    return [self objectForPropertyNamed:propertyName forInstance:instance from:self.objects];
}

- (NSMutableArray *)arrayForPropertyNamed:(NSString *)propertyName forInstance:(id)instance {

    return [self objectForPropertyNamed:propertyName forInstance:instance from:self.arrays];
}

- (void)setValue:(id)val forProperty:(NSString *)propertyName forInstance:(id)instance inPropertySet:(NSDictionary *)propertySet{
    
    SEL setter = [self setterForProperty:propertyName from:propertySet];
    
    if(setter) {
        [instance performSelector:setter withObject:val];
    }
    else {
        NSLog(@"Setter for property named '%@' not found.", propertyName);
    }
}

- (void)setString:(NSString *)val forProperty:(NSString *)propertyName forInstance:(id)instance {

    [self setValue:val forProperty:propertyName forInstance:instance inPropertySet:self.strings];
}

- (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance {

    [self setValue:val forProperty:propertyName forInstance:instance inPropertySet:self.numbers];
}

- (void)setInteger:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance {

    [self setValue:val forProperty:propertyName forInstance:instance inPropertySet:self.integers];
}

- (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance {

    [self setValue:val forProperty:propertyName forInstance:instance inPropertySet:self.booleans];
}

- (void)setNullForProperty:(NSString *)propertyName forInstance:(id)instance {

    SEL setter = [self setterForProperty:propertyName];

    if(setter) {
        [instance performSelector:setter withObject:nil];
    }
    else {
        NSLog(@"Setter for null property named '%@' not found.", propertyName);
    }
}

#pragma clang diagnostic pop

@end