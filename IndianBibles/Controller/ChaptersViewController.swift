//
//  ChaptersViewController.swift
//  IndianBibles
//
//  Created by Admin on 25/04/21.
//  Copyright © 2021 Rajeev Kalangi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ChaptersViewController: UICollectionViewController, UISearchBarDelegate {
    
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    let cellsPerRow = 5
    
    var selectedBookIndex : Int?
    let db = DBHandler()
    var chaptersCount: Int?
    let bibleBooks = BibleBooks()
    var queriedVerses : [Bible]?
    var queryString : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if let book = selectedBookIndex {
            navigationItem.title = bibleBooks.englishBooks[book]
            chaptersCount = db.getChaptersCount(book: book)
        }
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            if let queryText = searchBar.text {
                queryString = queryText
                queriedVerses = db.getQueriedVerses(search: queryText)
                performSegue(withIdentifier: "ChaptersToSearch", sender: self)
            }
        }
    }
}

//Mark: - Data Source

extension ChaptersViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return chaptersCount ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! CollectionViewCell
        
        cell.cellTitle.text = String(indexPath.item + 1)
        
        if let book = selectedBookIndex {
            let verses = db.getVersesCount(bookNo: book, chapterNo: indexPath.item + 1)
            cell.cellSubtitle.text =  String(verses) + " Verses"
        }
        
        cell.layer.cornerRadius = CGFloat(8)
        
        return cell
    }
    
}

//Mark: - Delegate

extension ChaptersViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ChaptersToVerses", sender: self)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChaptersToVerses" {
            let controller = segue.destination as! VersesViewController
            if let indexPaths = collectionView.indexPathsForSelectedItems {
                
                if let book = selectedBookIndex {
                    controller.selectedBookIndex = book
                    controller.selectedChapterIndex = indexPaths[0].item + 1
                }
            }
        } else if segue.identifier == "ChaptersToSearch" {
            let controller = segue.destination as! SearchViewController
            controller.queriedVerses = self.queriedVerses
            controller.queryString = self.queryString
        }
    }
}

//Mark: - FlowLayout

extension ChaptersViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }

}
