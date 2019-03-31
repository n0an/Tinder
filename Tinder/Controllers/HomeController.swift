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
        
//        setupFirestoreUserCards()
//        fetchUsersFromFirestore()
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
        
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge).whereField("age", isLessThanOrEqualTo: user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge)
        
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
                
                if user.uid != Auth.auth().currentUser?.uid {
                    
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
        animateSwipe(isLike: false)
    }

    
    @objc fileprivate func handleLike() {
       animateSwipe(isLike: true)
    }
    
    fileprivate func animateSwipe(isLike: Bool) {
        
        //        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
        //            self.topCardView?.frame = CGRect(x: 600, y: 0, width: self.topCardView!.frame.width, height: self.topCardView!.frame.height)
        //            self.topCardView?.transform = CGAffineTransform(rotationAngle: 15 * CGFloat.pi / 180)
        //        }) { (_) in
        //            self.topCardView?.removeFromSuperview()
        //            self.topCardView = self.topCardView?.nextCardView
        //        }
        
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
}

extension HomeController: SettingsControllerDelegate {
    
    func didSavedSettings() {
        fetchCurrentUser()
    }
}

extension HomeController: UserFetchingProtocol {
    
    func didFetchedUser() {
        self.fetchUsersFromFirestore()
    }
}

extension HomeController: LoginControllerDelegate {
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
}

extension HomeController: CardViewDelegate {
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    func didTapMoreInfo(_ cardViewModel: CardViewModel) {
        let vc = UserDetailsController()
        vc.cardViewModel = cardViewModel
        
        present(vc, animated: true)
    }
    
}

