//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


@objcMembers class Kid: NSObject {
    dynamic var nickName: String = ""
    dynamic var age: Double = 0.0
    dynamic var bestFriend: Kid? = nil
    dynamic var friends: [Kid] = []
    
    init(nickName: String, age: Double) {
        self.nickName = nickName
        self.age = age
    }
    
    func getName() -> String {
//        let name = self.value(forKey: "nickName")
        let name = self[keyPath: \Kid.nickName]

        return name
    }
}

var ben = Kid(nickName: "Benji", age: 5.5)
//let kidsNameKeyPath = #keyPath(Kid.nickName)
//let name = ben.value(forKey: kidsNameKeyPath)
//ben.setValue("ben", forKeyPath: kidsNameKeyPath)

let name = ben[keyPath: \Kid.nickName]
let age = ben[keyPath: \Kid.age]

ben[keyPath: \Kid.nickName] = "ben"

ben.getName()


struct BirthDayParty {
    let celebrant: Kid
    var theme: String
    let attending: [Kid]
}

var bensParty = BirthDayParty(celebrant: ben, theme: "Construction", attending: [])
let birthDayKid = bensParty[keyPath: \BirthDayParty.celebrant]
bensParty[keyPath: \BirthDayParty.theme] = "Ninja"

let birthDayKidsAgeKeyPath = \BirthDayParty.celebrant.age

func partyPersonsAge(party: BirthDayParty, participantPath: KeyPath<BirthDayParty, Kid>) -> Double {
    let kidsAgeKeyPath = participantPath.appending(path: \.age)
    return party[keyPath: kidsAgeKeyPath]
}

let birthDayBoysAge = partyPersonsAge(party: bensParty, participantPath: \.celebrant)


_ = ben.observe(\.age) { (observed, change) in
    
    print("change observed", observed.age)
}

ben.age = 32

@objcMembers class KindergartenController: NSObject {
    dynamic var representedKid: Kid
    var ageObservation: NSKeyValueObservation!
    init(kid: Kid) {
        representedKid = kid
        super.init()
        ageObservation = observe(\.representedKid.age) { (observed, change) in
            if observed.representedKid.age > 5 {
                
            }
        }
    }
}


