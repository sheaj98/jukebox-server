//
//  Int+Extentions.swift
//  App
//
//  Created by Shea Sullivan on 2018-08-31.
//

import Foundation
import Vapor
import SwiftRandom

func fiveDigitNumber(req: Request) -> Future<String> {
    let key = Randoms.randomInt(lower: 10000, 99999)
    return Future.map(on: req) { String(key) }
}
