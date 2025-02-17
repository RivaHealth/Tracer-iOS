//
//  ItemLoggerReport.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// A report of an item logger session
public struct ItemLoggerReport {
    
    /// Creates a report of an item logger session.
    ///
    /// - Parameter loggedItems: An array of logged items
    public init(loggedItems: [LoggedItem]) {
        self.loggedItems = loggedItems
    }
    
    /// Generates a multi-line string representation of all
    /// items logged during during this session.
    public lazy var rawLog: String = {
        return generateRawLog()
    }()
    
    /// Generates a CSV representation of all items logged
    /// during this session.
    public lazy var csvLog: String = {
        return generateCSVLog()
    }()
    
    /// The array of `LoggedItem`s during this `ItemLogger` session
    /// (e.g. prior to this report being generated)
    public let loggedItems: [LoggedItem]
    
}

// MARK: - Private API

fileprivate extension ItemLoggerReport {
    
    mutating func generateRawLog() -> String {
        let itemDescriptions = loggedItems.map({ loggedItem -> String in
            return """
            \(loggedItem.item)
            ---> timestamp: \(TraceDateFormatter.default.string(from: loggedItem.timestamp)),
            ---> properties: \(loggedItem.properties?.loggerDescription ?? "none")
            """
        }).joined(separator: "\n\n")
        
        return """
        
        ========  Begin Item Logger Session  ========
        
        \(itemDescriptions)
        
        ========   End Item Logger Session   ========
        
        """
    }
    
    mutating func generateCSVLog() -> String {
        var csvText = "Item,Timestamp,Properties\r\n"
        for loggedItem in loggedItems {
            let itemText = loggedItem.item.description.cleanedForCSV()
            let timestamp = TraceDateFormatter.default.string(from: loggedItem.timestamp).cleanedForCSV()
            let properties = loggedItem.properties?.csvDescription ?? "none"
            let newline = "\(itemText),\(timestamp),\(properties)\r\n"
            csvText.append(newline)
        }
        return csvText
    }
    
}
