//
//  TraceUIDetailPresenter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation
import Tracer

final class TraceUIDetailPresenter: Presenting {
    
    init(view: TraceUIDetailView) {
        self.view = view
        
        listenForChanges()
    }
    
    // MARK: - Private Properties
    
    private let view: TraceUIDetailView
    private var tracer: Tracer?
    private var trace: Traceable?
}

private extension TraceUIDetailPresenter {
    
    // MARK: - Presenting
    
    func listenForChanges() {
        TraceUISignals.UI.showTraceDetail.listen { traceToShow in
            self.trace = traceToShow
            let newTracer = Tracer(trace: traceToShow)
            self.tracer = newTracer
            let viewModel = TraceUIDetailViewModel(trace: traceToShow,
                                                   isTraceRunning: false,
                                                   statesForItemsToMatch: newTracer.result.statesForItemsToMatch)
            self.view.configure(with: viewModel)
        }
        TraceUISignals.UI.startTrace.listen { _ in
            guard self.tracer?.isRunning == false,
                  let trace = self.trace,
                  let started = self.tracer?.start(canThrowAssertions: TraceUI.canThrowAssertions) else { return }
            TraceUISignals.Traces.started.fire(data: (trace: trace, started: started))
            self.updateTraceState()
        }
        TraceUISignals.Traces.started.listen { tuple in
            self.listenForTraceChanges(with: tuple.started)
        }
        TraceUISignals.Traces.itemLogged.listen { traceItem in
            guard self.tracer?.isRunning == true else { return }
            self.tracer?.log(item: traceItem)
        }
        TraceUISignals.UI.stopTrace.listen { _ in
            guard self.tracer?.isRunning == true else { return }
            let traceReport = self.tracer?.stop()
            guard let trace = self.trace, let report = traceReport else { return }
            TraceUISignals.Traces.stopped.fire(data: (trace: trace, report: report))
        }
        TraceUISignals.UI.exportTrace.listen { _ in
            guard let result = self.tracer?.result else { return }
            let report = TraceReport(result: result)
            TraceUISignals.UI.traceReportExported.fire(data: report)
        }
    }
    
    func listenForTraceChanges(with traceStarted: TraceStarted) {
        traceStarted.stateChanged.listen { traceState in
            TraceUISignals.Traces.stateChanged.fire(data: traceState)
            
            self.updateTraceState()
        }
    }
    
    func updateTraceState() {
        guard let trace = self.trace, let states = self.tracer?.result.statesForItemsToMatch else { return }
        let viewModel = TraceUIDetailViewModel(trace: trace,
                                               isTraceRunning: true,
                                               statesForItemsToMatch: states)
        self.view.configure(with: viewModel)
    }
    
}
