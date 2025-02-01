//
//  AsyncSemaphore.swift
//  Retroview
//
//  Created by Adam Schuster on 1/27/25.
//

actor AsyncSemaphore {
    private let maxConcurrent: Int
    private var currentCount = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(value: Int) {
        self.maxConcurrent = value
    }

    func wait() async {
        while currentCount >= maxConcurrent {
            await withCheckedContinuation { continuation in
                waiters.append(continuation)
            }
        }
        currentCount += 1
    }

    func signal() {
        currentCount -= 1

        guard let next = waiters.popLast() else { return }
        next.resume()
    }
}
