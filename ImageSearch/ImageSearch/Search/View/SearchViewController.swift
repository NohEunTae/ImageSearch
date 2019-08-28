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
    
    var disposeBag = DisposeBag()
    var searchBarBag = DisposeBag()
    var viewModel = SearchImageViewModel()

    init() {
        super.init(nibName: "SearchViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupTableView()
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Observable.combineLatest(viewModel.data.asObservable(), imageTableView.rx.itemSelected) {
            ($0, $1)
            }
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] imagePresenters, indexPath in
                guard !imagePresenters.isEmpty else { return }
                let pageVC = ImagePageViewController(imagePresenters: imagePresenters, startIndex: indexPath.row)
                self?.navigationController?.pushViewController(pageVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    func setupTableView() {
        let nibCell = UINib(nibName: "ImageTableViewCell", bundle: nil)
        imageTableView.register(nibCell, forCellReuseIdentifier: "ImageTableViewCell")
        imageTableView.delegate = self
        imageTableView.prefetchDataSource = self
    }
    
    func bindUI() {
        bindTableView()

        viewModel.indicatorAnimating
            .bind(to: self.indicator.rx.isAnimating)
            .disposed(by: viewModel.disposeBag)
    
        viewModel.error
            .subscribe(onNext: { [weak self] error in
                switch error {
                case .json:
                    self?.presentAlert("결과 없음", message: "입력한 단어의 이미지 목록이 없습니다", completion: nil)
                case .network:
                    self?.presentAlert("네트워크 오류", message: "인터넷 연결상태를 확인하세요", completion: nil)
                default:
                    break
                }
            }).disposed(by: viewModel.disposeBag)
        
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .bind(to: viewModel.searchText)
            .disposed(by: searchBarBag)
        
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                let animation = text.isEmpty ? false : true
                self?.viewModel.indicatorAnimating.accept(animation)
                self?.viewModel.disposeBag = DisposeBag()
            })
            .disposed(by: searchBarBag)
    }
    
    func bindTableView() {
        viewModel.data
            .drive(imageTableView.rx.items(cellIdentifier: "ImageTableViewCell")) { _, model, cell in
                if let imageCell = cell as? ImageTableViewCell {
                    if let image = model.image {
                        imageCell.modifyCell(image: image)
                    } else {
                        imageCell.modifyCell(image: UIImage())
                        model.downloadImage { image in
                            DispatchQueue.main.async {
                                imageCell.modifyCell(image: image)
                            }
                        }
                    }
                }
            }
            .disposed(by: viewModel.disposeBag)
    }
}

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