//
//  LibraryPageViewController.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/19/23.
//
import AVKit
import Photos
import UIKit

protocol LibraryPageViewable: UIViewController {
    func updateProjectURLs(urls: [URL])
    func updateAssets(assets: PHFetchResult<PHAsset>)
    func pushImageProcessingPage(asset: PHAsset)
    func pushVideoProcessingPage(asset: PHAsset)
    func pushImageViewPage(projectURL: URL)
    func presentPlayer(projectURL: URL)
}

class LibraryPageViewController: UIViewController, LibraryPageViewable {
    enum Constants {
        static let insetMargin: CGFloat = 8
        static let headerHeight: CGFloat = 50
    }

    // MARK: view elements
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var collectionView: UICollectionView!

    // MARK: other variables
    private lazy var presenter: LibraryPagePresenting = LibraryPagePresenter(view: self)

    // MARK: Collection Data
    private var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionLayout()
        registerCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewAppears()
    }

    /**
     Make and assign compositional layout
     */
    private func setupCollectionLayout() {
        collectionView.collectionViewLayout = makeLayout()
    }

    private func registerCells() {
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        collectionView.register(UINib(nibName: AssetCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: AssetCollectionViewCell.reuseIdentifier)
    }

    /**
     Update My Projects section data, it's from local document directory
     */
    func updateProjectURLs(urls: [URL]) {
        guard !urls.isEmpty else {
            if sections.first is MyProjectSection {
                sections.removeFirst()
            }
            return
        }
        let section = MyProjectSection(projectURLs: urls)
        if sections.first is MyProjectSection {
            sections.removeFirst()
        }
        sections.insert(section, at: 0)

        collectionView.reloadData()
    }

    /**
     Update Photo Library section data
     */
    func updateAssets(assets: PHFetchResult<PHAsset>) {
        let section = PhotoLibrarySection(currentAssets: assets)
        if sections.last is PhotoLibrarySection {
            sections.removeLast()
        }
        sections.append(section)

        // TODO: diffable data source when have time :)
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }

    }

    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        presenter.segmentedControlChanged(index: sender.selectedSegmentIndex)
    }

    // MARK: view transition
    func pushImageProcessingPage(asset: PHAsset) {
        let imageProcessingPagePresenter = ImageProcessingPagePresenter(asset: asset, detector: HumanDetector())
        let viewController = ImageProcessingViewController.makeImageProcessingViewController(presenter: imageProcessingPagePresenter)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func pushVideoProcessingPage(asset: PHAsset) {
        let videoProcessingPagePresenter = VideoProcessingPagePresenter(asset: asset, detector: HumanDetector())
        let viewController = VideoProcessingViewController.makeVideoProcessingViewController(presenter: videoProcessingPagePresenter)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func pushImageViewPage(projectURL: URL) {
        let imageViewController = ImageViewController.makeImageViewController()
        imageViewController.image = UIImage(contentsOfFile: projectURL.path())
        navigationController?.pushViewController(imageViewController, animated: true)
    }

    func presentPlayer(projectURL: URL) {
        let playerViewController = AVPlayerViewController()
        let playerItem = AVPlayerItem(url: projectURL)
        playerViewController.player = AVPlayer(playerItem: playerItem)
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
}

// MARK: CollectionView DataSource, Delegate
extension LibraryPageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].itemCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return sections[indexPath.section].cell(collectionView: collectionView, indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header: CollectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeaderView.reuseIdentifier, for: indexPath) as! CollectionHeaderView
            header.configure(title: sections[indexPath.section].sectionTitle)
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        switch section {
        case is MyProjectSection:
            guard let projectURL = (section as! MyProjectSection).getProjectURL(index: indexPath.row) else { return }
            presenter.projectSelected(projectURL: projectURL)
        case is PhotoLibrarySection:
            guard let asset = (section as! PhotoLibrarySection).getAseet(index: indexPath.row) else { return }
            presenter.photoLibrarySelected(asset: asset)
        default:
            break
        }
    }
}

// MARK: CollectionView Layout
extension LibraryPageViewController {

    /**
     Make compositional layout
      - MyProjects section: Horizontal scroll layout
      - Photo Library section: Vertical scroll layout
     */
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let compositionalLayout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self, sectionIndex < sections.count else { return nil }

            let section = sections[sectionIndex]

            switch section {
            case is MyProjectSection:
                let fractionWidth = 0.4

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: Constants.insetMargin,
                                                             leading: Constants.insetMargin,
                                                             bottom: Constants.insetMargin,
                                                             trailing: 0)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionWidth), heightDimension: .fractionalWidth(fractionWidth))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                              leading: Constants.insetMargin,
                                                              bottom: 0,
                                                              trailing: 0)

                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .continuous

                let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(Constants.headerHeight))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)

                layoutSection.boundarySupplementaryItems = [headerItem]
                return layoutSection
            case is PhotoLibrarySection:
                let fractionWidth = 0.5

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionWidth), heightDimension: .fractionalWidth(fractionWidth))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: Constants.insetMargin,
                                                             leading: Constants.insetMargin,
                                                             bottom: Constants.insetMargin,
                                                             trailing: Constants.insetMargin)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(fractionWidth))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                              leading: Constants.insetMargin,
                                                              bottom: 0,
                                                              trailing: Constants.insetMargin)

                let layoutSection = NSCollectionLayoutSection(group: group)

                let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(Constants.headerHeight))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)

                layoutSection.boundarySupplementaryItems = [headerItem]
                return layoutSection
            default:
                return nil
            }
        }
        return compositionalLayout
    }
}
