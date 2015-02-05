+++++++++++++++++++++++++++++++
 Quick Start
+++++++++++++++++++++++++++++++

.. toctree::
   :hidden:

   TRModels_h
   TRQuickstart_h
   TRQuickstart_m

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

`TRModels.h <TRModels_h.html>`_ is a convenience header that contains #includes for all of the generated model header files.

`TRQuickstart.h <TRQuickstart_h.html>`_ is the header file containing the interface declaration for the TRQuickstart model.

`TRQuickstart.m <TRQuickstart_m.html>`_ is the implementation file for the TRQuickstart model.

        **Notes**

        * Models are prefixed with "TR" by default. You can change the prefix string with the *--prefix* command line option.

        * js2model uses `YAJL <https://lloyd.github.io/yajl/>`_ to parse JSON for C family languages. It is bundled with the generated source as a convenience. You can exclude the YAJL files with the *--no_dependencies* command line option.


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


