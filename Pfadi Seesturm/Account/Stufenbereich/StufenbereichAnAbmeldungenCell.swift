//
//  StufenbereichAnAbmeldungenCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichAnAbmeldungenCell: View {
    
    let event: TransformedCalendarEventResponseWithAnAbmeldungen
    let stufe: SeesturmStufe
    let selectedFilter: AktivitaetAktion
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .leading, spacing: 16) {
                Text(event.title)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(alignment: .center, spacing: 8) {
                    if stufe.allowedActionActivities.contains(.abmelden) && selectedFilter == .abmelden {
                        Label(event.displayTextAbmeldungen, systemImage: AktivitaetAktion.abmelden.icon)
                            .font(.caption)
                            .lineLimit(1)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(UIColor.systemGray5))
                            )
                            .foregroundStyle(Color.SEESTURM_RED)
                            .labelStyle(.titleAndIcon)
                    }
                    if stufe.allowedActionActivities.contains(.anmelden) && selectedFilter == .anmelden {
                        Label(event.displayTextAnmeldungen, systemImage: AktivitaetAktion.anmelden.icon)
                            .font(.caption)
                            .lineLimit(1)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(UIColor.systemGray5))
                            )
                            .foregroundStyle(Color.SEESTURM_GREEN)
                            .labelStyle(.titleAndIcon)
                    }
                }
                CustomCardView(shadowColor: .clear, backgroundColor: Color(UIColor.systemGray5)) {
                    if event.anAbmeldungen.filter({ $0.type == selectedFilter }).isEmpty {
                        Text("Keine \(selectedFilter.nomenMehrzahl)")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .padding()
                    }
                    else {
                        VStack(alignment: .center, spacing: 16) {
                            ForEach(Array(event.anAbmeldungen.filter { $0.type == selectedFilter }.sorted { $0.created > $1.created }.enumerated()), id: \.element.id) { index, abmeldung in
                                if index != 0 {
                                    Divider()
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .center, spacing: 16) {
                                        Text(abmeldung.displayName)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .multilineTextAlignment(.leading)
                                            .fontWeight(.bold)
                                            .font(.caption)
                                        Label(abmeldung.type.nomen, systemImage: abmeldung.type.icon)
                                            .layoutPriority(1)
                                            .font(.caption2)
                                            .lineLimit(1)
                                            .padding(4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.customCardViewBackground)
                                            )
                                            .foregroundStyle(abmeldung.type == .abmelden ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                                            .labelStyle(.titleAndIcon)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(abmeldung.bemerkungForDisplay)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .font(.caption2)
                                    Label("Abgemeldet: \(abmeldung.createdString)", systemImage: "clock")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .font(.caption2)
                                        .foregroundStyle(Color.secondary)
                                        .labelStyle(.titleAndIcon)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    StufenbereichAnAbmeldungenCell(
        event: TransformedCalendarEventResponseWithAnAbmeldungen(
            id: "12312",
            title: "Biberstufenaktivität vom 13.01.2025",
            anAbmeldungen: [
                TransformedAktivitaetAnAbmeldung(
                    id: "123123",
                    eventId: "12312",
                    vorname: "Sepp",
                    nachname: "Müller",
                    pfadiname: "Grizzly",
                    bemerkung: "Hallo",
                    type: .abmelden,
                    stufe: .biber,
                    created: Date(),
                    modified: Date(),
                    createdString: "Heute, 23:00 Uhr",
                    modifiedString: "Heute, 23:00 Uhr"
                ),
                TransformedAktivitaetAnAbmeldung(
                    id: "23423",
                    eventId: "12312",
                    vorname: "Sepp",
                    nachname: "Meier",
                    pfadiname: nil,
                    bemerkung: nil,
                    type: .abmelden,
                    stufe: .biber,
                    created: Date(),
                    modified: Date(),
                    createdString: "Heute, 23:00 Uhr",
                    modifiedString: "Heute, 23:00 Uhr"
                )
            ]
        ),
        stufe: .biber,
        selectedFilter: .anmelden
    )
}
