+++++++++++++++++++++++++++++++
 Quick Start
+++++++++++++++++++++++++++++++

Four simple steps to native model goodness:

1. Get (or create) `JSON Schema <http://json-schema.org>`_ file(s) for you JSON data.
2. Run js2model to generate your models' source code.
3. Add the generated source files to your project.
4. Use the models.


Get (or Create) JSON Schema
----------------------------

For purpose of this example, we'll use the following JSON Schema. Let's assume a file name of *quickstart.schema.json*.

.. highlight:: javascript

::

   {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "title": "address",
      "type": "object",
      "properties": {
         "street": { "type": "string" },
         "city": { "type": "string" },
         "county": { "type": "string" },
         "state": { "type": "string" },
         "zip": { "type": "string" }
      }
   }

Run js2model
------------

Run js2Model to generate the model source files:

.. highlight:: shell

::

   js2model -o output quickstart.schema.json

Add the generated source code files and dependencies to your project
---------------------------------------------------------------------

The command from the previous step will output the following files:

::

   output
   ├── ISO8601DateFormatter.h
   ├── ISO8601DateFormatter.m
   ├── JSONModelSchema.h
   ├── JSONModelSchema.m
   ├── JSONModelSerialize.h
   ├── JSONMorphoModel.h
   ├── JSONMorphoModel.m
   ├── TRJSONModelLoader.h
   ├── TRJSONModelLoader.m
   ├── TRModels.h
   ├── TRQuickstart.h
   ├── TRQuickstart.m
   └── dependencies
       └── yajl
           ├── api
           │   ├── yajl_common.h
           │   ├── yajl_gen.h
           │   ├── yajl_parse.h
           │   ├── yajl_tree.h
           │   └── yajl_version.h
           ├── yajl.c
           ├── yajl_alloc.c
           ├── yajl_alloc.h
           ├── yajl_buf.c
           ├── yajl_buf.h
           ├── yajl_bytestack.h
           ├── yajl_encode.c
           ├── yajl_encode.h
           ├── yajl_gen.c
           ├── yajl_lex.c
           ├── yajl_lex.h
           ├── yajl_parser.c
           ├── yajl_parser.h
           ├── yajl_tree.c
           └── yajl_version.c
   
Add all of these files to your project. 

Most of these source files are static dependencies. For this simple example, one model was generated, resulting in three files - *TRQuickstart.h*, *TRQuickstart.m*, and *TRModels.h*.

*TRModels.h* is a convenience header that contains #includes for all of the generated model header files.

.. highlight:: objective-c

::

   //
   //  TRModels.h
   //
   //  Created by js2Model on {{ timestamp }}.
   //  Copyright (c) 2014 Thomson Reuters. All rights reserved.
   //
   
      #import "TRQuickstart.h"



*TRQuickstart.h* is the header file containing the interface declaration for the TRQuickstart model.

.. highlight:: objective-c

::

   //
   //  TRQuickstart.h
   //
   //  Created by js2Model on 2015-02-04.
   //  Copyright (c) 2014 Thomson Reuters. All rights reserved.
   //
   
   #import <Foundation/Foundation.h>
   #import "JSONModelSchema.h"
   
   @interface TRQuickstartSchema : JSONModelSchema
   @end
   
   @interface TRQuickstart : NSObject <JSONModelSerialize>
   
   @property(strong, nonatomic) NSNumber * county;
   @property(strong, nonatomic) NSNumber * city;
   @property(strong, nonatomic) NSNumber * state;
   @property(strong, nonatomic) NSNumber * street;
   @property(strong, nonatomic) NSNumber * zip;
   
   @end


*TRQuickstart.m* is the implementation file for the TRQuickstart model.

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


Use the models
--------------

Load some JSON data into a model:

::

   NSError *error;
   
   NSData *jsonData = [self getSomeJSONFromSomewhere];
   
   TRQuickstart *model [TRQuickstart quickstartWithJSONData:data error:&error];
   
   if( !error ) {
         NSLog(@"Street = %@", model.street);
   }


Or load JSON from a file into a model:

::

   NSError *error;
   
   TRQuickstart *model [TRQuickstart testDataArrayWithJSONFromFileNamed:@"mydata.json" error:&error];
   
   if( !error ) {
         NSLog(@"Street = %@", model.street);
   }


