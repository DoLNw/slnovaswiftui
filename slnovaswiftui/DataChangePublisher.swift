//
//  DataChangePublisher.swift
//  slnovaswiftui
//
//  Created by Jcwang on 2022/3/11.
//

import Foundation
import Combine

class TimePublisher {
    let currentTimePublisher = Timer.TimerPublisher(interval: 1, runLoop: .main, mode: .default)
    let cancelable: AnyCancellable?
    init() {
        self.cancelable = currentTimePublisher.connect() as? AnyCancellable
    }
    deinit {
        self.cancelable?.cancel()
    }
}
