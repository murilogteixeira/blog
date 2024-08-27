//
//  SectionTitle.swift
//  
//
//  Created by Murilo Teixeira on 09/12/23.
//

import Foundation
import Publish

extension Plugin where Site == Blog {
    static func addDefaultSectionTitles() -> Self {
        Plugin(name: "Default section titles") { context in
            context.mutateAllSections { section in
                switch section.id {
                case .posts:
                    section.title = "Artigos"
                case .portfolio:
                    section.title = "Portifólio"
                case .about:
                    section.title = "Sobre mim"
                }
            }
        }
    }
}
