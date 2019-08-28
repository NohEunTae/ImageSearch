//
//  ImageViewController.swift
//  ImageSearch
//
//  Created by user on 26/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class ImageViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    let pageIndex : Int
    private let imagePresenter: ImagePresenter
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        setupImageView()
        setupButtons()
        setupScrollView()
    }
    
    init(imagePresenter: ImagePresenter, index: Int) {
        self.pageIndex = index
        self.imagePresenter = imagePresenter
        super.init(nibName: "ImageViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        
        if let image = imagePresenter.image {
            imageView.image = image
        } else {
            imagePresenter.downloadImage { image in
                self.imageView.image = image
            }
        }
    }
    
    private func setupButtons() {
        closeButton.rx.controlEvent(.touchDown).subscribe(onNext: closeBtnClicked).disposed(by: disposeBag)
        shareButton.rx.controlEvent(.touchDown).subscribe(onNext: shareBtnClicked).disposed(by: disposeBag)
        downloadButton.rx.controlEvent(.touchDown).subscribe(onNext: downloadBtnClicked).disposed(by: disposeBag)
    }

    // 스크롤뷰 설정
    private func setupScrollView() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.delegate = self
        
        let scrollViewTap = UITapGestureRecognizer()
        scrollView.addGestureRecognizer(scrollViewTap)
        
        scrollViewTap.rx.event
            .bind { _ in
                self.closeButton.isHidden = !self.closeButton.isHidden
                self.shareButton.isHidden = !self.shareButton.isHidden
                self.downloadButton.isHidden = !self.downloadButton.isHidden
            }
            .disposed(by: disposeBag)
    }

    private func closeBtnClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    // 공유 버튼 클릭 이벤트
    private func shareBtnClicked() {
        if let image = imageView.image {
            let imageToShare = [image]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = view
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // 다운로드 버튼 클릭 이벤트
    private func downloadBtnClicked() {
        if let image = self.imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    // 다운로드 성공 실패 여부
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        error == nil ?
                self.presentAlert("저장 완료", message: "이미지 저장이 완료되었습니다", completion: nil) :
                self.presentAlert("오류", message: error!.localizedDescription, completion: nil)
    }
}

// MARK: - Image Viewer Scroll View Delegate

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }    
}

