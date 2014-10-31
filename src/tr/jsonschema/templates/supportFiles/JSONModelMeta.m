//
// Created by Kevin on 10/25/14.
// Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import "JSONModelMeta.h"


@implementation JSONModelMeta {

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _objectSetters = [NSMutableDictionary new];

        _arraySetters = [NSMutableDictionary new];

        _objectGetters = [NSMutableDictionary new];

        _arrayGetters = [NSMutableDictionary new];

        _strings = [NSMutableDictionary new];

        _booleans = [NSMutableDictionary new];

        _integers = [NSMutableDictionary new];

        _numbers = [NSMutableDictionary new];
    }
    return self;
}

-(BOOL)propertyIsObject:(NSString *)propertyName {
    return [self.objectGetters valueForKey:propertyName] != nil ? YES : NO;
}

-(BOOL)propertyIsArray:(NSString *)propertyName {
    return [self.arrayGetters valueForKey:propertyName] != nil ? YES : NO;
}

-(SEL)objectGetterSelectorForProperty:(NSString *)propertyName {

    NSValue *value = [self.objectGetters valueForKey:propertyName];

    if( value ) {
        return [value pointerValue];
    }
    else {
        return NULL;
    }
}

-(SEL)arrayGetterSelectorForProperty:(NSString *)propertyName {

    NSValue *value = [self.arrayGetters valueForKey:propertyName];

    if( value ) {
        return [value pointerValue];
    }
    else {
        return NULL;
    }
}

-(SEL)numberSetterSelectorForProperty:(NSString *)propertyName {

    NSValue *value = [self.numbers valueForKey:propertyName];

    if( value ) {
        return [value pointerValue];
    }
    else {
        return NULL;
    }
}

-(SEL)stringSetterSelectorForProperty:(NSString *)propertyName {

    NSValue *value = [self.strings valueForKey:propertyName];

    if( value ) {
        return [value pointerValue];
    }
    else {
        return NULL;
    }
}

-(SEL)booleanSetterSelectorForProperty:(NSString *)propertyName {

    NSValue *value = [self.booleans valueForKey:propertyName];

    if( value ) {
        return [value pointerValue];
    }
    else {
        return NULL;
    }
}

-(SEL)integerSetterSelectorForProperty:(NSString *)propertyName {

    NSValue *value = [self.integers valueForKey:propertyName];

    if( value ) {
        return [value pointerValue];
    }
    else {
        return NULL;
    }
}


-(SEL)setterForProperty:(NSString *)propertyName {

    for (NSArray *props in @[self.objectSetters, self.arraySetters, self.integers, self.numbers, self.booleans, self.strings] ) {
        
        NSValue *value = [props valueForKey:propertyName];
        
        if( value ) {
            return [value pointerValue];
        }
    }
    
    return NULL;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (id <JSONModelSerialize>)getObjectForPropertyNamed:(NSString *)propertyName forInstance:(id)instance {

    SEL getter = [self objectGetterSelectorForProperty:propertyName];

    if (getter) {
        return [instance performSelector:getter];
    }
    else {
        NSLog(@"Object for property named '%@' not found.", propertyName);
    }
    return nil;
}

- (NSMutableArray *)getArrayForPropertyNamed:(NSString *)propertyName forInstance:(id)instance {
    SEL getter = [self arrayGetterSelectorForProperty:propertyName];

    if (getter) {
        return [instance performSelector:getter];
    }
    else {
        NSLog(@"Array for property named '%@' not found.", propertyName);
    }
    return nil;
}

- (void)setString:(NSString *)val forProperty:(NSString *)propertyName forInstance:(id)instance {

    SEL setter = [self stringSetterSelectorForProperty:propertyName];

    if(setter) {
        [instance performSelector:setter withObject:val];
    }
    else {
        NSLog(@"Setter for string property named '%@' not found.", propertyName);
    }
}

- (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance {

    SEL setter = [self numberSetterSelectorForProperty:propertyName];

    if(setter) {
        [instance performSelector:setter withObject:val];
    }
    else {
        NSLog(@"Setter for number property named '%@' not found.", propertyName);
    }
}

- (void)setInteger:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance {

    SEL setter = [self integerSetterSelectorForProperty:propertyName];

    if(setter) {
        [instance performSelector:setter withObject:val];
    }
    else {
        NSLog(@"Setter for double property named '%@' not found.", propertyName);
    }

}

- (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance {

    SEL setter = [self booleanSetterSelectorForProperty:propertyName];

    if(setter) {
        [instance performSelector:setter withObject:val];
    }
    else {
        NSLog(@"Setter for boolean property named '%@' not found.", propertyName);
    }

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