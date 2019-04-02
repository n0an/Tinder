//
//  MatchView.swift
//  Tinder
//
//  Created by nag on 02/04/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit

class MatchView: UIView {
    
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
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBlurView()
        
        setupLayout()
        
        runFadeInAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("msg")
    }
    
    fileprivate func setupLayout() {
        layoutPerson(imageView: currentUserImageView, left: true)
        layoutPerson(imageView: cardUserImageView, left: false)
        
    }
    
    fileprivate func runFadeInAnimation() {
        self.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.alpha = 1
        }) { (_) in
            
        }
    }
    
    fileprivate func layoutPerson(imageView: UIImageView, left: Bool) {
        addSubview(imageView)
        imageView.anchor(top: nil, leading: left ? nil: centerXAnchor, bottom: nil, trailing: left ? centerXAnchor : nil, padding: .init(top: 0, left: left ? 0 : 16, bottom: 0, right: left ? 16 : 0), size: .init(width: 140, height: 140))
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.layer.cornerRadius = 140 / 2
    }
    
    fileprivate func setupBlurView() {
        
        self.addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()

        }
    }
}
