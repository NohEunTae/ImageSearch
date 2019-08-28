//
//  SearchViewController.swift
//  ImageSearch
//
//  Created by user on 26/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class SearchViewController: UIViewController {
    @IBOutlet weak var imageTableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var disposeBag = DisposeBag()
    private var searchBag = DisposeBag()
    private var viewModel = SearchImageViewModel()

    init() {
        super.init(nibName: "SearchViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        bindInput()
        bindOutput()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        combineToCellSelected()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    private func combineToCellSelected() {
        Observable.combineLatest(viewModel.data.asObservable(), imageTableView.rx.itemSelected) {
            ($0, $1)
            }
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { imagePresenters, indexPath in
                guard !imagePresenters.isEmpty else { return }
                let pageVC = ImagePageViewController(imagePresenters: imagePresenters, startIndex: indexPath.row)
                self.navigationController?.pushViewController(pageVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        let nibCell = UINib(nibName: "ImageTableViewCell", bundle: nil)
        imageTableView.register(nibCell, forCellReuseIdentifier: "ImageTableViewCell")
        imageTableView.rx.setPrefetchDataSource(self).disposed(by: viewModel.disposeBag)
        imageTableView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
    }
    
    private func bindInput() {
        let distinctUntilChanged = searchBar.rx.text.orEmpty.distinctUntilChanged()
        distinctUntilChanged
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .bind(to: viewModel.searchText)
            .disposed(by: searchBag)
        
        distinctUntilChanged
            .subscribe(onNext: { text in
                let animation = text.isEmpty ? false : true
                self.viewModel.indicatorAnimating.accept(animation)
                self.viewModel.disposeBag = DisposeBag()
            })
            .disposed(by: searchBag)
        
        viewModel.indicatorAnimating
            .bind(to: indicator.rx.isAnimating)
            .disposed(by: viewModel.disposeBag)
    }
    
    private func bindOutput() {
        viewModel.error
            .subscribe(onNext: { error in
                switch error {
                case .json:
                    self.presentAlert("결과 없음", message: "입력한 단어의 이미지 목록이 없습니다", completion: nil)
                case .network:
                    self.presentAlert("네트워크 오류", message: "인터넷 연결상태를 확인하세요", completion: nil)
                default:
                    break
                }
            }).disposed(by: viewModel.disposeBag)
        
        viewModel.data
            .drive(imageTableView.rx.items(cellIdentifier: "ImageTableViewCell")) { _, model, cell in
                if let imageCell = cell as? ImageTableViewCell {
                    if let image = model.image {
                        imageCell.modifyCell(image: image)
                    } else {
                        imageCell.modifyCell(image: UIImage())
                        model.downloadImage { image in
                            imageCell.modifyCell(image: image)
                        }
                    }
                }
            }
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cropRatio: CGFloat = 0
        self.viewModel.data
            .drive(onNext: { models in
                guard !models.isEmpty else { return }
                cropRatio = CGFloat(models[indexPath.row].width / models[indexPath.row].height)
            })
            .disposed(by: viewModel.disposeBag)
        
        return tableView.frame.width / cropRatio
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension SearchViewController : UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        viewModel.data
            .drive(onNext: { models in
                guard !models.isEmpty else { return }
                indexPaths.forEach({ models[$0.row].downloadImage(completion: nil)})
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        viewModel.data
            .drive(onNext: { models in
                guard !models.isEmpty else { return }
                indexPaths.forEach({ models[$0.row].cancelDownload()})
            })
            .disposed(by: viewModel.disposeBag)
    }
}
