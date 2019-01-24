//: [Previous](@previous)

import Foundation

var str = "Hello, playground"

//: [Next](@next)






let jsonData = """
{
    "name" : "Monaliza Octocat",
    "email" : "support@github.com",
    "date" : "2011-04-14T16:00:49Z"
}
""".data(using: .utf8)


struct Author: Codable {
    
    let samad: String
    let email: String
    let date: Date

    private enum CodingKeys: String, CodingKey {
        case samad = "name"
        case email
        case date
    }
}

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
//
let author = try! decoder.decode(Author.self, from: jsonData!)

author.samad




let json = """
[
    {
        "product_name": "Bananas",
        "product_cost": 200,
        "description": "A banana grown in Ecuador."
    },
    {
        "product_name": "Oranges",
        "product_cost": 100,
        "description": "A juicy orange."
    }
]
""".data(using: .utf8)!

struct GroceryProduct: Codable {
    var name: String
    var points: Int
    var description: String
    
    private enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case points = "product_cost"
        case description
    }
}

//let decoder = JSONDecoder()
let products = try decoder.decode([GroceryProduct].self, from: json)


