//
//  ToDoDataManager.swift
//  MVC_to_MVVM
//
//  Created by GreenChiu on 2018/12/21.
//  Copyright © 2018 Green. All rights reserved.
//

import Foundation

open class ToDoDataManager {
    static let shared = ToDoDataManager()
    private let dispatchQueue = DispatchQueue(label: "todo.data.manager", qos: .default, attributes: .concurrent)
    private let filepath: String = {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/todos.txt"
    }()
    private init() {}
    
    final func retriveToDoItems( finishCallback callback: @escaping ([ToDoItem]?, Error?) -> Void) -> Void {
        dispatchQueue.async { [unowned self] in
            
            var result: [ToDoItem]?
            var catchError: Error?
            
            defer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    callback(result, catchError)
                })
            }
            
            guard FileManager.default.fileExists(atPath: self.filepath) else {
                return
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: self.filepath, isDirectory: false))
                let decoder = JSONDecoder()
                let list = try decoder.decode([ToDoItem].self, from: data)
                result = list
            }
            catch {
                catchError = error
            }
        }
    }
    
    final func synchornized(_ todos:[ToDoItem], finishCallback callback: @escaping (Error?) -> Void) -> Void {
        if todos.count == 0 {
            callback(nil)
            return
        }
        
        dispatchQueue.asyncAfter(deadline: .now() + 3, execute: { [unowned self] in
            do {
                let data = try JSONEncoder().encode(todos)
                try data.write(to: URL(fileURLWithPath: self.filepath), options: .atomic)
                DispatchQueue.main.async {
                    callback(nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    callback(error)
                }
            }
        })
        
    }
}
