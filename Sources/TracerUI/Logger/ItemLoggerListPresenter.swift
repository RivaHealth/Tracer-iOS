//
//  ItemLoggerListPresenter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/9/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

final class ItemLoggerListPresenter: Presenting {
    
    init(view: ItemLoggerListView) {
        self.view = view
        
        listenForChanges()
    }
    
    // MARK: - Presenting
    
    func listenForChanges() {
        TraceUISignals.Logger.itemLogged.listen { [weak self] loggedItem in
            guard let self else { return }
        
            DispatchQueue.main.async {
                self.view.display(loggedItem: loggedItem)
            }
        }
        TraceUISignals.UI.clearLog.listen { [weak self] _ in
            guard let self else { return }
        
            DispatchQueue.main.async {
                self.view.clearAll()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let view: ItemLoggerListView
    
}
