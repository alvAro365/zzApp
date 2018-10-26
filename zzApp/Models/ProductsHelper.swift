//
//  ProductsHelper.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-19.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation

struct Product {
    
    let productDescription = [
                           "BalanceOil": "Zinzino BalanceOil, a natural dietary supplement, helps to increase the omega-3 essential fatty acid levels in your body",
                           "BalanceTest": "This test will provide you vast details of your current Balance-levels. A drop of blood is all it takes",
                           "BalanceOil Capsules": "BalanceOil Capsules are exactly what it sounds like: BalanceOil, conveniently packaged in capsules that effectively adjust the fatty acid balance of the body. The oil consists of the essential omega-3 fatty acids EPA and DHA from fish oil and polyphenols from extra virgin olive oil. With BalanceOil Capsules, it is easy to get in balance and keep it. You don’t need any dosage tools and you avoid making dishes dirty, which makes them perfect for bringing with you when traveling. Just pack the number of capsules that you need and save space in your bag. We recommend keeping unopened and opened boxes at room temperature in a dark, dry place. Follow the dosing references for your body weight. BalanceOil Capsules contain BalanceOil with flavor of vanilla. 1 box contains 120 capsules with 1 ml BalanceOil",
                           "Xtend": "It is the perfect supplement to the BalanceOil, providing you with a complete, extended micro-and phytonutrient support program",
                           "LeanShake": "Zinzino LeanShake is a delicious and nutritious meal replacement for weight loss. Use it to lose fat and build muscles, and simutaneously balancing your microbiome, for gut health ",
                           "ZinoBiotic": "ZinoBiotic is a tailored blend of 5 natural dietary fibers. These fibers are metabolised in the colon (the large intestine) where they support the growth of healthy bacteria. Zinobiotic helps to reduce spiking in blood sugar after meals, and in maintaining good cholesterol levels. The fibers promote many healthy bowel functions including regularity, feelings of fullness and reduced bloating.",
                           "Skin Serum": "The Zinzino Skin Serum is an advanced strategy to Protect, Repair & Rebuild your skins Extracellular Matrix - ECM (afine mesh of microfibres that support the skin) to maintain a youthful skin 24 hours a day.",
                           "Viva": "Sleep, relax and be happy! Viva is a natural dietary supplement that could improve mood and your general wellbeing in several ways.",
                           "Protect": "The ulitamate supplement made to enhance your outmost important defence- The Immune system",
                           "Energy Bar": "Our great tasting energy bar is perfect as a healthy meal before or after training, or as a meal on the go. It is naturally vegan, GMO free and only contains natural sugars. 1 box contains 4 energy bars, á 40g."
    ]
    
    func getProducts() -> [String] {
        var pictures: [String] = []
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("product") {
                pictures.append(item)
            }
        }
        
        pictures = pictures.sorted(by: <)
        return pictures
    }
}
