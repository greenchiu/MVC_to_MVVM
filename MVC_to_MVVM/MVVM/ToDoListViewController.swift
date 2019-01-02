//
//  ToDoListViewController.swift
//  MVC_to_MVVM
//
//  Created by GreenChiu on 2018/12/22.
//  Copyright © 2018 Green. All rights reserved.
//

import UIKit

private let kResuseCellIdentifier = "kResuseCellIdentifier"

class ToDoListViewController: UIViewController {

    private let viewModel = ToDoListViewModel()
    private weak var hud: UIView?
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(ToDoListViewController.self)"
        viewModel.delegate = self

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
        viewModel.retriveList()
    }
}


fileprivate extension ToDoListViewController {
    @objc func displayAddToDoDialog() -> Void {
        let alertController = UIAlertController(title: "Add ToDo", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.clearButtonMode = UITextField.ViewMode.whileEditing
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self, let inputTextField = alertController.textFields?.first else { return }
            guard let inputText = inputTextField.text, inputText.count > 0 else { return }
            if self.viewModel.add(item: ToDoItem(name: inputText)) {
                self.tableView.insertRows(at: [IndexPath(row: self.viewModel.numberOfToDoItems() - 1, section: 0)], with: .fade)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func synchornizedToDoItems() -> Void {
        viewModel.synchornizeToDoItem()
    }
}

fileprivate extension ToDoListViewController {
    func displayEditToDoDialog( at index: Int) -> Void {
        guard let item = viewModel.item(at: index) else { return }
        let alertController = UIAlertController(title: "Update ToDo", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.text = item.name
            textField.clearButtonMode = UITextField.ViewMode.whileEditing
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self, let inputTextField = alertController.textFields?.first else { return }
            guard let inputText = inputTextField.text else { return }
            if self.viewModel.modifyToDoItem(title: inputText, at: index) {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ToDoListViewController: ToDoListViewModelDelegate {
    func toDoList(viewModel: ToDoListViewModel, didUpdateData state: DataState) -> Void {
        switch state {
        case .retriving, .synchornizing:
            UIView.showHUD(for: view)
            return
        case .idle:
            UIView.hideHUD(for: view)
            tableView.reloadData()
        }
    }
}

extension ToDoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfToDoItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kResuseCellIdentifier, for: indexPath)
        if let item = viewModel.item(at: indexPath.row) {
            cell.textLabel?.text = item.name
        }
        return cell
    }
}

extension ToDoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        displayEditToDoDialog(at: indexPath.row)
    }
}
