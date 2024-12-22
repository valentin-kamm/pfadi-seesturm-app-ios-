//
//  WeatherCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.11.2024.
//

import SwiftUI
import WeatherKit

struct WeatherCardView: View {
    
    var weather: TransformedWeatherResponse
    @Environment(\.colorScheme) var colorScheme
    
    @State var selectedGraph: Int = 0
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(weather.daily.day)
                                .lineLimit(3)
                                .fontWeight(.bold)
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Label("Pfadiheim Bergbrücke", systemImage: "location")
                                .lineLimit(3)
                                .labelStyle(.titleAndIcon)
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack {
                                if #available(iOS 17.0, *) {
                                    Text(weather.daily.temperatureMin)
                                        .font(.largeTitle)
                                        .foregroundStyle(Color.secondary)
                                        .fontWeight(.bold) +
                                    Text(" | ")
                                        .font(.largeTitle)
                                        .fontWeight(.ultraLight) +
                                    Text(weather.daily.temperatureMax)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                } else {
                                    Text(weather.daily.temperatureMin)
                                        .font(.largeTitle)
                                        .foregroundColor(Color.secondary)
                                        .fontWeight(.bold) +
                                    Text(" | ")
                                        .font(.largeTitle)
                                        .fontWeight(.ultraLight) +
                                    Text(weather.daily.temperatureMax)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                            Text(weather.daily.description)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .lineLimit(3)
                                .font(.callout)
                        }
                        getWeatherIcon()
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(16/9, contentMode: .fit)
                    }
                    .padding(.bottom, 4)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(alignment: .center, spacing: 16) {
                        CustomCardView(shadowColor: Color.clear, backgroundColor: Color(UIColor.systemGray5)) {
                            Label(weather.daily.precipitationAmount, systemImage: "cloud.rain.fill")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.primary)
                        }
                        CustomCardView(shadowColor: Color.clear, backgroundColor: Color(UIColor.systemGray5)) {
                            Label(weather.daily.windSpeed, systemImage: "wind")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.primary)
                        }
                        CustomCardView(shadowColor: Color.clear, backgroundColor: Color(UIColor.systemGray5)) {
                            Label(weather.daily.cloudCover, systemImage: "cloud.fill")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // graphics
                    TabView {
                        // temperature and precipitation
                        CustomCardView(shadowColor: .primary) {
                            TemperaturePrecipitationChart(weather: weather)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 50)
                        // cloud cover chart
                        CustomCardView(shadowColor: .primary) {
                            CloudCoverChart(weather: weather)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 50)
                        // wind speed chart
                        CustomCardView(shadowColor: .primary) {
                            WindChart(weather: weather)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 50)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 250)
                }
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let attributionUrl = URL(string: weather.attributionURL) {
                Link(destination: attributionUrl) {
                    Label("Apple Weather", systemImage: "apple.logo")
                        .labelStyle(.titleAndIcon)
                        .font(.footnote)
                }
                .foregroundStyle(Color.secondary)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
    
    // function to get icon based on the weather
    private func getWeatherIcon() -> Image {
        switch weather.daily.conditionCode {
        case .blizzard:
            return Image("blizzard" + (colorScheme == .dark ? "-dark" : ""))
        case .blowingDust:
            return Image("blowingDust")
        case .blowingSnow:
            return Image("blizzard" + (colorScheme == .dark ? "-dark" : ""))
        case .breezy:
            return Image("windy" + (colorScheme == .dark ? "-dark" : ""))
        case .clear:
            return Image("clear")
        case .cloudy:
            return Image("cloudy" + (colorScheme == .dark ? "-dark" : ""))
        case .drizzle:
            return Image("hail" + (colorScheme == .dark ? "-dark" : ""))
        case .flurries:
            return Image("flurries" + (colorScheme == .dark ? "-dark" : ""))
        case .foggy:
            return Image("foggy" + (colorScheme == .dark ? "-dark" : ""))
        case .freezingDrizzle:
            return Image("freezingDrizzle" + (colorScheme == .dark ? "-dark" : ""))
        case .freezingRain:
            return Image("freezingDrizzle" + (colorScheme == .dark ? "-dark" : ""))
        case .frigid:
            return Image("frigid" + (colorScheme == .dark ? "-dark" : ""))
        case .hail:
            return Image("hail" + (colorScheme == .dark ? "-dark" : ""))
        case .haze:
            return Image("foggy" + (colorScheme == .dark ? "-dark" : ""))
        case .heavyRain:
            return Image("heavyRain" + (colorScheme == .dark ? "-dark" : ""))
        case .heavySnow:
            return Image("snow" + (colorScheme == .dark ? "-dark" : ""))
        case .hot:
            return Image("hot")
        case .hurricane:
            return Image("hurricane" + (colorScheme == .dark ? "-dark" : ""))
        case .isolatedThunderstorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .mostlyClear:
            return Image("mostlyClear" + (colorScheme == .dark ? "-dark" : ""))
        case .mostlyCloudy:
            return Image("cloudy" + (colorScheme == .dark ? "-dark" : ""))
        case .partlyCloudy:
            return Image("mostlyClear" + (colorScheme == .dark ? "-dark" : ""))
        case .rain:
            return Image("heavyRain" + (colorScheme == .dark ? "-dark" : ""))
        case .scatteredThunderstorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .sleet:
            return Image("hail" + (colorScheme == .dark ? "-dark" : ""))
        case .smoky:
            return Image("foggy" + (colorScheme == .dark ? "-dark" : ""))
        case .snow:
            return Image("snow" + (colorScheme == .dark ? "-dark" : ""))
        case .strongStorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .sunFlurries:
            return Image("sunFlurries" + (colorScheme == .dark ? "-dark" : ""))
        case .sunShowers:
            return Image("sunShowers" + (colorScheme == .dark ? "-dark" : ""))
        case .thunderstorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .tropicalStorm:
            return Image("hurricane" + (colorScheme == .dark ? "-dark" : ""))
        case .windy:
            return Image("windy" + (colorScheme == .dark ? "-dark" : ""))
        case .wintryMix:
            return Image("wintryMix" + (colorScheme == .dark ? "-dark" : ""))
        default:
            return Image(systemName: "questionmark.square.dashed")
        }
    }
    
}

