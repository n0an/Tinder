//
//  ViewController.swift
//  Tinder
//
//  Created by nag on 23/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
//import SafariServices

class HomeController: UIViewController {
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    var user: User?
    
    var swipes = [String: Int]()
    
//    let cardViewModels = ([
//            User(name: "Kelly", age: 23, profession: "DJ", imageNames: ["kelly1", "kelly2", "kelly3"]),
//            User(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1", "jane2", "jane3"]),
//            Advertiser(title: "Advertiser", brandName: "This is Ad", posterPhotoName: "slide_out_menu_poster")
//        ] as [ProducesCardViewModel]).map {return $0.toCardViewModel()}.reversed()
    
    var cardViewModels = [CardViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        
        setupLayout()
        
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            let registrationController = RegistrationController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
            present(navController, animated: true)
        }
    }
    
    @objc fileprivate func handleSettings() {
        let settingsController = SettingsController()
        
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleRefresh() {
        
        cardsDeckView.subviews.forEach { $0.removeFromSuperview() }
        
        fetchUsersFromFirestore()
    }
    
    
    // MARK: - HELPER METHODS
    fileprivate func setupLayout() {
        
        view.backgroundColor = .white
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
    fileprivate func setupFirestoreUserCards() {
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirestore() {
        
        let hud = JGProgressHUD(style: .dark)
        
        hud.textLabel.text = "Fetching Users"
        hud.show(in: view)
        
        let query = Firestore.firestore().collection("users")
            .whereField("age", isGreaterThanOrEqualTo: user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge)
            .whereField("age", isLessThanOrEqualTo: user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge)
        
        topCardView = nil
        
        query.getDocuments { (snapshot, err) in
            hud.dismiss()
            
            if let err = err {
                print("Failed to fetch", err.localizedDescription)
                return
            }
            
            var previousCardView: CardView?
            
            snapshot?.documents.forEach { docSnapshot in
                
                let userDict = docSnapshot.data()
                
                let user = User(dictionary: userDict)
                
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                
//                let notSwiped = self.swipes[user.uid!] == nil
                let notSwiped = true
                
                if  isNotCurrentUser && notSwiped {
                    
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            }
        }
    }
    
    var topCardView: CardView?
    
    @objc fileprivate func handleDislike() {
        saveSwipeToFirestore(didLike: false)
        animateSwipe(isLike: false)
    }

    @objc fileprivate func handleLike() {
        saveSwipeToFirestore(didLike: true)
        animateSwipe(isLike: true)
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        print(uid)
        
        guard let cardUID = topCardView?.cardViewModel.uid else { return }
        
        let likesData = [cardUID: didLike ? 1 : 0]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("no swipes data", err.localizedDescription)
                return
            }
            
            if snapshot?.exists == true {
                
                Firestore.firestore().collection("swipes").document(uid).updateData(likesData) { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    print("likes updated")
                }
                
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(likesData) { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    print("likes set")
                }
            }
            
            if didLike {
                self.checkIfMatchExists(cardUID: cardUID, currentUserID: uid)
            }
        }
    }
    
    fileprivate func checkIfMatchExists(cardUID: String, currentUserID: String) {
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            if let likesData = snapshot?.data() as? [String: Int] {
                
                if likesData[currentUserID] == 1 {
                    print("MATCH")
                    self.presentMatchView(cardUID: cardUID)
                } else {
                    print("NO MATCH")
                }
            }
            
        }
    }
    
    fileprivate func presentMatchView(cardUID: String) {
        
        let matchView = MatchView()
        
        view.addSubview(matchView)
        matchView.fillSuperview()
        

    }

    fileprivate func animateSwipe(isLike: Bool) {
        
        let animationDuration = 0.5
        
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = 700 * (isLike ? 1 : -1)
        translationAnimation.duration = animationDuration
        translationAnimation.fillMode = .forwards
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = (15 * CGFloat.pi / 180) * (isLike ? 1 : -1)
        rotationAnimation.duration = animationDuration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            if let swipesData = snapshot?.data() as? [String: Int] {
                self.swipes = swipesData
            }
            
            self.fetchUsersFromFirestore()
        }
    }
}

extension HomeController: SettingsControllerDelegate {
    
    func didSavedSettings() {
        
        fetchCurrentUser()
    }
}

extension HomeController: UserFetchingProtocol {
    
    func didFetchedUser() {
        fetchSwipes()
        
    }
}

extension HomeController: LoginControllerDelegate {
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
}

extension HomeController: CardViewDelegate {
    func didRemoveCard(cardView: CardView, withDismissDirection: DismissDirection) {
        if withDismissDirection == .right {
            saveSwipeToFirestore(didLike: true)
        } else {
            saveSwipeToFirestore(didLike: false)
        }
        
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
        
    }
    
    func didTapMoreInfo(_ cardViewModel: CardViewModel) {
        let vc = UserDetailsController()
        vc.cardViewModel = cardViewModel
        
        present(vc, animated: true)
    }
    
}

