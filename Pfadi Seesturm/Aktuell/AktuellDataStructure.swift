//
//  WordpressDataModels.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

// data structure to parse the JSON coming from the API
struct AktuellResponse: Codable {
    var totalPosts: Int
    var posts: [AktuellPostResponse]
    
    init(totalPosts: Int = 0, posts: [AktuellPostResponse] = []) {
        self.totalPosts = totalPosts
        self.posts = posts
    }
}
struct AktuellPostResponse: Identifiable, Codable {
    
    var id: Int
    var published: Date
    var modified: Date
    var imageUrl: String
    var title: String
    var titleDecoded: String
    var content: String
    var contentPlain: String
    var imageHeight: Int
    var imageWidth: Int
    var author: String
    
    init(
        id: Int = 0,
        published: Date = Date(),
        modified: Date = Date(),
        imageUrl: String = "",
        title: String = "",
        titleDecoded: String = "",
        content: String = "",
        contentPlain: String = "",
        imageHeight: Int = 1,
        imageWidth: Int = 1,
        author: String = ""
    ) {
        self.id = id
        self.published = published
        self.modified = modified
        self.imageUrl = imageUrl
        self.title = title
        self.titleDecoded = titleDecoded
        self.content = content
        self.contentPlain = contentPlain
        self.imageHeight = imageHeight
        self.imageWidth = imageWidth
        self.author = author
    }
    
}

// data structure and extension used to transform the data in a form that can be used to display on the view
struct TransformedAktuellPostResponse: Identifiable, Hashable {
    var id: Int
    var publishedYear: String
    var published: String
    var modified: String
    var imageUrl: String
    var title: String
    var titleDecoded: String
    var content: String
    var contentPlain: String
    var aspectRatio: Double
    var author: String
    
    init(
        id: Int = 0,
        publishedYear: String = "",
        published: String = "",
        modified: String = "",
        imageUrl: String = "",
        title: String = "",
        titleDecoded: String = "",
        content: String = "",
        contentPlain: String = "",
        aspectRatio: Double = 1.0,
        author: String = ""
    ) {
        self.id = id
        self.publishedYear = publishedYear
        self.published = published
        self.modified = modified
        self.imageUrl = imageUrl
        self.title = title
        self.titleDecoded = titleDecoded
        self.content = content
        self.contentPlain = contentPlain
        self.aspectRatio = aspectRatio
        self.author = author
    }
}
extension AktuellPostResponse {
    func toTransformedPost() -> TransformedAktuellPostResponse {
        return TransformedAktuellPostResponse(
            id: id,
            publishedYear: DateTimeUtil.shared.formatDate(date: published, format: "yyyy", withRelativeDateFormatting: false, timeZone: .current),
            published: DateTimeUtil.shared.formatDate(date: published, format: "EEEE, d. MMMM yyyy", withRelativeDateFormatting: true, timeZone: .current).uppercased(),
            modified: DateTimeUtil.shared.formatDate(date: modified, format: "EEEE, d. MMMM yyyy", withRelativeDateFormatting: true, timeZone: .current).uppercased(),
            imageUrl: imageUrl,
            title: title,
            titleDecoded: titleDecoded,
            content: content,
            contentPlain: contentPlain,
            aspectRatio: Double(imageWidth) < Double(imageHeight) ? 1.0 : Double(imageWidth) / Double(imageHeight),
            author: author
        )
    }
}
