//
//  ViewController.swift
//  MVC_to_MVVM
//
//  Created by GreenChiu on 2018/12/21.
//  Copyright © 2018 Green. All rights reserved.
//

import UIKit

private let kResuseCellIdentifier = "kResuseCellIdentifier"

class MVCViewController: UIViewController {
    
    fileprivate enum ViewState {
        case idle
        case retriving
        case synchorning
    }
    
    private lazy var tableView = UITableView()
    private weak var hud: UIView?
    private var todos = [ToDoItem]()
    private var viewState: ViewState = .idle {
        didSet {
            var toggleHUD: (UIView) -> Void
            if viewState == .idle {
                toggleHUD = UIView.hideHUD
                UIView.hideHUD(for: view)
                return
            } else {
                toggleHUD = UIView.showHUD
            }
            toggleHUD(view)
        }
    }
    private var dirty = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "\(MVCViewController.self)"
        
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kResuseCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        var contraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: ["tableView":tableView])
        contraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: ["tableView":tableView])
        
        NSLayoutConstraint.activate(contraints)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(displayAddToDoDialog)),
                                              UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(synchornizedToDoItems))]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTodoItems()
    }
    
}

// MARK: - Target Actions
private extension MVCViewController {
    @objc func displayAddToDoDialog() -> Void {
        let alertController = UIAlertController(title: "Add ToDo", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.clearButtonMode = UITextField.ViewMode.whileEditing
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self, let inputTextField = alertController.textFields?.first else { return }
            guard let inputText = inputTextField.text else { return }
            self.add(item: ToDoItem(name: inputText))
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func synchornizedToDoItems() -> Void {
        if viewState != .idle || todos.count == 0 || !dirty {
            return
        }
        viewState = .synchorning
        ToDoDataManager.shared.synchornized(todos, finishCallback: { [weak self] error in
            print(error?.localizedDescription ?? "No error")
            guard let self = self else { return }
            self.dirty = error != nil
            self.viewState = .idle
        })
    }
}

// MARK: - Private fucs
private extension MVCViewController {
    func displayEditToDoDialog( at index: Int) -> Void {
        guard let item = item(at: index) else { return }
        let alertController = UIAlertController(title: "Update ToDo", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.text = item.name
            textField.clearButtonMode = UITextField.ViewMode.whileEditing
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self, let inputTextField = alertController.textFields?.first else { return }
            guard let inputText = inputTextField.text else { return }
            if self.modifyToDoItem(title: inputText, at: index) {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Manage ToDoItems
private extension MVCViewController {
    func loadTodoItems() -> Void {
        if viewState != .idle {
            return
        }
        viewState = .retriving
        ToDoDataManager.shared.retriveToDoItems(finishCallback: { [weak self] result, _ in
            guard let self = self else { return }
            if let result = result {
                self.todos += result
                self.tableView.reloadData()
            }
            self.viewState = .idle
        })
    }
    
    func add( item: ToDoItem ) -> Void {
        todos.append(item)
        tableView.reloadData()
        dirty = true
    }
    
    func item( at index: Int ) -> ToDoItem? {
        if index > numberOfToDoItems() {
            return nil
        }
        return todos[index]
    }
    
    func numberOfToDoItems() -> Int {
        return todos.count
    }
    
    /// Return false means there is not item, doesn't change anything.
    func modifyToDoItem( title: String, at index: Int) -> Bool {
        guard title.count > 0, index < numberOfToDoItems() else {
            return false
        }
        todos[index].name = title
        dirty = true
        return true
    }
}

// MARK: - TableView's Delegate & DataSource
extension MVCViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfToDoItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kResuseCellIdentifier, for: indexPath)
        if let item = item(at: indexPath.row) {
            cell.textLabel?.text = item.name
        }
        return cell
    }
}

extension MVCViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        displayEditToDoDialog(at: indexPath.row)
    }
}
