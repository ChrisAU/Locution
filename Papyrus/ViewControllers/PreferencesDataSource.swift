//
//  PreferencesDataSource.swift
//  Papyrus
//
//  Created by Chris Nevin on 30/07/2017.
//  Copyright © 2017 CJNevin. All rights reserved.
//

import UIKit

class PreferencesDataSource : NSObject, UITableViewDataSource, UITableViewDelegate {
    private let preferences: Preferences
    
    init(preferences: Preferences = .sharedInstance) {
        self.preferences = preferences
    }
    
    func value(for section: Int) -> Int {
        return preferences.values[section]!
    }
    
    func setValue(for section: Int, value: Int) {
        preferences.values[section] = value
    }
    
    func setValue(to indexPath: IndexPath) {
        setValue(for: indexPath.section, value: indexPath.row)
    }
    
    func section(at index: Int) -> [String: [String]] {
        return preferences.sections[index]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return preferences.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 4 {
            return 1
        }
        let rows = self.section(at: section).values.first!.count
        return rows
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section(at: section).keys.first!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.bounds.width
        } else if indexPath.section < 4 {
            return 80
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: BoardCell = tableView.dequeueCell(at: indexPath)
            cell.configure(index: value(for: indexPath.section))
            return cell
        } else if indexPath.section < 4 {
            let cell: SliderCell = tableView.dequeueCell(at: indexPath)
            cell.configure(index: value(for: indexPath.section),
                           values: section(at: indexPath.section).values.first!,
                           onChange: { [weak self] newIndex in
                            self?.setValue(for: indexPath.section, value: newIndex)
            })
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = Array(section(at: indexPath.section).values.first!)[indexPath.row]
        cell.accessoryType = value(for: indexPath.section) == indexPath.row ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell: BoardCell = tableView.cell(at: indexPath), indexPath.section == 0 {
            cell.nextBoard()
            setValue(for: indexPath.section, value: cell.gameTypeIndex)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if indexPath.section < 4 {
            return
        }
        setValue(to: indexPath)
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
    }
}
