//
//  GespeichertePersonenDataStructure.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 10.11.2024.
//

import Foundation

struct GespeichertePerson: Codable, Identifiable {
    var id: UUID
    var vorname: String
    var nachname: String
    var pfadiname: String?
}
