//
//  ToDoListViewModel.swift
//  MVC_to_MVVM
//
//  Created by GreenChiu on 2018/12/22.
//  Copyright © 2018 Green. All rights reserved.
//

typealias DataState = ToDoListViewModel.DataState
protocol ToDoListViewModelDelegate: class {
    func toDoList( viewModel: ToDoListViewModel, didUpdateData state: DataState ) -> Void
}

class ToDoListViewModel {
    enum DataState : Equatable {
        case idle
        case retriving
        case synchornizing
    }
    private var dataIsDirty = false
    private var items = [ToDoItem]()
    private(set) var state = DataState.idle {
        didSet {
            guard let delegate = delegate else {
                return
            }
            delegate.toDoList(viewModel: self, didUpdateData: state)
        }
    }
    
    weak var delegate: ToDoListViewModelDelegate?
}

extension ToDoListViewModel {
    
    func add( item: ToDoItem ) -> Bool {
        guard item.name.count > 0, state == .idle else {
            return false
        }
        items.append(item)
        dataIsDirty = true
        return true
    }
    
    func item( at index: Int ) -> ToDoItem? {
        if index > numberOfToDoItems() || numberOfToDoItems() == 0 {
            return nil
        }
        return items[index]
    }
    
    func numberOfToDoItems() -> Int {
        return items.count
    }
    
    /// Return false means there is not item, doesn't change anything.
    func modifyToDoItem( title: String, at index: Int) -> Bool {
        guard title.count > 0, index < numberOfToDoItems(), state == .idle else {
            return false
        }
        items[index].name = title
        dataIsDirty = true
        return true
    }
}

extension ToDoListViewModel {
    final func retriveList() -> Void {
        if state == .retriving || state == .synchornizing {
            return
        }
        
        ToDoDataManager.shared.retriveToDoItems(finishCallback: { [weak self] (result, _) in
            guard let self = self else { return }
            if let result = result {
                self.items = result
            }
            else {
                self.items.removeAll()
            }
            self.state = .idle
        })
        
        state = .retriving
    }
    
    final func synchornizeToDoItem() -> Void {
        switch state {
        case .retriving, .synchornizing:
            return
        case .idle:
            if !dataIsDirty {
                return
            }
        }
        
        ToDoDataManager.shared.synchornized(items, finishCallback: { [weak self] (error) in
            guard let self = self else { return }
            self.state = .idle
        })
        
        state = .synchornizing
    }
}
