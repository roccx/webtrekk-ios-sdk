//
//  PropertyValue .swift
//  Pods
//
//  Created by arsen.vartbaronov on 09/08/16.
//
//

import Foundation

enum PropertyValue {
    case value(String)
    case key(String)
    
    func serialized(for event: TrackingEvent) -> String? {
        switch self {
        case let .value(value):
            return value
        case let .key(key):
            return event.variables[key]
        }
    }
    
    func serialized() -> String? {
        switch self {
        case let .value(value):
            return value
        case let .key(key):
            return nil
        }
    }
}
