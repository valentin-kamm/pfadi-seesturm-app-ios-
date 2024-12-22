//
//  Constants.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

// normal (string) constants
struct Constants {
    
    static var OAUTH_CONFIG = ApplicationConfig(
        issuer: "https://pbs.puzzle.ch",
        clientID: "wKbfjfg_sj0iKpBR8u3QBAOmCkJR0lub3BqlBtbH60I",
        redirectUri: "https://seesturm.ch/oauth/app/callback",
        scope: "email name with_roles openid"
    )
    static var OAUTH_TOKEN_ENDPOINT = URL(string: "https://seesturm.ch/wp-json/seesturmAppCustomEndpoints/v2/oauth/token")!
    
    // Seesturm REST API endpoints
    static var SEESTURM_API_BASE_URL = "https://seesturm.ch/wp-json/seesturmAppCustomEndpoints/v2/"
    
    // placeholder text
    static var PLACEHOLDER_TEXT = "Lorem ipsum odor amet, consectetuer adipiscing elit. Lobortis duis lacinia venenatis dapibus libero proin. Sit suscipit dictum curae bibendum aliquam. Ex diam magna lacinia fringilla id, risus quisque eros. Parturient hendrerit quisque torquent molestie sociosqu suscipit ex semper. Phasellus mus amet iaculis mollis cursus sit nisl. Nulla ac risus suspendisse magna accumsan maecenas. Maximus dictum ac ligula dolor maximus leo dapibus ac vestibulum. Dis adipiscing taciti ad facilisis, nostra massa. Semper ante sociosqu bibendum rhoncus suscipit nullam. Curabitur ante netus volutpat velit, finibus ante hendrerit."
    
    // Base url for google calendar
    static var GOOGLE_CALENDAR_BASE_URL = "https://seesturm.ch/wp-json/seesturmAppCustomEndpoints/v2/events/"
    
    // link to google form for app feedback
    static var FEEDBACK_FORM_URL = "https://docs.google.com/forms/d/e/1FAIpQLSfT0fEhmPpLxrY4sUjkuYwbchMENu1a5pPwpe5NQ2kCqkYL1A/viewform?usp=sf_link"
    
    // datenschutzerklärung
    static var DATENSCHUTZERKLAERUNG_URL = "https://seesturm.ch/datenschutz/"
    
    // max an min artificial delay for network calls
    static var MIN_ARTIFICIAL_DELAY: Double = 0.3
    static var MAX_ARTIFICIAL_DELAY: Double = 0.6
    
    // check if the app is run in debug mode
    static var IS_DEBUG: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    // wetter
    static var WEATHER_URL = "https://seesturm.ch/wp-json/seesturmAppCustomEndpoints/v2/weather"
    
}

// calendar constants
extension CalendarType {
    var info: CalendarInfo {
        switch self {
        case .termine:
            return CalendarInfo(
                calendarId: "app@seesturm.ch",
                subscriptionURL: URL(string: "webcal://calendar.google.com/calendar/ical/app%40seesturm.ch/public/basic.ics")!
            )
        case .termineLeitungsteam:
            return CalendarInfo(
                calendarId: "5975051a11bea77feba9a0990756ae350a8ddc6ec132f309c0a06311b8e45ae1@group.calendar.google.com",
                subscriptionURL: URL(string: "webcal://calendar.google.com/calendar/ical/5975051a11bea77feba9a0990756ae350a8ddc6ec132f309c0a06311b8e45ae1%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenBiberstufe:
            return CalendarInfo(
                calendarId: "c_7520d8626a32cf6eb24bff379717bb5c8ea446bae7168377af224fc502f0c42a@group.calendar.google.com",
                subscriptionURL: URL(string: "webcal://calendar.google.com/calendar/ical/c_7520d8626a32cf6eb24bff379717bb5c8ea446bae7168377af224fc502f0c42a%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenWolfsstufe:
            return CalendarInfo(
                calendarId: "c_e0edfd55e958543f4a4a370fdadcb5cec167e6df847fe362af9c0feb04069a0a@group.calendar.google.com",
                subscriptionURL: URL(string: "webcal://calendar.google.com/calendar/ical/c_e0edfd55e958543f4a4a370fdadcb5cec167e6df847fe362af9c0feb04069a0a%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenPfadistufe:
            return CalendarInfo(
                calendarId: "c_753fcf01c8730c92dfc6be4fac8c4aa894165cf451a993413303eaf016b1647e@group.calendar.google.com",
                subscriptionURL: URL(string: "webcal://calendar.google.com/calendar/ical/c_753fcf01c8730c92dfc6be4fac8c4aa894165cf451a993413303eaf016b1647e%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenPiostufe:
            return CalendarInfo(
                calendarId: "c_be80dc194bbf418bea3a613472f9811df8887e07332a363d6d1ed66056f87f25@group.calendar.google.com",
                subscriptionURL: URL(string: "webcal://calendar.google.com/calendar/ical/c_be80dc194bbf418bea3a613472f9811df8887e07332a363d6d1ed66056f87f25%40group.calendar.google.com/public/basic.ics")!
            )
        }
    }
}
