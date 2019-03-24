//
//  ViewController.swift
//  Tinder
//
//  Created by nag on 23/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UIViewController {
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let buttonsStackView = HomeBottomControlsStackView()
    
//    let cardViewModels = ([
//            User(name: "Kelly", age: 23, profession: "DJ", imageNames: ["kelly1", "kelly2", "kelly3"]),
//            User(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1", "jane2", "jane3"]),
//            Advertiser(title: "Advertiser", brandName: "This is Ad", posterPhotoName: "slide_out_menu_poster")
//        ] as [ProducesCardViewModel]).map {return $0.toCardViewModel()}.reversed()
    
    var cardViewModels = [CardViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        
        setupLayout()
        setupDummyCards()
        fetchUsersFromFirestore()
    }
    
    @objc func handleSettings() {
        let registrationController = RegistrationController()
        present(registrationController, animated: true, completion: nil)
    }
    
    // MARK: - HELPER METHODS
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonsStackView])
        
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
    fileprivate func setupDummyCards() {
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    fileprivate func fetchUsersFromFirestore() {
        print("here")
        
        Firestore.firestore().collection("users").getDocuments { (snapshot, err) in
            if let err = err {
                print("Failed to fetch", err.localizedDescription)
                return
            }
            
            snapshot?.documents.forEach { docSnapshot in
                let userDict = docSnapshot.data()
                
                let user = User(dictionary: userDict)
                
                self.cardViewModels.append(user.toCardViewModel())
                
            }
            
            self.setupDummyCards()
        }
    }
}
