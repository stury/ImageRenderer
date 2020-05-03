//
//  Gradients.swift
//  SpirographView
//
//  Created by Scott Tury on 4/30/20.
//  Copyright © 2020 Scott Tury. All rights reserved.
//

//{
//    "name": "Berimbolo",
//    "colors": ["#02111D", "#037BB5", "#02111D"]
//}
struct Gradients : Codable {
    let name : String
    let colors : [String]
    
    // Allow the user to get the actual UIColor...
    func nativeColors() -> [Color] {
        var result = [Color]()
        
        for hexString in colors {
            do {
                if let hexColor = Color(hexString: hexString) {
                    result.append(hexColor)
                }
            }
        }
        
        return result
    }
    
//    enum CodingKeys: String, CodingKey {
//        case name
//        case colors
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        name = try values.decode(String.self, forKey: .name)
//        if let colorDescriptions = try values.decode([String].self, forKey: .colors) {
//            var actualColors = [UIColor]()
//
//            // decode each color into a UIColor
//            for description in colorDescriptions {
//                // convert hex color to UIColor
//
//            }
//            colors = actualColors
//        }
//    }
}
