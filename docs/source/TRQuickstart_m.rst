=========================
TRQuickstart.m
=========================

.. highlight:: objective-c

::

   //
   //  TRQuickstart.m
   //
   //  Created by js2Model on 2015-02-04.
   //  Copyright (c) 2014 Thomson Reuters. All rights reserved.
   //
   
   #import "TRQuickstart.h"
   #import "TRJSONModelLoader.h"
   
   #define valueWithSel(sel) [NSValue valueWithPointer: @selector(sel)]
   
   @implementation TRQuickstartSchema
   
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
   
   static TRQuickstartSchema *TRQuickstartSchemaInstance;
   
   @implementation TRQuickstart{
   }
   
   +(void)initialize {
   
       if( self == [TRQuickstart class] )
       {
           TRQuickstartSchemaInstance = [TRQuickstartSchema new];
       }
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
   
       return [TRQuickstartSchemaInstance objectForPropertyNamed:propertyName forInstance:self];
   }
   
   - (JSONInstanceMeta *)arrayForPropertyNamed:(NSString *)propertyName {
       return [TRQuickstartSchemaInstance arrayForPropertyNamed:propertyName forInstance:self];
   }
   
   - (void)setString:(NSString *)val forProperty:(NSString *)propertyName {
       [TRQuickstartSchemaInstance setString:val forProperty:propertyName forInstance:self];
   }
   
   - (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName {
       [TRQuickstartSchemaInstance setNumber:val forProperty:propertyName forInstance:self];
   }
   
   - (void)setInteger:(NSNumber *)val forProperty:(NSString *)propertyName {
       [TRQuickstartSchemaInstance setInteger:val forProperty:propertyName forInstance:self];
   }
   
   - (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName {
       [TRQuickstartSchemaInstance setBoolean:val forProperty:propertyName forInstance:self];
   }
   
   - (void)setNullForProperty:(NSString *)propertyName {
       [TRQuickstartSchemaInstance setNullForProperty:propertyName forInstance:self];
   }
   
   +(JSONModelSchema *)modelSchema {
       return TRQuickstartSchemaInstance ;
   }
   
   -(NSMutableDictionary*)additionalProperties {
       [NSException raise:@"Method not implemented" format:@"additionalProperties is not implemented. Additional property support was disabled when generating this class."];
       return nil;
   }
   
   -(void)setValue:(id)value forAdditionalProperty:(NSString*)propertyName {
       [NSException raise:@"Method not implemented" format:@"setValue:forAdditionalProperty: is not implemented". Additional property support was disabled when generating this class.];
   }
   
   -(id)valueForAdditionalProperty:(NSString*)propertyName {
       [NSException raise:@"Method not implemented" format:@"valueForAdditionalProperty is not implemented". Additional property support was disabled when generating this class.];
       return nil;
   }
   @end

