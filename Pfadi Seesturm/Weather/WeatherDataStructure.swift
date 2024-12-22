//
//  WeatherDataStructures.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.11.2024.
//

import Foundation
import WeatherKit


struct WeatherResponse: Codable {
    var attributionURL: String
    var readTime: Date
    var daily: DailyWeatherForecastResponse
    var hourly: [HourlyWeatherForecastResponse]
    init(
        attributionURL: String = "",
        readTime: Date = Date(),
        daily: DailyWeatherForecastResponse = DailyWeatherForecastResponse(),
        hourly: [HourlyWeatherForecastResponse] = []
    ) {
        self.attributionURL = attributionURL
        self.readTime = readTime
        self.daily = daily
        self.hourly = hourly
    }
}
struct DailyWeatherForecastResponse: Codable {
    var forecastStart: Date
    var forecastEnd: Date
    var conditionCode: String
    var temperatureMax: Double
    var temperatureMin: Double
    var precipitationAmount: Double
    var precipitationChance: Double
    var snowfallAmount: Double
    var cloudCover: Double
    var humidity: Double
    var windDirection: Double
    var windSpeed: Double
    var sunrise: Date
    var sunset: Date
    init(
        forecastStart: Date = Date(),
        forecastEnd: Date = Date(),
        conditionCode: String = "",
        temperatureMax: Double = 0.0,
        temperatureMin: Double = 0.0,
        precipitationAmount: Double = 0.0,
        precipitationChance: Double = 0.0,
        snowfallAmount: Double = 0.0,
        cloudCover: Double = 0.0,
        humidity: Double = 0.0,
        windDirection: Double = 0.0,
        windSpeed: Double = 0.0,
        sunrise: Date = Date(),
        sunset: Date = Date()
    ) {
        self.forecastStart = forecastStart
        self.forecastEnd = forecastEnd
        self.conditionCode = conditionCode
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.precipitationAmount = precipitationAmount
        self.precipitationChance = precipitationChance
        self.snowfallAmount = snowfallAmount
        self.cloudCover = cloudCover
        self.humidity = humidity
        self.windDirection = windDirection
        self.windSpeed = windSpeed
        self.sunrise = sunrise
        self.sunset = sunset
    }
}
struct HourlyWeatherForecastResponse: Codable {
    var forecastStart: Date
    var cloudCover: Double
    var precipitationType: String
    var precipitationAmount: Double
    var snowfallAmount: Double
    var temperature: Double
    var windSpeed: Double
    var windGust: Double
    init(
        forecastStart: Date = Date(),
        cloudCover: Double = 0.0,
        precipitationType: String = "",
        precipitationAmount: Double = 0.0,
        snowfallAmount: Double = 0.0,
        temperature: Double = 0.0,
        windSpeed: Double = 0.0,
        windGust: Double = 0.0
    ) {
        self.forecastStart = forecastStart
        self.cloudCover = cloudCover
        self.precipitationType = precipitationType
        self.precipitationAmount = precipitationAmount
        self.snowfallAmount = snowfallAmount
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.windGust = windGust
    }
}

