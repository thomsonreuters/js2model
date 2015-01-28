# js2Model.py Reference

Version 0.1 Beta <font color="red"><b>DRAFT</b></span>

## Goal

The goal of js2Model.py is to generate source code model classes from JSON schema definitions. Currently, only Objective-C is supported, but the script is architected in a such a way as to make it fairly easy to add new languages.

## Getting it

To install js2Model:

1) Clone the Mercurial repository

> ```
> $hg clone http://hg.int.thomsonreuters.com:9220/hg-wln/js2Model 
> ```

2) Install the python module  

> ```
> $cd js2Model
> $python setup.py install
> ```

3) Install the dependencies

> ```
> $pip install -r requirements.txt
> ```

## Running it

> <pre>
> js2model.py [-h] [-l LANG] [--prefix PREFIX] [--rootname ROOTNAME] [-p]
>                    [-x] [-o OUTPUT] [--implements IMPLEMENTS] [--super SUPER]
>                    [--import IMPORTFILES]
>                    FILES [FILES ...]
> 
> Generate native data models from JSON.
> 
> positional arguments:
>   FILES                 JSON files input for model generation
> 
> optional arguments:
>   -h, --help            show this help message and exit
>   -l LANG, --lang LANG  language (default: objc)
>   --prefix PREFIX       prefix for class names (default: TR)
>   --rootname ROOTNAME   Class name for root schema object (default: fileName)
>   -p, --primitives      Use primitive types in favor of object wrappers
>   -x, --noadditional    Do not include additionalProperties in models
>   -o OUTPUT, --output OUTPUT
>                         Target directory of output files
>   --implements IMPLEMENTS
>                         Comma separated list of interface(s)|protocol(s)
>                         supported by the generated classes
>   --super SUPER         Comma separated list of super classes. Generated
>                         classes inherit these
>   --import IMPORTFILES  Comma separated list of files to @import
> </pre>



## JSON Schema support

[JSON Schema draft 4](http://tools.ietf.org/html/draft-zyp-json-schema-04), the most up-to-date specification as of this writing, is currently supported.

The following table lists the support for JSON Schema keywords. js2Model.py will ignore unsupported keywords. 

| JSON Schema rule                                                                                           | Supported                       | Since | Note |
| -----------------------------------------------------------------------------------------------------------|:-------------------------------:|:-----:|------|
| [type (Simple)](#type)                                                                                     | <font color="green">Yes</font>  | 0.1.0 |      |
| [properties](#properties)                                                                                  | <font color="green">Yes</font>  | 0.1.0 |      |
| patternProperties                                                                                          | <font color="red">No</font>     |       |      |
| [additionalProperties](#additionalproperties)                                                              | <font color="green">Yes</font>  | 0.1.0 |      |
| [items](#items)                                                                                            |  <font color="green">Yes</font> | 0.1.0 |      |
| additionalItems                                                                                            | <font color="red">No</font>     |       |      |
| [required](#required)                                                                                      | <font color="green">Yes</font>  | 0.1.0 |      |
| [optional](#optional)                                                                                      | <font color="red">No</font>     | 0.1.0 | Deprecated |
| dependencies                                                                                               | <font color="red">No</font>     |       |      |
| [minimum, maximum](#minimummaximum-minitemsmaxitems-minlengthmaxlength-required-pattern)                   | <font color="green">Yes</font>  | 0.1.0 |      |
| exclusiveMinimum, exclusiveMaximum                                                                         | <font color="red">No</font>     |       |      |
| [minItems, maxItems](#minimummaximum-minitemsmaxitems-minlengthmaxlength-required-pattern)                 | <font color="green">Yes</font>  | 0.1.0 |      |
| [uniqueItems](#uniqueitems)                                                                                | <font color="green">Yes</font>  | 0.1.0 |      |
| [pattern](#minimummaximum-minitemsmaxitems-minlengthmaxlength-required-pattern)                            | <font color="red">No</font>     |       |      |
| [minLength, maxLength](#minimummaximum-minitemsmaxitems-minlengthmaxlength-required-pattern)               | <font color="green">Yes</font>  | 0.1.0 |      |
| [enum](#enum)                                                                                              | <font color="green">Yes</font>  | 0.1.0 |      |
| [default](#default)                                                                                        | <font color="green">Yes</font>  | 0.1.0 |      |
| [title](#title)                                                                                            | <font color="green">Yes</font>  | 0.1.0 |      |
| [description](#description)                                                                                | <font color="green">Yes</font>  | 0.1.0 |      |
| [format](#format)                                                                                          | <font color="green">Yes</font>  | 0.1.0 |      |
| divisibleBy                                                                                                | <font color="red">No</font>     |       |      |
| disallow                                                                                                   | <font color="red">No</font>     |       |      |
| [extends](#extends)                                                                                        | <font color="green">Yes</font>  | 0.1.0 |      |
| id                                                                                                         | <font color="red">No</font>     |       |      |
| [$ref](#ref)                                                                                               | <font color="green">Yes</font>  | 0.1.0 | Supports absolute, relative, slash & dot delimited fragment paths, self-ref |
| $schema                                                                                                    | <font color="red">No</font>     |       |      |

## properties

For each property in the properties section of an object, a property is added to the generated class.

#### Objective-C

Properties for object types are declared as

> <pre> 
> @property(strong, nonatomic) NSNumber *myProperty;
> </pre>

Modern Objective-C auto syntheseis of a properties iVar, getter and setter is assumed by the code generation, implemetation files can usually be trivial.

As a convenience, NSArrays will be initialized, but lazily -

> <pre>
> -(NSArray *) myArray {
> 	
> 	if( ! _myArray ) {
> 		_myArray = [NSArray new];
> 	}
> 	return _myArray;
> }
> </pre>


## type

Types get mapped as follows;

| Schema type                         | Objective-c type             |
| ------------------------------------| -----------------------------|
| `string`                            | `String *`                   |
| `number`                            | `NSNumber *`                 |
| `integer`                           | `NSNumber *`                 |
| `boolean`                           | `NSNumber *`                 |
| `object`                            | _generated Objective-C type_ |
| `array`                             | `NSArray *`                  |
| `array` (with `"uniqueItems":true`) | `NSArray *`                  |
| `null`                              | `Object *`                   |
| `any`                               | `Object *`                   |


## <font color="red"> Incomplete - many more details need to be added :-)</font>

