//
//  SettingsController.swift
//  Tinder
//
//  Created by nag on 26/03/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate: AnyObject {
    func didSavedSettings()
}

class CustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}

class SettingsController: UITableViewController {
    
    weak var delegate: SettingsControllerDelegate?
    
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }
    
    @objc fileprivate func handleSelectPhoto(button: UIButton) {
        print(button)
        let imagePickerController = CustomImagePickerController()
        imagePickerController.imageButton = button
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        tableView.tableFooterView = UIView()
        
        tableView.keyboardDismissMode = .interactive
        
        fetchCurrentUser()
    }
    
    var user: User?

    
    fileprivate func loadUserPhotos() {
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, data, err, _, _, _) in
                
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, data, err, _, _, _) in
                
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, data, err, _, _, _) in
                
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))]
    }
    
    lazy var header: UIView = {
        let header = UIView()
        
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        
        return header
    }()
    
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return header
        }
        
        let headerLabel = HeaderLabel()
        
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }
        
        headerLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        
        return 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return 1
    }
    
    @objc fileprivate func handleMinAgeChange() {
        evaluateMinMax()
    }
    
    @objc fileprivate func handleMaxAgeChange() {
        evaluateMinMax()
    }
    
    fileprivate func evaluateMinMax() {
        guard let ageRangeCell = tableView.cellForRow(at: [5, 0]) as? AgeRangeCell else { return }
        let minValue = Int(ageRangeCell.minSlider.value)
        var maxValue = Int(ageRangeCell.maxSlider.value)
        maxValue = max(minValue, maxValue)
        ageRangeCell.maxSlider.value = Float(maxValue)
        ageRangeCell.minLabel.text = "Min \(minValue)"
        ageRangeCell.maxLabel.text = "Max \(maxValue)"
        
        user?.minSeekingAge = minValue
        user?.maxSeekingAge = maxValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
            
            ageRangeCell.minSlider.value = Float(user?.minSeekingAge ?? 18)
            ageRangeCell.maxSlider.value = Float(user?.maxSeekingAge ?? 80)
            
            ageRangeCell.minLabel.text = "Min: \(user?.minSeekingAge ?? 18)"
            ageRangeCell.maxLabel.text = "Max: \(user?.maxSeekingAge ?? 100)"
            
            return ageRangeCell
        }
        
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter Profession"
            cell.textField.text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
            
        case 3:
            cell.textField.placeholder = "Enter Age"
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
            if let age = user?.age {
                cell.textField.text = "\(age)"
            }
        default:
            cell.textField.placeholder = "Enter Bio"
            cell.textField.text = user?.name
        }
        
        return cell
    }
    
    @objc fileprivate func handleNameChange(textField: UITextField) {
        
        self.user?.name = textField.text
    }
    
    @objc fileprivate func handleProfessionChange(textField: UITextField) {
        self.user?.profession = textField.text
    }
    
    @objc fileprivate func handleAgeChange(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "")
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func handleSave() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let documentData: [String: Any] = [
            "uid": uid,
            "fullName": user?.name ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "imageUrl2": user?.imageUrl2 ?? "",
            "imageUrl3": user?.imageUrl3 ?? "",
            "age": user?.age ?? -1,
            "profession": user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge ?? -1,
            "maxSeekingAge": user?.maxSeekingAge ?? -1
        ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        
        Firestore.firestore().collection("users").document(uid).setData(documentData) { (err) in
            hud.dismiss()
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            print("user saved")
            
            self.dismiss(animated: true, completion: {
                self.delegate?.didSavedSettings()
                
            })
        }
    }
    
    @objc fileprivate func handleLogout() {
        dismiss(animated: true)
    }
    
}

extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        let customPicker = picker as? CustomImagePickerController
        let imageButton = customPicker?.imageButton
        
        customPicker?.imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.7) else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image"
        hud.show(in: view)
        
        ref.putData(uploadData, metadata: nil) { (nil, err) in
            if let err = err {
                hud.dismiss()
                print(err.localizedDescription)
                return
            }
            
            ref.downloadURL(completion: { (url, err) in
                hud.dismiss()
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                print("download url: \(url?.absoluteString ?? "")")
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                } else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
                
                
            })
            
            print("Finished uploading")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension SettingsController: UserFetchingProtocol {
    func didFetchedUser() {
        self.loadUserPhotos()
        self.tableView.reloadData()
    }
    
    
}
