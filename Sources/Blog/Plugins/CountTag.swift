//
//  CountTag.swift
//  
//
//  Created by Murilo Teixeira on 10/12/23.
//

import Foundation
import Publish

struct CountTag {
    static var count: [Tag: Int] = [:]

    static func count<T: Website>(context: PublishingContext<T>) {
        count = context.allTags.reduce(into: [Tag: Int]()) { partialResult, tag in
            partialResult[tag] = context.items(taggedWith: tag).count
        }
    }
}

extension Tag {
    public var count: Int {
        CountTag.count[self] ?? 0
    }
}

extension Plugin {
    static func countTag() -> Self {
        Plugin(name: "Count tag") { context in
            CountTag.count(context: context)
        }
    }
}
