//
//  ChildTableViewCell.swift
//  AlefGitTz
//
//  Created by Павел Галкин on 12.12.2022.
//

import UIKit
import RealmSwift
 
class ChildTableViewCell: UITableViewCell, UITextFieldDelegate {
    let realmManager: RealmManagerProtocol = RealmManager()
    //complition handler
    var didDelete: () -> () = {}
    
    private(set) var cellView = ChildCellView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initializeUI()
     
        self.cellView.childNameField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeUI(){
        //чтобы работали textField добавить подвид в contentMode
//view loading
        contentView.addSubview(cellView)
        cellView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cellView.deleteButton.addTarget(self, action: #selector(deleteChild), for: .touchUpInside)
        cellView.childNameField.addTarget(self, action: #selector(saveChildRealm), for: .editingChanged)
        cellView.childAgeField.addTarget(self, action: #selector(nameFilterDigits), for: .editingChanged)
        cellView.childAgeField.addTarget(self, action: #selector(saveChildRealm), for: .editingChanged)
        cellView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().inset(0)
            make.right.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().offset(0)
        }
    }

//функция срабатывает 0 при вводе данных в поле + ограничение символов ввода
    @objc func nameFilterDigits(_ textField: UITextField){
        
        if textField.text!.lengthOfBytes(using: String.Encoding.utf8) > 2 {
            textField.text = String(textField.text!.prefix(2))
        }
        if  let text = textField.text, let intText = Int(text) {
          textField.text = "\(intText)"
        } else {
          textField.text = ""
        }
    }
//the function saves the child data to the database with each change in the TextField
    @objc func saveChildRealm(_ textField: UITextField){

        let childs = realmManager.obtainChild()
        let oldChildId = childs.endIndex - 1
        let child = ChildModel()
        let realm = try! Realm()
        try! realm.write({
            child.childID = childs[oldChildId].childID
            child.name = cellView.childNameField.text ?? ""
            child.age = cellView.childAgeField.text ?? ""
       
//MARK: - что то здесь!
            if  child.name != "" &&
                child.age != ""{
                realm.add(child, update: .modified)
            } else {
                return
            }
            
        })
        //print array with BD parents
        let parents = realmManager.obtainParent()
        print("\(parents)")
        
//        //print array with BD childs
//            let childArray = realmManager.obtainChild()
//            print("\(childArray)")
    }

//function with child removal closure
    @objc func deleteChild(){
        didDelete()
    }
    
//delegate function to enter data in letters only
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let letters = CharacterSet(charactersIn: "абвгдежзийклмнопрстуфхцчшщъыьэюяАБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ").inverted
       return (string.rangeOfCharacter(from: letters) == nil)
    }
}
