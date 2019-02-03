/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Collection view cell for displaying an asset.
*/

import UIKit

class GridViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var livePhotoBadgeImageView: UIImageView!

    var representedAssetIdentifier: String!

    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    var livePhotoBadgeImage: UIImage! {
        didSet {
            livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImage = nil
        livePhotoBadgeImageView.image = nil
    }
}
