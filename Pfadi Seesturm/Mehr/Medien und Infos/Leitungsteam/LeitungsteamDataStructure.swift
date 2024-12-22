//
//  LeitungsteamDataStructure.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI

typealias LeitungsteamResponse = [LeitungsteamStufeResponse]
struct LeitungsteamStufeResponse: Codable, Identifiable {
    let id: UUID
    let teamName: String
    let teamId: Int
    let members: [LeitungsteamMemberResponse]
    
    init(
        id: UUID = UUID(),
        teamName: String = "",
        teamId: Int = 0,
        members: [LeitungsteamMemberResponse] = []
    ) {
        self.id = id
        self.teamName = teamName
        self.teamId = teamId
        self.members = members
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.teamName = try container.decode(String.self, forKey: .teamName)
        self.teamId = try container.decode(Int.self, forKey: .teamId)
        self.members = try container.decode([LeitungsteamMemberResponse].self, forKey: .members)
    }
    
}
struct LeitungsteamMemberResponse: Codable, Identifiable {
    let id: UUID
    let name: String
    let job: String
    let contact: String
    let photo: String
    
    init(
        id: UUID = UUID(),
        name: String = "",
        job: String = "",
        contact: String = "",
        photo: String = ""
    ) {
        self.id = id
        self.name = name
        self.job = job
        self.contact = contact
        self.photo = photo
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.job = try container.decode(String.self, forKey: .job)
        self.contact = try container.decode(String.self, forKey: .contact)
        self.photo = try container.decode(String.self, forKey: .photo)
    }
    
}
