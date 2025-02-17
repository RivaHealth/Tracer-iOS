//
//  TraceReport.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// A report of a trace's execution
public class TraceReport {
    
    /// Creates a report of the trace's execution.
    ///
    /// - Parameter result: The result of the trace
    public init(result: TraceResult) {
        self.result = result
    }
    
    /// A multi-line summary of the trace execution which can
    /// be displayed or otherwise exported to share with others.
    public var summary: String {
        return generateSummary()
    }
    
    /// Generates a multi-line string representation of all
    /// items logged during during this trace.
    public var rawLog: String {
        return generateRawLog()
    }
    
    /// The original `TraceResult` from which this summary was generated
    /// in case you'd like to generate a custom report.
    public let result: TraceResult
    
    // MARK: - Private Properties
    
    fileprivate lazy var startTime: String = {
        return TraceDateFormatter.default.string(from: result.startTime)
    }()
    
    fileprivate lazy var endTime: String = {
        return TraceDateFormatter.default.string(from: result.endTime ?? Date())
    }()
    
    fileprivate lazy var legend: String = {
        return TraceItemState.allReportableStates.map({ "--> \($0.debugDescription)" }).joined(separator: "\n")
    }()
}

// MARK: - Printable

extension TraceReport: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return rawLog
    }

    public var debugDescription: String {
        return summary
    }

}

// MARK: - Private API

fileprivate extension TraceReport {
    
    func generateSummary() -> String {
        let itemsToMatch = result.statesForItemsToMatch.compactMap({ stateDictionary -> String? in
            guard let item = stateDictionary.keys.first,
                let state = stateDictionary.values.first else { return nil }
            
            return """
            \(state.rawValue)
            ---> type: \(item.type),
                 itemToMatch: \(item.itemToMatch)
            """
        }).joined(separator: "\n\n")
        
        let totalItems = result.statesForItemsToMatch.count

        func countOfMatchedItem(state: TraceItemState) -> String {
            let count = result.statesForItemsToMatch.filter({ $0.values.first == state }).count
            return "\(count) out of \(totalItems)"
        }
        
        func countOfLoggedItem(state: TraceItemState) -> String {
            let count = result.statesForAllLoggedItems.filter({ $0.values.first == state }).count
            return "\(count)" // don't show total count here
        }
        
        return """
        
        ========  Begin Trace Report  ========
        
        Trace name: \(result.trace.name)
        
        Start time: \(startTime)
        End time: \(endTime)
        
        Result: \(result.state.rawValue)
        What does this mean?: \(result.state.debugDescription)
        
        Enforcing order?: \(result.trace.enforceOrder)
        Allow duplicates?: \(result.trace.allowDuplicates)
        
        ======================================
                    Results Legend
        ======================================
        
        \(legend)
        
        ======================================
                    Trace Results
        ======================================
        
        Total items to match: \(totalItems)
        
        --> Matched: \(countOfMatchedItem(state: .matched))
        --> Missing: \(countOfMatchedItem(state: .missing))
        --> Out of order: \(countOfMatchedItem(state: .outOfOrder))
        --> Had Duplicates: \(countOfMatchedItem(state: .hadDuplicates))
        --> Ignored, but matched: \(countOfLoggedItem(state: .ignoredButMatched))
        --> Ignored, no match: \(countOfLoggedItem(state: .ignoredNoMatch))
        
        ======================================
                 Items To Match Log
        ======================================
        
        \(itemsToMatch)
        
        ======================================
                      Raw Log
        ======================================
        
        The raw log can be exported separately.
        
        ========   End Trace Report   ========
        
        """
    }
    
    func generateRawLog() -> String {
        let loggedItems = result.statesForAllLoggedItems.compactMap({ stateDictionary -> String? in
            guard let item = stateDictionary.keys.first,
                  let state = stateDictionary.values.first else { return nil }
            
            return """
            \(state.rawValue)
            ---> type: \(item.type),
                 itemToMatch: \(item.itemToMatch)
            """
        }).joined(separator: "\n\n")
        
        return """
        
        ========  Begin Trace Raw Log  ========
        
        Trace name: \(result.trace.name)
        
        Start time: \(startTime)
        End time: \(endTime)
        
        ======================================
                    Results Legend
        ======================================
        
        \(legend)
        
        =======================================
                        Raw Log
        =======================================

        \(loggedItems)
        
        ========   End Trace Raw Log   ========
        
        """
    }
    
}
