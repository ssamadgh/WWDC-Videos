/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This view controller corresponds to the scene in main storyboard where the pet's image, pet name, likes, dislikes and special powers are
displayed.
*/

import UIKit

class PetViewController: UIViewController {
    
    @IBOutlet var petImage: UIImageView!
    @IBOutlet var petName: UILabel!
    @IBOutlet var petLikes: UILabel!
    @IBOutlet var petDislikes: UILabel!
    @IBOutlet var petSpecialPowers: UILabel!
    
    var pet: Pet = PetDataSource.petList()[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        petImage.image = pet.image
        petName.text = pet.name
        petLikes.text = "Likes: "+pet.likes
        petDislikes.text = "Dislikes: "+pet.dislikes
        petSpecialPowers.text = "Special Powers: "+pet.specialPowers
    }
}

