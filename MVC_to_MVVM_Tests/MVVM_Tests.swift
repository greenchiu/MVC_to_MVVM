//
//  MVVM_Tests.swift
//  MVC_to_MVVM_Tests
//
//  Created by GreenChiu on 2018/12/24.
//  Copyright © 2018 Green. All rights reserved.
//

import XCTest

class MVVM_Tests: XCTestCase {
    
    private var exp: XCTestExpectation?
    private var verifyState = DataState.idle
    
    override func tearDown() {
        let s = DispatchSemaphore(value: 0)
        ToDoDataManager.shared.synchornized([], finishCallback: { _ in
            s.signal()
        })
        s.wait()
    }
    
    func testInitState() -> Void {
        let vm = ToDoListViewModel()
        XCTAssertTrue(vm.numberOfToDoItems() == 0)
        XCTAssertNil(vm.item(at: 0))
        XCTAssertNil(vm.item(at: 10))
        XCTAssertNil(vm.item(at: 100))
        XCTAssertEqual(vm.state, .idle)
    }
    
    func testAdd() -> Void {
        let vm = ToDoListViewModel()
        XCTAssertTrue(vm.numberOfToDoItems() == 0)
        
        XCTAssertFalse(vm.add(item: ToDoItem(name: "")))
        XCTAssertFalse(vm.numberOfToDoItems() > 0)
        XCTAssertTrue(vm.add(item: ToDoItem(name: "1")))
        XCTAssertTrue(vm.numberOfToDoItems() == 1)
        XCTAssertEqual(vm.state, .idle)
        
        let item = vm.item(at: 0)
        XCTAssertNotNil(item)
        if let item = item {
            XCTAssertEqual(item.name, "1")
        }
    }

    func testModify() -> Void {
        let vm = ToDoListViewModel()
        XCTAssertTrue(vm.numberOfToDoItems() == 0)
        XCTAssertFalse(vm.modifyToDoItem(title: "123", at: 0))
        XCTAssertFalse(vm.modifyToDoItem(title: "321", at: 10))
        XCTAssertFalse(vm.modifyToDoItem(title: "213", at: 100))
        
        XCTAssertTrue(vm.add(item: ToDoItem(name: "1")))
        XCTAssertTrue(vm.numberOfToDoItems() == 1)
        
        let item = vm.item(at: 0)
        XCTAssertNotNil(item)
        if let item = item {
            XCTAssertEqual(item.name, "1")
            XCTAssertFalse(vm.modifyToDoItem(title: "", at: 0))
        }
        
        XCTAssertTrue(vm.modifyToDoItem(title: "4", at: 0))
        if let mutatedItem = vm.item(at: 0) {
            XCTAssertEqual(mutatedItem.name, "4")
        }
    }
    
    
    func testRetrive() -> Void {
        let vm = ToDoListViewModel()
        vm.delegate = self
        
        exp = expectation(description: "testRetrive")
        verifyState = .retriving
        vm.retriveList()
        wait(for: [exp!], timeout: 10)
        XCTAssertTrue(vm.numberOfToDoItems() == 0)
        
        verifyState = .idle
        exp = expectation(description: "testRetrive_state_back_to_idle")
        wait(for: [exp!], timeout: 10)
        XCTAssertEqual(vm.state, verifyState)
    }
    
    func testSynchorize() -> Void {
        let vm = ToDoListViewModel()
        vm.delegate = self
        vm.synchornizeToDoItem()
        
        XCTAssertTrue(vm.add(item: ToDoItem(name: "1")))
        XCTAssertTrue(vm.numberOfToDoItems() == 1)
        
        exp = expectation(description: "testSynchorize")
        verifyState = .synchornizing
        vm.synchornizeToDoItem()
        wait(for: [exp!], timeout: 10)
        XCTAssertTrue(vm.numberOfToDoItems() == 1)
        
        verifyState = .idle
        exp = expectation(description: "testSynchorize_state_back_to_idle")
        wait(for: [exp!], timeout: 10)
        XCTAssertEqual(vm.state, verifyState)
    }
}

extension MVVM_Tests: ToDoListViewModelDelegate {
    func toDoList(viewModel: ToDoListViewModel, didUpdateData state: DataState) {
        if let exp = exp {
            XCTAssertEqual(state, verifyState)
            exp.fulfill()
            return
        }
    }
}
