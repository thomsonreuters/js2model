//
// Created by Kevin on 10/25/14.
// Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import "JSONModelSchema.h"
#import "JSONMorphoModel.h"

@implementation JSONPropertyMeta

-(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter type:(Class) type itemType:(Class) itemType {
    
    self = [super init];
    if (self) {
        _getter = getter;
        _setter = setter;
        _type = type;
        _itemType = itemType;
        _isArray = type == [NSMutableArray class] ? YES : NO;
    }
    return self;
}

-(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter type:(Class) type {
    
    return [self initWithGetter:getter setter:setter type:type itemType:nil];
}

-(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter {
    return [self initWithGetter:getter setter:setter type:nil];
}

-(instancetype)initAsArrayWithItemType:(Class) itemType {
    self = [self initWithGetter:nil setter:nil type:[NSMutableArray class] itemType:itemType];
    
    if(self) {
        _isArray = YES;
    }
    return self;
}


-(id)newObject {
    return [[self.type alloc] init];
}

-(id)newItemObject {
    return self.itemType ? [[self.itemType alloc] init] : nil;
}

+(instancetype)propertyMetaWithGetter:(SEL)getter setter:(SEL)setter type:(Class) type itemType:(Class) itemType {
    return [[JSONPropertyMeta alloc] initWithGetter:getter setter:setter type:type itemType:itemType];
}

+(instancetype)propertyMetaWithGetter:(SEL)getter setter:(SEL)setter type:(Class) initBlock {
    return [[JSONPropertyMeta alloc] initWithGetter:getter setter:setter type:initBlock];
}

+(instancetype)propertyMetaWithGetter:(SEL)getter setter:(SEL)setter {
    return [[JSONPropertyMeta alloc] initWithGetter:getter setter:setter];
}

+(instancetype)propertyMetaAsArrayWithItemType:(Class)itemType {
    return [[self alloc] initAsArrayWithItemType:itemType];
}

@end

@implementation JSONInstanceMeta

-(instancetype)initWithInstance:(id)instance propertyMeta:(JSONPropertyMeta *)propertyMeta {
    self = [super init];
    if (self) {
        _instance = instance;
        _propertyMeta = propertyMeta;
    }
    return self;
}

+(instancetype)initWithInstance:(id)instance propertyMeta:(JSONPropertyMeta *)propertyMeta {
    return [[JSONInstanceMeta alloc] initWithInstance:instance propertyMeta:propertyMeta];
}

@end

@implementation JSONModelSchema {

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

- (JSONInstanceMeta *)objectForPropertyNamed:(NSString *)propertyName forInstance:(id)instance from:(NSDictionary *)propertySet {
    
    JSONPropertyMeta *propMeta = [propertySet valueForKey:propertyName];

    if (!propMeta) {
        
        NSLog(@"Object for property named '%@' not found in schema %@. Adding to additionalProperties.", propertyName, NSStringFromClass([instance class]));

        propMeta = [[JSONPropertyMeta alloc] initWithGetter:@selector(valueForKey:) setter:@selector(setValue:forKey:)];

        NSMutableDictionary *additionalProperties = [instance additionalProperties];
        
        id obj = [additionalProperties valueForKey:propertyName];
        
        if( !obj ) {
            obj = [JSONMorphoModel new];
            [additionalProperties setValue:obj forKey:propertyName];
        }
        
        return [JSONInstanceMeta initWithInstance:obj propertyMeta:propMeta];
    }
    else if (propMeta.getter) {
        
        id obj = [instance performSelector:propMeta.getter];
        
        if( !obj ) {
            obj = [propMeta newObject];

            NSAssert(propMeta.setter, @"Expecting a getter for %@", propertyName);
            
            if(propMeta.setter) {
                [instance performSelector:propMeta.setter withObject:obj];
            }
        }
        
        return [JSONInstanceMeta initWithInstance:obj propertyMeta:propMeta];
    }
    else {
        NSAssert(NO, @"Shouldn't get here. Something wrong for property named '%@'.", propertyName);
    }
    return nil;
}

- (JSONInstanceMeta *)objectForPropertyNamed:(NSString *)propertyName forInstance:(id)instance {

    return [self objectForPropertyNamed:propertyName forInstance:instance from:self.objects];
}

- (JSONInstanceMeta *)arrayForPropertyNamed:(NSString *)propertyName forInstance:(id)instance {

    return [self objectForPropertyNamed:propertyName forInstance:instance from:self.arrays];
}

- (void)setValue:(id)val forProperty:(NSString *)propertyName forInstance:(id)instance inPropertySet:(NSDictionary *)propertySet{
    
    SEL setter = [self setterForProperty:propertyName from:propertySet];
    
    if(setter) {
        [instance performSelector:setter withObject:val];
    }
    else {
        NSLog(@"Setter for property named '%@' not found. Adding to additionalProperties", propertyName);
        [[instance additionalProperties] setValue:val forKey:propertyName];
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