//
//  ImagePageViewController.swift
//  ImageSearch
//
//  Created by user on 26/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ImagePageViewController: UIViewController {
    
    var pageController: UIPageViewController!
    let page: Page

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageController()
    }
    
    init(imagePresenters: [ImagePresenter], startIndex: Int) {
        self.page = Page(startIndex: startIndex, imagePresenters: imagePresenters)
        super.init(nibName: "ImagePageViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPageController() {
        pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        
        guard let maybefirstViewController = viewController(at: page.startIndex) else { return }
        
        let startingViewController: ImageViewController = maybefirstViewController
        let viewControllers = [startingViewController]
        
        pageController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)

        addChild(pageController)
        view.addSubview(pageController.view)
        
        let pageViewRect = view.bounds
        pageController.view.frame = pageViewRect
        pageController.didMove(toParent: self)

    }
    
    func viewController(at index: Int) -> ImageViewController? {
        if (page.imagePresenters.isEmpty || page.imagePresenters.count <= index) {
            return nil
        }
        let imageVC = ImageViewController(imagePresenter: page.imagePresenters[index], index: index)
        return imageVC
    }
}

// MARK: - UIPageViewControllerDataSource

extension ImagePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as? ImageViewController
        
        guard let index = vc?.pageIndex else {
            return nil
        }
        
        return index == 0 ? nil : self.viewController(at: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as? ImageViewController
        
        guard let index = vc?.pageIndex else {
            return nil
        }
        return index == page.imagePresenters.count ? nil : self.viewController(at: index + 1)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return page.imagePresenters.count
    }
}
