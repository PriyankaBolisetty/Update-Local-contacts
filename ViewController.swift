//
//  ViewController.swift
//  LocalContacts
//  Created by Priyanka
//  Copyright © 2018 Priyanka Bolisetty. All rights reserved.
//

import Contacts
import Cocoa

extension NSUserInterfaceItemIdentifier {
    static let sugegstedPhoneColumnIdentifier = NSUserInterfaceItemIdentifier("SuggestedPhoneCellID")
}

extension ViewController: NSTableViewDataSource {
    func tableView(tableView: NSTableView, numberOfRowsInSection section: Int)-> Int {
        return displayContacts.count
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return displayContacts.count
    }
}

extension ViewController: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
        static let PhoneTypeCell = "PhoneTypeCellID"
        static let OriginalPhoneCell = "OriginalPhoneCellID"
        static let SuggestedPhoneCell = "SuggestedPhoneCellID"
    }
    
    override func scrollPageDown(_ sender: Any?) {
        print("Scrolling...")
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        checkToEnableOrDisableUpdateButton()
        checkToEnableOrDisableCheckAllCheckBox()
        var text: String = ""
        var cellIdentifier: String = ""
        var label: String = ""
        var _: String = ""
        var nameText: String = ""
        let currentContact = displayContacts[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = currentContact.name
            nameText = currentContact.contactID
            if(row > 0){
                if(nameText == displayContacts[row - 1].contactID){
                    text = ""
                }
            }
            cellIdentifier = CellIdentifiers.NameCell
        }
        if tableColumn == tableView.tableColumns[1] {
            label = currentContact.phoneType
            text = formatPhoneNumberLabel(phonelabel: label)
            phoneTypeText = text
            cellIdentifier = CellIdentifiers.PhoneTypeCell
        }
        if tableColumn == tableView.tableColumns[2] {
           text = currentContact.originalPhoneNumber
           originalPhoneText = text
           cellIdentifier = CellIdentifiers.OriginalPhoneCell
        }
        if tableColumn == tableView.tableColumns[3] {
            text = currentContact.suggestedPhoneNumber
            suggestedPhoneText = text
            if(originalPhoneText == suggestedPhoneText)
            {
                text = ""
            }
            cellIdentifier = CellIdentifiers.SuggestedPhoneCell
        }
        if(cellIdentifier == CellIdentifiers.NameCell){
            if let myCell:NSTableCellView = tableView.makeView(withIdentifier: (NSUserInterfaceItemIdentifier(rawValue: cellIdentifier)), owner: self) as? NSTableCellView{
                myCell.textField?.stringValue = text
                myCell.textField?.textColor = NSColor.black
                myCell.textField?.tag = row
                
                if(!currentContact.isAnyPhoneSuggestedInThisContact){
                    myCell.textField?.font = NSFont.systemFont(ofSize: 14, weight: .regular)
                } else {
                    myCell.textField?.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
                }
                return myCell
            }
        }
        if(cellIdentifier == CellIdentifiers.OriginalPhoneCell){
            if let myCell1:NSTableCellView = tableView.makeView(withIdentifier: (NSUserInterfaceItemIdentifier(rawValue: cellIdentifier)), owner: self) as? NSTableCellView{
                myCell1.textField?.stringValue = text
                myCell1.textField?.textColor = NSColor.black
                myCell1.textField?.tag = row
                return myCell1
            }
        }
        if(cellIdentifier == CellIdentifiers.PhoneTypeCell){
            if let myCell2:NSTableCellView = tableView.makeView(withIdentifier: (NSUserInterfaceItemIdentifier(rawValue: cellIdentifier)), owner: self) as? NSTableCellView{
                myCell2.textField?.stringValue = text
                myCell2.textField?.textColor = NSColor.black
                myCell2.textField?.tag = row
                return myCell2
            }
        }
        if(cellIdentifier == CellIdentifiers.SuggestedPhoneCell){
            if let myCell3:NSTableCellView = tableView.makeView(withIdentifier: (NSUserInterfaceItemIdentifier(rawValue: cellIdentifier)), owner: self) as? NSTableCellView{
                myCell3.textField?.stringValue = text
                myCell3.textField?.tag = row
                let btn = myCell3.subviews[0] as! NSButton
                btn.tag = row
                if(allCheckBoxState == 0){
                    btn.state = NSControl.StateValue(rawValue: NSControl.StateValue.off.rawValue)
                    checkUncheckAll.state = NSControl.StateValue(rawValue: NSControl.StateValue.off.rawValue)
                    if(currentContact.suggestedPhoneNumber == currentContact.originalPhoneNumber){
                        btn.isEnabled = false
                        btn.isHidden = true
                    } else{
                        btn.state = NSControl.StateValue(rawValue: NSControl.StateValue.off.rawValue)
                        btn.isEnabled = true
                        btn.isHidden = false
                    }
                }
                else{
                    checkUncheckAll.state = NSControl.StateValue(rawValue: NSControl.StateValue.on.rawValue)
                    btnUpdate.isEnabled = true
                    if(currentContact.suggestedPhoneNumber == currentContact.originalPhoneNumber){
                        btn.state = NSControl.StateValue(rawValue: NSControl.StateValue.off.rawValue)
                        btn.isEnabled = false
                        btn.isHidden = true
                    } else{
                        btn.state = NSControl.StateValue(rawValue: NSControl.StateValue.on.rawValue)
                        btn.isEnabled = true
                        btn.isHidden = false
                    }
                }
                //checkToEnableOrDisableUpdateButton()
                displayContacts[row].isCheckBoxChecked = btn.state.rawValue
                let thisContactID = currentContact.contactID
                let thisOriginalPhoneNo = currentContact.originalPhoneNumber
                let thisSuggestedPhoneNo = currentContact.suggestedPhoneNumber
                for i in 0..<(sortedContacts.count){
                    if sortedContacts[i].contactID == thisContactID{
                        if(sortedContacts[i].originalPhoneNumber == thisOriginalPhoneNo){
                            if(sortedContacts[i].suggestedPhoneNumber == thisSuggestedPhoneNo){
                                sortedContacts[i].isCheckBoxChecked = btn.state.rawValue
                            }
                        }
                    }
                }
                return myCell3
            }
        }
        return nil
    }
}

class ViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var dropDownMenuHomeLocation: NSPopUpButton!
    @IBOutlet weak var suggestedFirst: NSButton!
    @IBOutlet weak var checkUncheckAll: NSButton!
    @IBOutlet weak var btnUpdate: NSButton!
    @IBOutlet weak var btnLogs: NSButton!

    @IBOutlet weak var txtTotalContacts: NSTextField!
    @IBOutlet weak var txtTotalContactsWithPhones: NSTextField!
    @IBOutlet weak var txtTotalSuggestedContacts: NSTextField!
    @IBOutlet var textView: NSTextView!
    
    let store = CNContactStore()
    var enableUpdateButton: Bool = false
    var allCheckBoxState:Int = 0
    
    var CountryName = Locale.current.regionCode
    var CountryCode:String = ""
    var IntlAccessCode: String = ""
    var PhoneNumberLength:Int = 0
    
    var fullNameText: String = ""
    var phoneTypeText: String = ""
    var originalPhoneText: String = ""
    var suggestedPhoneText: String = ""
    var logFileContent = "Logs: Update Local Contacts\n"
    
    var cnContacts = [CNContact]()
    struct tableViewContactsList {
        var name: String
        var phoneType: String
        var originalPhoneNumber: String
        var suggestedPhoneNumber: String
        var contactID: String
        var isSuggestedNoSameAsOriginal: Bool
        var isAnyPhoneSuggestedInThisContact: Bool
        var isCheckBoxChecked: Int
        
        init(name: String? = nil,
             phoneType: String? = nil,
             originalPhoneNumber: String? = nil,
             suggestedPhoneNumber: String? = nil,
             contactID: String? = nil,
             isSuggestedNoSameAsOriginal: Bool? = false,
             isAnyPhoneSuggestedInThisContact: Bool? = false,
             isCheckBoxChecked: Int? = 0) {
            self.name = name!
            self.phoneType = phoneType!
            self.originalPhoneNumber = originalPhoneNumber!
            self.suggestedPhoneNumber = suggestedPhoneNumber!
            self.contactID = contactID!
            self.isSuggestedNoSameAsOriginal = isSuggestedNoSameAsOriginal!
            self.isAnyPhoneSuggestedInThisContact = isAnyPhoneSuggestedInThisContact!
            self.isCheckBoxChecked = isCheckBoxChecked!
        }
    }
    var structContacts = [tableViewContactsList]()
    var sortedContacts = [tableViewContactsList]()
    var displayContacts = [tableViewContactsList]()
    
    var contactsCounter = 0;
    struct countryCodesAndLengths {
        let countryName: String
        let countryCode: String
        let intlAccessCode: String
        let phoneNumberLength: NSInteger
    }
    
    var structCountries = [countryCodesAndLengths]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //createContact()
        btnLogs.isEnabled = false
        DefineCountryRules()
        fetchAllContacts()
        createDropDownMenuWithHomeLocations()
        if(structCountries.contains(where: {$0.countryName == CountryName})){
            CountryCode = structCountries[structCountries.index { $0.countryName == CountryName }!].countryCode
            IntlAccessCode = structCountries[structCountries.index { $0.countryName == CountryName }!].intlAccessCode
            PhoneNumberLength = structCountries[structCountries.index { $0.countryName == CountryName }!].phoneNumberLength
        } else{
            let ok = alertOKCancel(question: "Update Alert", messageText: "There are no rules defined for your country. Setting US as current Home Location.")
            if(ok){
                CountryName = "US"
                CountryCode = structCountries[structCountries.index { $0.countryName == CountryName }!].countryCode
                IntlAccessCode = structCountries[structCountries.index { $0.countryName == CountryName }!].intlAccessCode
                PhoneNumberLength = structCountries[structCountries.index { $0.countryName == CountryName }!].phoneNumberLength
            } else{
                return
            }
        }
        run()
    }
    
    func run(){
        allCheckBoxState = 1
        applyRulesForContacts()
        sortContactsBySuggestedFirst()
        checkToEnableOrDisableCheckAllCheckBox()
        checkToEnableOrDisableUpdateButton()
        updateLabels()
        
        self.tableView.scrollRowToVisible(0)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func updateLabels(){
        txtTotalContacts.stringValue = cnContacts.count.description
        fetchAllContacts()
        applyRulesForContacts()
        sortContactsBySuggestedFirst()
    
        var abc = Set<String>()
        for item in sortedContacts{
            abc.insert(item.contactID)
        }
        txtTotalContactsWithPhones.stringValue = abc.count.description
        let countSuggestedContacts = sortedContacts.filter{!$0.isSuggestedNoSameAsOriginal}
        txtTotalSuggestedContacts.stringValue = countSuggestedContacts.count.description
    }
    
    @IBAction func checkBoxCheckedEvent(_ sender: NSButton) {
        var row = displayContacts[(sender as AnyObject).tag]
        
        let btn:NSButton
        if let myCell3:NSTableCellView = tableView.makeView(withIdentifier: (NSUserInterfaceItemIdentifier(rawValue: "SuggestedPhoneCellID")), owner: self) as? NSTableCellView{
           btn = myCell3.subviews[0] as! NSButton
        if(row.isCheckBoxChecked == 0){
            row.isCheckBoxChecked = 1
            btn.state = NSControl.StateValue(rawValue: NSControl.StateValue.on.rawValue)
        } else if(row.isCheckBoxChecked == 1){
            row.isCheckBoxChecked = 0
            btn.state = NSControl.StateValue(rawValue: NSControl.StateValue.off.rawValue)
        }
        }
        
        let thisContactID = row.contactID
        let thisOriginalPhoneNo = row.originalPhoneNumber
        let thisSuggestedPhoneNo = row.suggestedPhoneNumber
        
        for i in 0..<(displayContacts.count){
            if (displayContacts[i].contactID == thisContactID && displayContacts[i].originalPhoneNumber == thisOriginalPhoneNo && displayContacts[i].suggestedPhoneNumber == thisSuggestedPhoneNo){
                displayContacts[i].isCheckBoxChecked = row.isCheckBoxChecked
                break
            }
        }
        for i in 0..<(sortedContacts.count){
            if (sortedContacts[i].contactID == thisContactID && sortedContacts[i].originalPhoneNumber == thisOriginalPhoneNo && sortedContacts[i].suggestedPhoneNumber == thisSuggestedPhoneNo){
                sortedContacts[i].isCheckBoxChecked = row.isCheckBoxChecked
                break
            }
        }
        
        //Check to enable/Disable update button
        var countCheckedBoxes:Int = 0
        for item in displayContacts{
            if item.isCheckBoxChecked == 1{
                countCheckedBoxes += 1
            }
        }
        if(countCheckedBoxes == 0){
            btnUpdate.isEnabled = false
            checkUncheckAll.state = NSControl.StateValue(rawValue: NSControl.StateValue.off.rawValue)
        }
        if(countCheckedBoxes > 0 && countCheckedBoxes <= displayContacts.count){
            btnUpdate.isEnabled = true
            checkUncheckAll.state = NSControl.StateValue(rawValue: NSControl.StateValue.on.rawValue)
        }
    }
    
    @IBAction func checkUncheckAllEvent(_ sender: NSButton) {
        allCheckBoxState = (sender as AnyObject).state
        
        if(allCheckBoxState == 0){
            for item in 0..<(displayContacts.count){
                if(displayContacts[item].isAnyPhoneSuggestedInThisContact == true){
                    displayContacts[item].isAnyPhoneSuggestedInThisContact = false
                    if(displayContacts[item].isCheckBoxChecked == 1){
                        displayContacts[item].isCheckBoxChecked = 0
                    } else{
                        continue
                    }
                }
            }
            for item in 0..<(sortedContacts.count){
                if(displayContacts[item].isAnyPhoneSuggestedInThisContact == true){
                    displayContacts[item].isAnyPhoneSuggestedInThisContact = false
                    if(sortedContacts[item].isCheckBoxChecked == 1){
                        sortedContacts[item].isCheckBoxChecked = 0
                    }
                    else{
                        continue
                    }
                 }
            }
        } else{
            for item in 0..<(displayContacts.count){
                if(displayContacts[item].isAnyPhoneSuggestedInThisContact == false){
                    displayContacts[item].isAnyPhoneSuggestedInThisContact = true
                    if(displayContacts[item].isCheckBoxChecked == 0){
                        displayContacts[item].isCheckBoxChecked = 1
                    }
                    else{
                        continue
                    }
                }
            }
            for item in 0..<(sortedContacts.count){
                if(displayContacts[item].isAnyPhoneSuggestedInThisContact == false){
                    displayContacts[item].isAnyPhoneSuggestedInThisContact = true
                    if(sortedContacts[item].isCheckBoxChecked == 0){
                        sortedContacts[item].isCheckBoxChecked = 1
                    }
                    else{
                        continue
                    }
                }
            }
        }
        tableView.reloadData()
    }
 }
