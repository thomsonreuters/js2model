//
// Created by Kevin on 10/25/14.
// Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModelSerialize.h"

typedef id (^initBlockType)(void);

@interface JSONPropertyMeta : NSObject

@property (nonatomic) SEL getter;
@property (nonatomic) SEL setter;
@property (nonatomic) Class type;
@property (nonatomic) BOOL isArray;
@property (nonatomic) Class itemType;

-(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter type:(Class) type itemType:(Class) itemType;
-(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter type:(Class) type;
-(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter;

-(id)newObject;
-(id)newItemObject;

+(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter type:(Class) type itemType:(Class) itemType;
+(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter type:(Class) type;
+(instancetype)initWithGetter:(SEL)getter setter:(SEL)setter;

@end


@interface JSONInstanceMeta : NSObject

@property (strong, nonatomic) id instance;
@property (strong, nonatomic) JSONPropertyMeta *propertyMeta;

-(instancetype)initWithInstance:(id)instance propertyMeta:(JSONPropertyMeta *)propertyMeta;

+(instancetype)initWithInstance:(id)instance propertyMeta:(JSONPropertyMeta *)propertyMeta;

@end


@interface JSONModelMeta : NSObject

@property(strong, nonatomic) NSMutableDictionary *objects;
@property(strong, nonatomic) NSMutableDictionary *arrays;
@property(strong, nonatomic) NSMutableDictionary *strings;
@property(strong, nonatomic) NSMutableDictionary *booleans;
@property(strong, nonatomic) NSMutableDictionary *integers;
@property(strong, nonatomic) NSMutableDictionary *numbers;

-(BOOL)propertyIsObject:(NSString *)propertyName;

-(BOOL)propertyIsArray:(NSString *)propertyName;

//-(SEL)objectGetterForProperty:(NSString *)propertyName;
//
//-(SEL)arrayGetterForProperty:(NSString *)propertyName;
//
//-(SEL)numberSetterForProperty:(NSString *)propertyName;
//
//-(SEL)stringSetterForProperty:(NSString *)propertyName;
//
//-(SEL)booleanSetterForProperty:(NSString *)propertyName;
//
//-(SEL)integerSetterForProperty:(NSString *)propertyName;

// Searches all data types for property setter
-(SEL)setterForProperty:(NSString *)propertyName;

- (JSONInstanceMeta *)objectForPropertyNamed:(NSString *)propertyName forInstance:(id)instance;

- (JSONInstanceMeta *)arrayForPropertyNamed:(NSString *)propertyName forInstance:(id)instance;

- (void)setString:(NSString *)val forProperty:(NSString *)propertyName forInstance:(id)instance;

- (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance;

- (void)setInteger:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance;

- (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance;

- (void)setNullForProperty:(NSString *)propertyName forInstance:(id)instance;

@end