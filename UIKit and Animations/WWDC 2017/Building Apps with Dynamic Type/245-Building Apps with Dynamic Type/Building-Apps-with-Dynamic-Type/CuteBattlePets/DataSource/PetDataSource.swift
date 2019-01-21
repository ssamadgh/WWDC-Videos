/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is the data source class for Pet
*/

import UIKit

class PetDataSource: NSObject {
    
    class func petList() -> [Pet] {
        let petList = [
            Pet(name: "STARBIT", image: #imageLiteral(resourceName: "Bunny"), likes: "Constellations, Carrots, Burrows",
                dislikes: "Ferrets, snakes",
                specialPowers: "Shooting Star-shaped shurikens from forehead",
                popularity: 101, winnings: 27, health: 68),
            Pet(name: "FIREOWL", image: #imageLiteral(resourceName: "Owl"), likes: "Dark nights, treetops, hooting",
                dislikes: "Bright light, sunny mornings",
                specialPowers: "Attracts fireflies using firebolt spike feather on the forehead",
                popularity: 78, winnings: 9, health: 72),
            Pet(name: "SLYTHER", image: #imageLiteral(resourceName: "snake"), likes: "Playing hide-n-seek, swimming",
                dislikes: "mongoose, strong smell",
                specialPowers: "Camouflages with surroundings with powers of invisibility",
                popularity: 67, winnings: 5, health: 52),
            Pet(name: "SPIDENT", image: #imageLiteral(resourceName: "spider"), likes: "Climbing walls, web weaving",
                dislikes: "water, peanut butter, vinegar",
                specialPowers: "Attacks enemies with trident sharp tentacles",
                popularity: 72, winnings: 7, health: 37)
        ]
        return petList
    }
}
