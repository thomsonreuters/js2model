//
//  JsonMorphoModel.swift
//  js2ModelSwift
//
//  Created by Kevin on 11/10/14.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

import Foundation


//
//  TRPerson.m
//
//  Created by js2Model on 2014-11-05.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

public class JsonMorphoModelSchema : JsonModelSchema<JsonMorphoModel> {
    
    init() { }
}

var JsonMorphoSchemaInstance: JsonMorphoModelSchema = JsonMorphoModelSchema();

class JsonMorphoModel : JsonModelSerialize {

    typealias ModelType = JsonMorphoModel

    var additionalProperties: [String: Any]

    
    required init() {
        
    }

    convenience required init(jsonData:[Byte]) {
        self.init()
    }
    
    convenience required init(filename:String) {
        self.init()
    }
    
    class func modelSchema() -> JsonModelSchema<ModelType> {
        return JsonMorphoSchemaInstance;
    }

    func set(string val:String, forProperty propertyName:String)
    func set(number val:Double, forProperty propertyName: String)
    func set(integer val:Int, forProperty propetyName:String)
    func set(boolean val:Bool, forProperty propetyName:String)
    func setNil(forProperty propertyName:String)
    
    var additionalProperties: [String: Any] { get }
    func value(forAdditionalProperty propertyName:String) -> Any
    func set(value:Any, forAdditionalProperty propertyName:String)
    
    
    - (JSONInstanceMeta *)objectForPropertyNamed:(NSString *)propertyName {
        
        return [JSONMorphoModelSchemaInstance objectForPropertyNamed:propertyName forInstance:self];
        }
        
        - (JSONInstanceMeta *)arrayForPropertyNamed:(NSString *)propertyName {
            return [JSONMorphoModelSchemaInstance arrayForPropertyNamed:propertyName forInstance:self];
            }
            
            - (void)setString:(NSString *)val forProperty:(NSString *)propertyName {
                [JSONMorphoModelSchemaInstance setString:val forProperty:propertyName forInstance:self];
                }
                
                - (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName {
                    [JSONMorphoModelSchemaInstance setNumber:val forProperty:propertyName forInstance:self];
                    }
                    
                    - (void)setInteger:(NSNumber *)val forProperty:(NSString *)propertyName {
                        [JSONMorphoModelSchemaInstance setInteger:val forProperty:propertyName forInstance:self];
                        }
                        
                        - (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName {
                            [JSONMorphoModelSchemaInstance setBoolean:val forProperty:propertyName forInstance:self];
                            }
                            
                            - (void)setNullForProperty:(NSString *)propertyName {
                                [JSONMorphoModelSchemaInstance setNullForProperty:propertyName forInstance:self];
                            }


-(NSMutableDictionary*)additionalProperties {
    return _additionalProperties;
}

-(void)setValue:(id)value forAdditionalProperty:(NSString*)propertyName {
    [_additionalProperties setObject:value forKey:propertyName];
}

-(id)valueForAdditionalProperty:(NSString*)propertyName {
    return [_additionalProperties valueForKey:propertyName];
}

@end
