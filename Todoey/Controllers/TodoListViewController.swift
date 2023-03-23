//
//  ViewController.swift
//  Todoey
//
//  Created by Qihui YU on 20/03/2023.
//  Copyright © 2023 qihui.yu. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath)
    }

    // MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    
    // MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // CRUD - U(Update) operation
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // CRUD - D(Delete) operation
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        saveItems()
                
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    // MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add Item", style: .default) { [self](action) in
            // what will happen once the user clicks the Add Item button on our UIAlert
            if(textField.text != nil) {
                
                // CRUD - C(Create) Operation
                let newItem = Item(context: context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = selectedCategory
                itemArray.append(newItem)
                
                saveItems()
            }
            tableView.reloadData()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manupulation Methods
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        // CRUD - R(Read) Operation
        // specify data type of output: Item
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        }
        else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
}

// MARK: - Search bar Methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)

        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            // UI task thread is in main thread, without this dispatchQueue won't work
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

