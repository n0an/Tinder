//
//  CardView.swift
//  Tinder
//
//  Created by nag on 24/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import SDWebImage

// MARK: - CardViewDelegate
protocol CardViewDelegate: AnyObject {
    func didTapMoreInfo(_ cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView, withDismissDirection: DismissDirection)
}

class CardView: UIView {
    
    // MARK: - PROPERTIES
    fileprivate let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
    
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let informationLabel = UILabel()
    
//    fileprivate let barsStackView = UIStackView()
    
    var imageIndex = 0
    
    weak var delegate: CardViewDelegate?
    
    var nextCardView: CardView?
    
    var cardViewModel: CardViewModel! {
        didSet {
            swipingPhotosController.cardViewModel = self.cardViewModel
            
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
//            (0..<cardViewModel.imageUrls.count).forEach { (_) in
//                let barView = UIView()
//                barView.backgroundColor = cardViewBarDeselectedColor
//                barsStackView.addArrangedSubview(barView)
//            }
//            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            
            setupImageIndexObserver()
        }
    }
    
    // MARK: - SUBVIEWS
    fileprivate let moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "33").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleMoreInfo), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VIEW LIFECYCLE
    override func layoutSubviews() {
        gradientLayer.frame = self.frame
    }
    
    // MARK: - HELPER METHODS
    fileprivate func setupLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotosController.view!

        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        
        setupGradientLayer()
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        
        informationLabel.textColor = .white
        informationLabel.numberOfLines = 0
        
        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
    }
    
    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] idx, imageUrl in
            
            print("Changing photo from viewModel")
            
//            self?.barsStackView.arrangedSubviews.forEach {
//                $0.backgroundColor = cardViewBarDeselectedColor
//            }
            
//            self?.barsStackView.arrangedSubviews[idx].backgroundColor = .white
        }
    }
    
//    fileprivate func setupBarStackView() {
//        addSubview(barsStackView)
//
//        barsStackView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: UIEdgeInsets.init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
//
//        barsStackView.spacing = 4
//        barsStackView.distribution = .fillEqually
//    }
    
    fileprivate func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        
        layer.addSublayer(gradientLayer)
    }
    
    // MARK: - ACTIONS
    @objc fileprivate func handleMoreInfo() {
        delegate?.didTapMoreInfo(self.cardViewModel)
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ (v) in
                v.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            break
        }
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2
        
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let dismissDirection: DismissDirection = gesture.translation(in: nil).x > 0 ? .right : .left
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > cardViewDismissThreshold
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            if shouldDismissCard {
                self.frame = CGRect(x: dismissDirection.rawValue*600, y: 0, width: self.frame.width, height: self.frame.height)
            } else {
                self.transform = .identity
            }
        }, completion: { _ in
            
            self.transform = .identity
            
            if shouldDismissCard {
                self.removeFromSuperview()
                
                self.delegate?.didRemoveCard(cardView: self, withDismissDirection: dismissDirection)
            }
        })
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let degrees = translation.x / 20
        let angle = degrees * .pi / 180
        let rotation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotation.translatedBy(x: translation.x, y: translation.y)
    }
}
