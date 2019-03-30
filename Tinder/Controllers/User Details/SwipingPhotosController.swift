//
//  SwipingPhotosController.swift
//  Tinder
//
//  Created by nag on 29/03/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit

class SwipingPhotosController: UIPageViewController {
    
    var cardViewModel: CardViewModel! {
        didSet {
            controllers = cardViewModel.imageUrls.map {
                return PhotoController(imageUrlString: $0)
            }
            
            setViewControllers([controllers.first!], direction: .forward, animated: false)
            
            setupBarViews()
        }
    }
    
    fileprivate let barsStackView = UIStackView(arrangedSubviews: [])
    fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    
    fileprivate func setupBarViews() {
        cardViewModel.imageUrls.forEach { _ in
            let barView = UIView()
            barView.backgroundColor = deselectedBarColor
            barView.layer.cornerRadius = 2
            barsStackView.addArrangedSubview(barView)
        }
        
        barsStackView.arrangedSubviews.first?.backgroundColor = .white
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
        view.addSubview(barsStackView)
        
        var paddingTop: CGFloat = 8
        
        if !isCardViewMode {
            paddingTop += UIApplication.shared.statusBarFrame.height
        }
        
        barsStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddingTop, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }
    
    var controllers = [UIViewController]()
    
    fileprivate let isCardViewMode: Bool
    
    init(isCardViewMode: Bool = false) {
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        dataSource = self
        delegate = self
        
        if isCardViewMode {
            disableSwipingAbility()
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        print("Cycling")
        let currentController = viewControllers!.first!
        if let index = controllers.firstIndex(of: currentController) {
            
            barsStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectedBarColor }
            
            if gesture.location(in: self.view).x > view.frame.width / 2 {
                
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                
                barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
                
            } else {
                let prevIndex = max(index - 1, 0)
                let prevController = controllers[prevIndex]
                setViewControllers([prevController], direction: .reverse, animated: false)
                
                barsStackView.arrangedSubviews[prevIndex].backgroundColor = .white
            }
            
        }
    }
    
    fileprivate func disableSwipingAbility() {
        view.subviews.forEach { v in
            if let v = v as? UIScrollView {
                v.isScrollEnabled = false
            }
        }
    }
}

extension SwipingPhotosController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? -1
        if index == 0 { return nil }
        return controllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
    }
}


extension SwipingPhotosController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("transitionCompleted")
        
        let currentPhotoController = viewControllers?.first
        
        if let index = controllers.firstIndex(where: {$0 == currentPhotoController}) {
            barsStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectedBarColor }
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
        
    }
}