#Preview {
    
    WeatherCardView(
        weather: WeatherPreviewSampleDataProvider.shared.sampleData()
    )
    
}

class WeatherPreviewSampleDataProvider {
    static let shared = WeatherPreviewSampleDataProvider()
    func sampleData() -> TransformedWeatherResponse {
        let jsonString = """
    {
      "attributionURL": "https://developer.apple.com/weatherkit/data-source-attribution/",
      "readTime": "2024-11-30T15:58:08Z",
      "daily": {
        "forecastStart": "2024-11-30T07:00:00Z",
        "forecastEnd": "2024-11-30T19:00:00Z",
        "conditionCode": "MostlyClear",
        "temperatureMax": 3.55,
        "temperatureMin": -1.9,
        "precipitationAmount": 0,
        "precipitationChance": 0,
        "snowfallAmount": 0,
        "cloudCover": 0.32,
        "humidity": 0.82,
        "windDirection": 329,
        "windSpeed": 2.98,
        "sunrise": "2024-11-30T06:48:46Z",
        "sunset": "2024-11-30T15:34:02Z"
      },
      "hourly": [
        {
          "forecastStart": "2024-11-30T05:00:00Z",
          "cloudCover": 0.51,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": -1.52,
          "windSpeed": 3.11,
          "windGust": 7.07
        },
        {
          "forecastStart": "2024-11-30T06:00:00Z",
          "cloudCover": 0.56,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": -1.64,
          "windSpeed": 2.86,
          "windGust": 6.88
        },
        {
          "forecastStart": "2024-11-30T07:00:00Z",
          "cloudCover": 0.49,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": -1.9,
          "windSpeed": 3,
          "windGust": 6.01
        },
        {
          "forecastStart": "2024-11-30T08:00:00Z",
          "cloudCover": 0.52,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": -1.02,
          "windSpeed": 3.42,
          "windGust": 7.85
        },
        {
          "forecastStart": "2024-11-30T09:00:00Z",
          "cloudCover": 0.51,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": -0.39,
          "windSpeed": 3.64,
          "windGust": 9.62
        },
        {
          "forecastStart": "2024-11-30T10:00:00Z",
          "cloudCover": 0.38,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 0.71,
          "windSpeed": 2.79,
          "windGust": 8.15
        },
        {
          "forecastStart": "2024-11-30T11:00:00Z",
          "cloudCover": 0.36,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 2.09,
          "windSpeed": 3.02,
          "windGust": 10.06
        },
        {
          "forecastStart": "2024-11-30T12:00:00Z",
          "cloudCover": 0.22,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 3.27,
          "windSpeed": 3.63,
          "windGust": 11.56
        },
        {
          "forecastStart": "2024-11-30T13:00:00Z",
          "cloudCover": 0.22,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 3.55,
          "windSpeed": 3.29,
          "windGust": 10.86
        },
        {
          "forecastStart": "2024-11-30T14:00:00Z",
          "cloudCover": 0.27,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 3.34,
          "windSpeed": 2.79,
          "windGust": 9.84
        },
        {
          "forecastStart": "2024-11-30T15:00:00Z",
          "cloudCover": 0.27,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 2.49,
          "windSpeed": 2.55,
          "windGust": 7.97
        },
        {
          "forecastStart": "2024-11-30T16:00:00Z",
          "cloudCover": 0.25,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 1.35,
          "windSpeed": 2.7,
          "windGust": 6.99
        },
        {
          "forecastStart": "2024-11-30T17:00:00Z",
          "cloudCover": 0.27,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 0.96,
          "windSpeed": 2.82,
          "windGust": 5.41
        },
        {
          "forecastStart": "2024-11-30T18:00:00Z",
          "cloudCover": 0.22,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 0.61,
          "windSpeed": 2.36,
          "windGust": 4.74
        }
      ]
    }
    """
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
            isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            return isoFormatter.date(from: dateString)!
        }
        return try! decoder.decode(WeatherResponse.self, from: data).toTransformedWeatherResponse()
    }
}
