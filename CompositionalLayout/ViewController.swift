//
//  ViewController.swift
//  CompositionalLayout
//
//  Created by Stanislav Terentyev on 26.01.2021.
//

import UIKit

struct Model : Decodable {
    let download_url: String?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var model = [Model]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = layout()
        downloadImage()
    }
}

extension ViewController {
    
    func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(200),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension:.absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.interItemSpacing = .flexible(10)
       
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 30
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 10
        layout.configuration = configuration
        return layout
    }
}

extension ViewController {
    
    func configureImage(cell: CustomCollectionViewCell, for indexPath: IndexPath) {
        let models = model[indexPath.row]
        
        DispatchQueue.global().async {
            guard let imageURL = URL(string: models.download_url!) else {return}
            guard let imageData = try? Data(contentsOf: imageURL) else {return}
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: imageData)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        
        configureImage(cell: cell, for: indexPath)
        return cell
    }
}

extension ViewController {
    private func downloadImage () {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=1&limit=100") else {return}
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data
            else {return}
            if error == nil {
                do {
                    self.model = try JSONDecoder().decode([Model].self, from: data)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}


