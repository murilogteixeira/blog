import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct Blog: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
        case portfolio
        case about
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://murilot.com")!
    var name = "Murilo Teixeira"
    var description = "A description of Blog"
    var language: Language { .brPortuguese }
    var imagePath: Path? { nil }
}

// This will generate your website using the built-in Foundation theme:
try Blog().publish(using: [
    .addMarkdownFiles(),
    .copyResources(),
    .installPlugin(.addDefaultSectionTitles()),
    .installPlugin(.countTag()),
    .generateHTML(withTheme: .foundation),
    .generateRSSFeed(including: [.posts]),
    .generateSiteMap()
])
