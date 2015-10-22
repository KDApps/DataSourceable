//
//  LoadableDataSourceTests.swift
//  DataSourceable
//
//  Created by Niels van Hoorn on 13/10/15.
//  Copyright © 2015 Zeker Waar. All rights reserved.
//

import DataSourceable
import Quick
import Nimble

private enum Error: ErrorType {
    case Fail
}

class LoadingDataSource: Loadable {
    var fixtureData: [Int]
    var state: State<[Int],ErrorType> = .Empty
    func loadData(completion: ([Int]) -> Void) throws {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            completion(self.fixtureData)
        }
    }
    init(fixtureData: [Int]) {
        self.fixtureData = fixtureData
    }
}

class FailingDataSource: LoadingDataSource {
    override func loadData(completion: ([Int]) -> Void) throws {
        throw Error.Fail
    }
}

extension State: Equatable {}

public func ==<D,E>(lhs: State<D,E>, rhs: State<D,E>) -> Bool {
    switch (lhs,rhs) {
    case (.Empty,.Empty): return true
    case (.Loading,.Loading): return true
    case (.Ready,.Ready): return true
    case (.Error,.Error): return true
    default: return false
    }
}


class LoadableSpec: QuickSpec {
    override func spec() {
        describe("Loadable") {
            var loading: LoadingDataSource!
            context("succeeding") {
                beforeEach {
                    loading = LoadingDataSource(fixtureData: [1,3,4])
                }

                it("reloads the fixture data") {
                    loading.reload({})
                    expect(loading.data).toEventually(equal(loading.fixtureData))
                }
            }
            
            context("failing") {
                beforeEach {
                    loading = FailingDataSource(fixtureData: [1,3,4])
                }
                it("moves to the error state") {
                    loading.reload({
                    })
                    let errorState: State<[Int],ErrorType> = .Error(Error.Fail,nil)
                    expect(loading.state).toEventually(equal(errorState))
                }
            }
            
        }
    }
}
