/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is the Model class for Pet.
*/

import UIKit

class Pet: NSObject {
    let name: String
    let image: UIImage
    let likes: String
    let dislikes: String
    let specialPowers: String
    let popularity: Int
    let winnings: Int
    let health: Int
    
    init(name: String, image: UIImage, likes: String, dislikes: String, specialPowers: String, popularity: Int, winnings: Int, health: Int) {
        self.name = name
        self.image = image
        self.likes = likes
        self.dislikes = dislikes
        self.specialPowers = specialPowers
        self.popularity = popularity
        self.winnings = winnings
        self.health = health
    }
}
