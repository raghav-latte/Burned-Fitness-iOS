//
//  FontHelper.swift
//  Burned
//
//  Created by Raghav Sethi on 30/08/25.
//

import SwiftUI

struct FontHelper {
    static func printAllFonts() {
        for family in UIFont.familyNames.sorted() {
            print("Font Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  Font Name: \(name)")
            }
        }
    }
    
    static func printCustomFonts() {
        print("=== Custom Fonts ===")
        for family in UIFont.familyNames.sorted() {
            let fontNames = UIFont.fontNames(forFamilyName: family)
            if fontNames.contains(where: { $0.lowercased().contains("pilat") }) {
                print("Found Pilat font family: \(family)")
                for name in fontNames {
                    print("  Font Name: \(name)")
                }
            }
        }
    }
}