======================
js2Model.py Reference
======================

**Version 0.1 Beta DRAFT**


Running it
~~~~~~~~~~
::

  js2model.py [-h] [-l LANG] [--prefix PREFIX] [--rootname ROOTNAME] [-p]
                     [-x] [-o OUTPUT] [--implements IMPLEMENTS] [--super SUPER]
                     [--import IMPORTFILES]
                     FILES [FILES ...]
  
  Generate native data models from JSON.
  
  positional arguments:
    FILES                 JSON files input for model generation
  
  optional arguments:
    -h, --help            show this help message and exit
    -l LANG, --lang LANG  language (default: objc)
    --prefix PREFIX       prefix for class names (default: TR)
    --rootname ROOTNAME   Class name for root schema object (default: fileName)
    -p, --primitives      Use primitive types in favor of object wrappers
    -x, --additional    Do not include additionalProperties in models
    -o OUTPUT, --output OUTPUT
                          Target directory of output files
    --implements IMPLEMENTS
                          Comma separated list of interface(s)|protocol(s)
                          supported by the generated classes
    --super SUPER         Comma separated list of super classes. Generated
 
    --import IMPORTFILES  Comma separated list of files to @import

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
