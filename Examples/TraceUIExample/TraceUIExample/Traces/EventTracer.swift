//
//  EventTracer.swift
//  TraceUIExample
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Tracer

enum Event: String {
    case logicCheckpointOne
    case logicCheckpointTwo
    case logicCheckpointThree
    
    var uxFlowHint: String {
        switch self {
        case .logicCheckpointOne: return "Step one here"
        case .logicCheckpointTwo: return "Step two here"
        case .logicCheckpointThree: return "Step three here"
        }
    }
    
    var toTraceItem: TraceItem {
        return TraceItem(type: "event", itemToMatch: AnyTraceEquatable(self), uxFlowHint: uxFlowHint)
    }
    
    static func traceItems(from events: [Event]) -> [TraceItem] {
        return events.map({ $0.toTraceItem })
    }
}

struct EventTracer {
    
    static func log(event: Event) {
        print("\nEVENT: \(event.rawValue) logged")
    }
    
}
