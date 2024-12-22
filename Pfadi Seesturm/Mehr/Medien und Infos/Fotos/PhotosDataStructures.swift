//
//  PhotosDataStructures.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

// Für Pfadijahre
struct PfadijahreResponse: Codable {
    var albums: [PfadijahreAlbumResponse]
    
    init(albums: [PfadijahreAlbumResponse] = []) {
        self.albums = albums
    }
}
struct PfadijahreAlbumResponse: Codable, Identifiable, Hashable {
    var title: String
    var id: String
    var thumbnail: String
    
    init(title: String = "", id: String = "", thumbnail: String = "") {
        self.title = title
        self.id = id
        self.thumbnail = thumbnail
    }
}

// für gallerien zu jedem Pfadijahr
struct GalleriesResponse: Codable {
    var galleries: [PhotoGalleryResponse]
    
    init(galleries: [PhotoGalleryResponse] = []) {
        self.galleries = galleries
    }
}
struct PhotoGalleryResponse: Codable, Identifiable, Hashable {
    var title: String
    var id: String
    var thumbnail: String
    
    init(title: String = "", id: String = "", thumbnail: String = "") {
        self.title = title
        self.id = id
        self.thumbnail = thumbnail
    }
}

// für fotos in den einzelnen gallerien
struct ImagesResponse: Codable {
    var images: [SeesturmWordpressImageResponse]
    
    init(images: [SeesturmWordpressImageResponse] = []) {
        self.images = images
    }
}
struct SeesturmWordpressImageResponse: Codable, Identifiable {
    var id: UUID
    var thumbnail: String
    var original: String
    var orientation: String
    var height: Int
    var width: Int
    // Custom initializer that ensures UUID is generated when decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode other properties
        self.thumbnail = try container.decode(String.self, forKey: .thumbnail)
        self.original = try container.decode(String.self, forKey: .original)
        self.orientation = try container.decode(String.self, forKey: .orientation)
        self.height = try container.decode(Int.self, forKey: .height)
        self.width = try container.decode(Int.self, forKey: .width)
        // Generate a new UUID for id
        self.id = UUID()
    }
    // CodingKeys enum for decoding
    enum CodingKeys: String, CodingKey {
        case thumbnail
        case original
        case orientation
        case height
        case width
    }
    // Regular initializer
    init(id: UUID = UUID(), thumbnail: String = "", original: String = "", orientation: String = "", height: Int = 1, width: Int = 1) {
        self.id = id
        self.thumbnail = thumbnail
        self.original = original
        self.orientation = orientation
        self.height = height
        self.width = width
    }
}
