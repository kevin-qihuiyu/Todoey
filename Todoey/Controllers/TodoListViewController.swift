//
//  ViewController.swift
//  Todoey
//
//  Created by Qihui YU on 20/03/2023.
//  Copyright © 2023 qihui.yu. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath)
        
//        let newItem1 = Item()
//        newItem1.title = "Find Mike"
//        itemArray.append(newItem1)
//
//        let newItem2 = Item()
//        newItem2.title = "Find Joe"
//        itemArray.append(newItem2)
//
//        let newItem3 = Item()
//        newItem3.title = "Find Hanna"
//        itemArray.append(newItem3)
        
        loadItems()
    }

    // MARK - Tableview Datasource Methods
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
    
    // MARK - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
                
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    // MARK - Add New Items
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
                let newItem = Item()
                newItem.title = textField.text!
                itemArray.append(newItem)
                
                saveItems()
            }
            tableView.reloadData()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK - Model Manupulation Methods
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }

}