// data structures for transformed data
struct TransformedWeatherResponse: Codable {
    var attributionURL: String
    var readTime: String
    var daily: TransformedWeatherForecastResponse
    var hourly: [TransformedHourlyWeatherForecastResponse]
    init(
        attributionURL: String = "",
        readTime: String = "",
        daily: TransformedWeatherForecastResponse = TransformedWeatherForecastResponse(),
        hourly: [TransformedHourlyWeatherForecastResponse] = []
    ) {
        self.attributionURL = attributionURL
        self.readTime = readTime
        self.daily = daily
        self.hourly = hourly
    }
}
struct TransformedWeatherForecastResponse: Codable {
    var forecastStart: Date
    var forecastEnd: Date
    var day: String
    var conditionCode: WeatherCondition?
    var description: String
    var temperatureMax: String
    var temperatureMin: String
    var precipitationAmount: String
    var precipitationChance: String
    var snowfallAmount: String
    var cloudCover: String
    var humidity: String
    var windDirection: String
    var windSpeed: String
    var sunrise: Date
    var sunriseString: String
    var sunset: Date
    var sunsetString: String
    init(
        forecastStart: Date = Date(),
        forecastEnd: Date = Date(),
        day: String = "",
        conditionCode: WeatherCondition? = nil,
        description: String = "",
        temperatureMax: String = "",
        temperatureMin: String = "",
        precipitationAmount: String = "",
        precipitationChance: String = "",
        snowfallAmount: String = "",
        cloudCover: String = "",
        humidity: String = "",
        windDirection: String = "",
        windSpeed: String = "",
        sunrise: Date = Date(),
        sunriseString: String = "",
        sunset: Date = Date(),
        sunsetString: String = ""
    ) {
        self.forecastStart = forecastStart
        self.forecastEnd = forecastEnd
        self.day = day
        self.conditionCode = conditionCode
        self.description = description
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.precipitationAmount = precipitationAmount
        self.precipitationChance = precipitationChance
        self.snowfallAmount = snowfallAmount
        self.cloudCover = cloudCover
        self.humidity = humidity
        self.windDirection = windDirection
        self.windSpeed = windSpeed
        self.sunrise = sunrise
        self.sunriseString = sunriseString
        self.sunset = sunset
        self.sunsetString = sunsetString
    }
}
struct TransformedHourlyWeatherForecastResponse: Codable, Identifiable {
    var id: UUID
    var forecastStart: Date
    var cloudCover: Double
    var precipitationType: String
    var precipitationAmount: Double
    var snowfallAmount: Double
    var temperature: Double
    var windSpeed: Double
    var windGust: Double
    init(
        id: UUID = UUID(),
        forecastStart: Date = Date(),
        cloudCover: Double = 0.0,
        precipitationType: String = "",
        precipitationAmount: Double = 0.0,
        snowfallAmount: Double = 0.0,
        temperature: Double = 0.0,
        windSpeed: Double = 0.0,
        windGust: Double = 0.0
    ) {
        self.id = id
        self.forecastStart = forecastStart
        self.cloudCover = cloudCover
        self.precipitationType = precipitationType
        self.precipitationAmount = precipitationAmount
        self.snowfallAmount = snowfallAmount
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.windGust = windGust
    }
}
extension WeatherResponse {
    func toTransformedWeatherResponse() -> TransformedWeatherResponse {
        return TransformedWeatherResponse(
            attributionURL: attributionURL,
            readTime: DateTimeUtil.shared.formatDate(date: readTime, format: "dd.MM.yyyy, HH:dd", withRelativeDateFormatting: true, timeZone: .current),
            daily: daily.toTransformedWeatherResponse(),
            hourly: hourly.map { $0.toTransformedWeatherResponse() }
        )
    }
}
extension DailyWeatherForecastResponse {
    func toTransformedWeatherResponse() -> TransformedWeatherForecastResponse {
        return TransformedWeatherForecastResponse(
            forecastStart: forecastStart,
            forecastEnd: forecastEnd,
            day: DateTimeUtil.shared.formatDate(date: forecastStart, format: "EEEE, d. MMMM", withRelativeDateFormatting: true, includeTimeInRelativeFormatting: false, timeZone: .current),
            conditionCode: WeatherUtils.shared.convertConditionCode(code: conditionCode),
            description: WeatherUtils.shared.getGermanWeatherDescription(condition: WeatherUtils.shared.convertConditionCode(code: conditionCode)),
            temperatureMax: "\(Int(round(temperatureMax)))°",
            temperatureMin: "\(Int(round(temperatureMin)))°",
            precipitationAmount: "\(Int(round(precipitationAmount))) mm",
            precipitationChance: "\(Int(round(100 * precipitationChance))) %",
            snowfallAmount: "\(Int(round(snowfallAmount))) mm",
            cloudCover: "\(Int(round(100 * cloudCover))) %",
            humidity: "\(Int(round(100 * humidity))) %",
            windDirection: WeatherUtils.shared.convertWindDirection(direction: windDirection),
            windSpeed: "\(Int(round(windSpeed))) km/h",
            sunrise: sunrise,
            sunriseString: DateTimeUtil.shared.formatDate(date: sunrise, format: "HH:mm", withRelativeDateFormatting: false, timeZone: .current),
            sunset: sunset,
            sunsetString: DateTimeUtil.shared.formatDate(date: sunset, format: "HH:mm", withRelativeDateFormatting: false, timeZone: .current)
        )
    }
}
extension HourlyWeatherForecastResponse {
    func toTransformedWeatherResponse() -> TransformedHourlyWeatherForecastResponse {
        return TransformedHourlyWeatherForecastResponse(
            id: UUID(),
            forecastStart: forecastStart,
            cloudCover: 100 * cloudCover,
            precipitationType: precipitationType,
            precipitationAmount: precipitationAmount,
            snowfallAmount: snowfallAmount,
            temperature: temperature,
            windSpeed: windSpeed,
            windGust: windGust
        )
    }
}

class WeatherUtils {
    static let shared = WeatherUtils()
    func convertWindDirection(direction: Double) -> String {
        let ranges: [Range<Double>] = [
            11.25..<33.75,
            33.75..<56.25,
            56.25..<78.75,
            78.75..<101.25,
            101.25..<123.75,
            123.75..<146.25,
            146.25..<168.75,
            168.75..<191.25,
            191.25..<213.75,
            213.75..<236.25,
            236.25..<258.75,
            258.75..<281.25,
            281.25..<303.75,
            303.75..<326.25,
            326.25..<348.75
        ]
        let directions: [String] = [
            "NNO",
            "NO",
            "ONO",
            "O",
            "OSO",
            "SO",
            "SSO",
            "S",
            "SSW",
            "SW",
            "WSW",
            "W",
            "WNW",
            "NW",
            "NNW",
        ]
        for (index, range) in ranges.enumerated() {
            if range.contains(direction) {
                return directions[index]
            }
        }
        return "N"
    }
    func convertConditionCode(code: String) -> WeatherCondition? {
        let firstLetter = code.prefix(1).lowercased()
        let correctedCode = firstLetter + code.dropFirst(1)
        return WeatherCondition(rawValue: correctedCode)
    }
    func getGermanWeatherDescription(condition: WeatherCondition?) -> String {
        if let condition = condition {
            return condition.description
        }
        else {
            return "Unbekannt"
        }
    }
}
