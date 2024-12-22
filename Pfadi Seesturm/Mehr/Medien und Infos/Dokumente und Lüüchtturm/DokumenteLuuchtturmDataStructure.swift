//
//  DokumenteLuuchtturmDataStructure.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.10.2024.
//

import SwiftUI

struct SeesturmWordpressDocumentResponse: Identifiable, Codable {
    
    var id: String
    var thumbnailUrl: String
    var thumbnailWidth: Int
    var thumbnailHeight: Int
    var title: String
    var url: String
    var published: Date
    
    init(
        id: String = "",
        thumbnailUrl: String = "",
        thumbnailWidth: Int = 212,
        thumbnailHeight: Int = 300,
        title: String = "",
        url: String = "",
        published: Date = Date()
    ) {
        self.id = id
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
        self.title = title
        self.url = url
        self.published = published
    }
    
}

// data structure and extension used to transform the data in a form that can be used to display on the view
struct TransformedSeesturmWordpressDocumentResponse: Identifiable {
    
    var id: String
    var thumbnailUrl: String
    var thumbnailWidth: Int
    var thumbnailHeight: Int
    var title: String
    var url: String
    var published: String
    
    init(
        id: String = "",
        thumbnailUrl: String = "",
        thumbnailWidth: Int = 212,
        thumbnailHeight: Int = 300,
        title: String = "",
        url: String = "",
        published: String = ""
    ) {
        self.id = id
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
        self.title = title
        self.url = url
        self.published = published
    }
    
}
extension SeesturmWordpressDocumentResponse {
    func toTransformedDocument() -> TransformedSeesturmWordpressDocumentResponse {
        return TransformedSeesturmWordpressDocumentResponse(
            id: id,
            thumbnailUrl: thumbnailUrl,
            thumbnailWidth: thumbnailWidth,
            thumbnailHeight: thumbnailHeight,
            title: title,
            url: url,
            published: DateTimeUtil.shared.formatDate(date: published, format: "EEEE, d. MMMM yyyy", withRelativeDateFormatting: true, timeZone: .current).uppercased()
        )
    }
}
