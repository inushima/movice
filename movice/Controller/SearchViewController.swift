//
//  ViewController.swift
//  movice
//
//  Created by 上西篤季 on 2022/09/03.
//

import UIKit
import Moya

class SearchViewController: UIViewController {
    
    @IBOutlet weak var titleSearchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let movieDataRepository = MovieDataRepository()
    var searchResult: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleSearchBar.delegate = self
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let horizontalSpace:CGFloat = 5

        let cellSize:CGFloat = self.view.bounds.width/2 - horizontalSpace

        return CGSize(width: cellSize, height: cellSize)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        
        let movieInformation = searchResult[indexPath.row]
        
        let image = cell.contentView.viewWithTag(1) as! UIImageView
        
        image.image = getImageByUrl().getImageByUrl(url: movieInformation.poster_path, dark: true, size: "154")
        
        let label = cell.contentView.viewWithTag(2) as! UILabel
    
        label.text = movieInformation.title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieInformation = searchResult[indexPath.row]
        
        performSegue(withIdentifier: "toDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetailViewController
        
        if let indexPath = collectionView.indexPathsForSelectedItems {
            destinationVC.selectedMoive = searchResult[indexPath[0][1]]
         
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let title = searchBar.text {
            getMovieData(title: title)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    //映画情報の取得
    func getMovieData(title: String) {
        movieDataRepository.getMoiveData(title: title) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let movieData):
                self.searchResult = movieData.results
                self.collectionView.reloadData()
            case .failure(let moyaError):
                print(moyaError.localizedDescription)
            }
        }
    }
}

