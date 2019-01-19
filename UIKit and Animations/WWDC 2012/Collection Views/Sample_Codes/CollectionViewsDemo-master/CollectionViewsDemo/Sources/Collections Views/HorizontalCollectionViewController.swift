//
//  HorizontalCollectionViewController.swift
//
//  Copyright © 2015 Sébastien MICHOY and contributors.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer. Redistributions in binary
//  form must reproduce the above copyright notice, this list of conditions and
//  the following disclaimer in the documentation and/or other materials
//  provided with the distribution. Neither the name of the nor the names of
//  its contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

import UIKit

class HorizontalCollectionViewController: UIViewController {

    // MARK: Properties
    
    let applicationsGroupedByCategory: [ApplicationCategoryItem]
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        self.applicationsGroupedByCategory = ApplicationManager.applicationsGroupedByCategories()
        
        super.init(coder: aDecoder)
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spacesWidth = (deviceType() == .phone) ? 2 : 10 as CGFloat
        
        let collectionViewFlowLayout = DecorationCollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = spacesWidth
        collectionViewFlowLayout.minimumInteritemSpacing = spacesWidth
        collectionViewFlowLayout.itemSize = ApplicationIconNameCollectionViewCell.standardSizeForApplicationItem()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: spacesWidth, bottom: 5, right: spacesWidth)
        collectionViewFlowLayout.headerReferenceSize = CGSize(width: 30, height: 0)
        collectionViewFlowLayout.footerReferenceSize = CGSize(width: 14, height: 0)
        collectionViewFlowLayout.scrollDirection = .horizontal
        
        self.collectionView.collectionViewLayout = collectionViewFlowLayout
    }
}

extension HorizontalCollectionViewController: UICollectionViewDataSource {

    // MARK: UICollectionViewDataSource Protocol
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let application = self.applicationsGroupedByCategory[indexPath.section].applications[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ApplicationIconNameCollectionViewCell", for: indexPath as IndexPath) as! ApplicationIconNameCollectionViewCell
        
        cell.fillWithApplicationItem(application: application)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.applicationsGroupedByCategory[section].applications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let applicationCategory = self.applicationsGroupedByCategory[indexPath.section]
        let supplementaryView: UICollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ApplicationHeaderCollectionReusableView", for: indexPath) as! ApplicationHeaderCollectionReusableView
            header.fillWithApplicationCategoryItem(applicationCategory: applicationCategory)
            header.titleLabel.transform = CGAffineTransform(rotationAngle: .pi / 2)
            supplementaryView = header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ApplicationFooterCollectionReusableView", for: indexPath) as! ApplicationFooterCollectionReusableView
            footer.fillWithApplicationCategoryItem(applicationCategory: applicationCategory)
            footer.titleLabel.transform = CGAffineTransform(rotationAngle: .pi / 2)
            supplementaryView = footer
        }
        
        return supplementaryView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.applicationsGroupedByCategory.count
    }
}

extension HorizontalCollectionViewController: UICollectionViewDelegate {

    // MARK: UICollectionViewDelegate Protocol
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionHeader, let view = view as? ApplicationHeaderCollectionReusableView {
            view.titleLabel.textColor = UIColor.white
            view.backgroundColor = UIColor(red: (102 / 255.0), green: (169 / 255.0), blue: (251 / 255.0), alpha: 1)
        } else if elementKind == ApplicationBackgroundCollectionReusableView.kind() {
            let evenSectionColor = UIColor(red: (176 / 255.0), green: (226 / 255.0), blue: (172 / 255.0), alpha: 1)
            let oddSectionColor = UIColor(red: (248 / 255.0), green: (197 / 255.0), blue: (143 / 255.0), alpha: 1)
            
            view.backgroundColor = (indexPath.section % 2 == 0) ? evenSectionColor : oddSectionColor
        }
    }
}
