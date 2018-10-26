//
//  String+DeletePrefix.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-18.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation

extension String {
    func deletePrefixAndSuffix(_ prefix: String, _ suffix: String) -> String {
        guard (self.hasPrefix(prefix) && self.hasSuffix(suffix)) else { return self }
        return String(String(self.dropFirst(prefix.count)).dropLast(suffix.count))
    }
}
