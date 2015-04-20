+++++++++++++++++++++++++++++++
 Quick Start
+++++++++++++++++++++++++++++++

.. toctree::
   :hidden:

   TRModels_h
   TRQuickstart_h
   TRQuickstart_m

Four simple steps to native model goodness:

1. Installation
2. Get (or create) `JSON Schema <http://json-schema.org>`_ file(s) for you JSON data.
3. Run js2model to generate your models' source code.
4. Add the generated source files to your project.
5. Use the models.

Installation
============

Install from PyPI
-----------------

Run the pip install command:

.. highlight:: shell

::

        pip install js2model

Install from source
-------------------

Clone the repository from github, install the dependencies, then run the setup.py script:

.. highlight:: shell

::

        git clone git@github.com:thomsonreuters/js2model.git

        cd js2model

        pip install -r requirements.txt

        python setup.py install


Get JSON Schema describing your JSON
===============================================

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

Creating JSON Schema from scratch
---------------------------------

If you do not already have a JSON Schema definition for your JSON, it can be tedious to create it. Fortunately you can automatically create schema files from JSON data using `GenSON <http://goo.gl/z0FMel>`_.  GenSON (rhymes with Gen Con) is a powerful, user-friendly JSON Schema generator built in Python. See the docs for more details.

Run js2model
============

Run js2Model to generate the model source files:

.. highlight:: shell

::

   js2model -o output quickstart.schema.json

Add the generated source code files and dependencies to your project
=====================================================================

The command from the previous step will output the following files:

::

        ── output
            ├── TRModels.h
            ├── TRQuickstart.h
            └── TRQuickstart.m
   
Add all of these files to your project. 

For this simple example, one model was generated, resulting in three files - *TRQuickstart.h*, *TRQuickstart.m*, and *TRModels.h*.

`TRModels.h <TRModels_h.html>`_ is a convenience header that contains #includes for all of the generated model header files.

`TRQuickstart.h <TRQuickstart_h.html>`_ is the header file containing the interface declaration for the TRQuickstart model.

`TRQuickstart.m <TRQuickstart_m.html>`_ is the implementation file for the TRQuickstart model.

        **Notes**

        * Models are prefixed with "TR" by default. You can change the prefix string with the *--prefix* command line option.

        * js2model uses `NSJSONSerialization <http://goo.gl/WsJCxL>`_ to parse JSON for Objective C.


Use the models in your code.
============================

Load some JSON data into a model:

::

   NSError *error;
   
   NSData *jsonData = [self getSomeJSONFromSomewhere];
   
   TRQuickstart *model = [TRQuickstart quickstartWithJSONData:data error:&error];
   
   if( !error ) {
         NSLog(@"Street = %@", model.street);
   }


Or load JSON from a file into a model:

::

   NSError *error;
   
   TRQuickstart *model = [TRQuickstart quickstartWithJSONFromFileNamed:@"mydata.json" error:&error];
   
   if( !error ) {
         NSLog(@"Street = %@", model.street);
   }


