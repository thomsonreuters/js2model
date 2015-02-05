======================
js2Model.py Reference
======================

**Version 0.1 Beta DRAFT**


Running it
~~~~~~~~~~
::

  usage: js2model.py [-h] [-l LANG] [--prefix PREFIX] [--rootname ROOTNAME] [-p]
                   [--additional] [--novalidate] [-o OUTPUT]
                   [--implements IMPLEMENTS] [--super SUPER]
                   [--import IMPORT_FILES] [-v] [--no-deserialize]
                   [--no-dependencies]
                   FILES [FILES ...]

        Generate native data models from JSON Schema definitions.

        positional arguments:
          FILES                 JSON Schema files for model generation

        optional arguments:
          -h, --help            show this help message and exit
          -l LANG, --lang LANG  language (default: objc)
          --prefix PREFIX       prefix for class names (default: TR)
          --rootname ROOTNAME   Class name for root schema object (default: fileName)
          -p, --primitives      Use primitive types in favor of object wrappers
          --additional          Include additionalProperties in models
          --novalidate          Skip schema validation
          -o OUTPUT, --output OUTPUT
                                Target directory of output files
          --implements IMPLEMENTS
                                Comma separated list of interface(s)|protocol(s)
                                supported by the generated classes
          --super SUPER         Comma separated list of super classes. Generated
                                classes inherit these
          --import IMPORT_FILES
                                Comma separated list of files to @import
          -v, --verbose         Print actions to STDOUT.
          --no-deserialize      Do not generate deserialization code. Implies --no-dependencies.
          --no-dependencies     Do not include dependencies in output.

A simple sample
---------------

Given the JSON schema definition:

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

js2Model will generate the class source files:

**address.h**

.. highlight:: objective-c
::

   @interface Address : NSObject <JSONModelSerialize>
   
   @property(strong, nonatomic) NSString * county;
   @property(strong, nonatomic) NSString * city;
   @property(strong, nonatomic) NSString * state;
   @property(strong, nonatomic) NSString * street;
   @property(strong, nonatomic) NSString * zip;
   
   @end


**address.m**

::

   @implementation Address{
       NSMutableDictionary *_additionalProperties;
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
   
   //
   // Code removed for clarity
   //
   
   @end


To deserialize JSON data into an instance of Address:

::

   NSError *error;
   
   NSData *jsonData = [self getSomeJSONFromSomewhere];
   
   Address *address = [Address alloc] initWithJSONData:data error:&error];
   
   if( !error ) {
         NSLog(@"Street = %@", address.street);
   }


.. automodule:: js2model
   :members:
