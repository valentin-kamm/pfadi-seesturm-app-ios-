//
//  TermineDetailView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.11.2024.
//

import SwiftUI
import RichText

struct TermineDetailView: View {
    
    let event: TransformedCalendarEventResponse
    let calendarInfo: CalendarInfo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(event.title)
                    .multilineTextAlignment(.leading)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Label {
                    Text(event.fullDateTimeString)
                        .foregroundStyle(Color.secondary)
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(Color.SEESTURM_GREEN)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let location = event.location {
                    Label {
                        Text(location)
                            .foregroundStyle(Color.secondary)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "location")
                            .foregroundStyle(Color.SEESTURM_GREEN)
                    }
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let description = event.description {
                    RichText(html: description)
                        .transition(.none)
                        .linkOpenType(.SFSafariView())
                        .placeholder(content: {
                            Text(Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT)
                                .padding(.bottom, -100)
                                .padding(.horizontal)
                                .font(.body)
                                .redacted(reason: .placeholder)
                                .customLoadingBlinking()
                        })
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    UIApplication.shared.open(calendarInfo.subscriptionURL)
                }) {
                    Image(systemName: "calendar.badge.plus")
                }
            }
        }
    }
}

#Preview("Mehrtägiger Anlass") {
    TermineDetailView(event: TermineCardViewPreviewExtension().multiDayEventData(), calendarInfo: CalendarType.termine.info)
}

#Preview("Eintägiger Anlass") {
    TermineDetailView(event: TermineCardViewPreviewExtension().oneDayEventData(), calendarInfo: CalendarType.termine.info)
}
#Preview("Ganztägiger, mehrtägiger Anlass") {
    TermineDetailView(event: TermineCardViewPreviewExtension().allDayMultiDayEventData(), calendarInfo: CalendarType.termine.info)
}
#Preview("Ganztägiger, eintägiger Anlass") {
    TermineDetailView(event: TermineCardViewPreviewExtension().allDayOneDayEventData(), calendarInfo: CalendarType.termine.info)
}
