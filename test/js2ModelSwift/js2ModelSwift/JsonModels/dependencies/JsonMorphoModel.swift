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
    typealias ModelSchemaType = JsonMorphoModelSchema;

    lazy var additionalProperties: [String: Any] = [String: Any]()

    required init() {
        
    }

    convenience required init(jsonData:[Byte]) {
        self.init()
    }
    
    convenience required init(filename:String) {
        self.init()
    }
    
    class func modelSchema() -> JsonMorphoModelSchema {
        return JsonMorphoSchemaInstance;
    }

    func set(string val:String, forProperty propertyName:String) {
        JsonMorphoSchemaInstance.set(string:val, forProperty:propertyName, forInstance:self);
    }
    
    func set(number val:Double, forProperty propertyName: String){
        JsonMorphoSchemaInstance.set(string:val, forProperty:propertyName, forInstance:self);
    }
 
    func set(integer val:Int, forProperty propetyName:String){
        JsonMorphoSchemaInstance.set(integer:val, forProperty:propertyName, forInstance:self);
    }
    
    func set(boolean val:Bool, forProperty propetyName:String){
        JsonMorphoSchemaInstance.set(boolean:val, forProperty:propertyName, forInstance:self);
    }
    
    func value(forAdditionalProperty propertyName:String) -> Any {
        return additionalProperties[propertyName]
    }
    
    func set(value:Any, forAdditionalProperty propertyName:String) {
        additionalProperties[propertyName] = value
    }
    
}
