//
//  MatchView.swift
//  Tinder
//
//  Created by nag on 02/04/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase

class MatchView: UIView {
    
    var cardUID: String! {
        didSet {
            Firestore.firestore().collection("users").document(cardUID).getDocument { (snapshot, err) in
                if let err = err {
                    print(err)
                    return
                }
                
                guard let dict = snapshot?.data() else { return }
                
                let user = User(dictionary: dict)
                guard let url = URL(string: user.imageUrl1 ?? "") else { return }
                self.cardUserImageView.sd_setImage(with: url)
                
                guard let currentUserImageUrl = URL(string: self.currentUser.imageUrl1 ?? "") else { return }
                self.currentUserImageView.sd_setImage(with: currentUserImageUrl, completed: { (_, _, _, _) in
                    self.setupAnimations()
                })
                
                self.descriptionLabel.text = "You and \(user.name ?? "?") liked\neachother"
                
            }
        }
    }
    
    var currentUser: User!
    
    fileprivate let itsAMatchImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "itsamatch"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    fileprivate let sendMessageButton: SendMessageButton = {
        let button = SendMessageButton(type: .system)
        button.setTitle("SEND MESSAGE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    fileprivate let keepSwipingButton: UIButton = {
        let button = KeepSwipingButton(type: .system)
        button.setTitle("Keep Swiping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    fileprivate let currentUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    fileprivate let cardUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "jane3"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        
        imageView.alpha = 0
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBlurView()
        
        setupLayout()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("msg")
    }
    
    lazy var views = [
        itsAMatchImageView,
        descriptionLabel,
        sendMessageButton,
        keepSwipingButton,
        currentUserImageView,
        cardUserImageView
    ]
    
    fileprivate func setupLayout() {
        
        views.forEach {
            addSubview($0)
            $0.alpha = 0
        }
        
        layoutPerson(imageView: currentUserImageView, left: true)
        layoutPerson(imageView: cardUserImageView, left: false)
        
//        addSubview(itsAMatchImageView)
//        addSubview(descriptionLabel)
//        addSubview(sendMessageButton)
//        addSubview(keepSwipingButton)
        
        itsAMatchImageView.anchor(top: nil, leading: nil, bottom: descriptionLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 300, height: 100))
        itsAMatchImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        descriptionLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 50))
        
        sendMessageButton.anchor(top: currentUserImageView.bottomAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))
        
        keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor, leading: sendMessageButton.leadingAnchor, bottom: nil, trailing: sendMessageButton.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
        
        
        
    }
    
    fileprivate func setupAnimations() {
        
        views.forEach {
            $0.alpha = 1
        }
        
        let angle: CGFloat = 30 * CGFloat.pi / 180
        
        let rotationTransformationLeft = CGAffineTransform(rotationAngle: -angle)
        let rotationTransformationRight = CGAffineTransform(rotationAngle: angle)

        currentUserImageView.transform = rotationTransformationLeft.concatenating(CGAffineTransform(translationX: 200, y: 0))
        cardUserImageView.transform = rotationTransformationRight.concatenating(CGAffineTransform(translationX: -200, y: 0))
        
        sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)
        
        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45, animations: {
                self.currentUserImageView.transform = rotationTransformationLeft
                self.cardUserImageView.transform = rotationTransformationRight

            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4, animations: {
                self.currentUserImageView.transform = .identity
                self.cardUserImageView.transform = .identity
            })
            
        }) { (_) in
            
        }
        
        UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.sendMessageButton.transform = .identity
            self.keepSwipingButton.transform = .identity
        })
        
        
    }
    
    
    fileprivate func layoutPerson(imageView: UIImageView, left: Bool) {
//        addSubview(imageView)
        imageView.anchor(top: nil, leading: left ? nil: centerXAnchor, bottom: nil, trailing: left ? centerXAnchor : nil, padding: .init(top: 0, left: left ? 0 : 16, bottom: 0, right: left ? 16 : 0), size: .init(width: 140, height: 140))
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.layer.cornerRadius = 140 / 2
    }
    
    fileprivate func setupBlurView() {
        
        self.addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        
        visualEffectView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 1
        })
        
    }
    
    @objc fileprivate func handleTapDismiss() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}
