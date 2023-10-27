$version: "2"
namespace my.weather
use aws.protocols#restJson1

/// Provides weather forecasts.
@restJson1
service Weather {
    version: "2006-03-01"
    resources: [Forecast]
}

resource Forecast {
    identifiers: { cityId: CityId }
    read: GetForecast,
}

// "pattern" is a trait.
@pattern("^[A-Za-z0-9 ]+$")
string CityId

@range(min: 1, max: 100)
integer Page

// "error" is a trait that is used to specialize
// a structure as an error.
@error("client")
@httpError(404)
structure NoSuchResource {}

// The paginatedd is a custom trait, indicating that the operation may
// return truncated results. We use our own custom trait, so `page`
// field could be configured as integer instead of string.
@readonly
@suppress(["PaginatedTrait"])
@paginated(
    inputToken: "page"
    outputToken: "page"
    pageSize: "per_page"
    items: "data"
)
@http(method: "GET", uri: "/forecast")
operation GetForecast {
    input: GetForecastInput
    output: GetForecastOutput
    errors: [NoSuchResource]
}

// "cityId" provides the only identifier for the resource since
// a Forecast doesn't have its own.
@input
structure GetForecastInput {
    @required
    @httpQuery("cityId")
    cityId: CityId

    @httpQuery("page")
    page: Page
    @httpQuery("per_page")
    per_page: Page
}

@output
structure GetForecastOutput {
    page: Page
    per_page: Page
    total: Page
    total_pages: Page

    @required
    data: ForecastSummaries
}

list ForecastSummaries {
    member: ForecastSummary
}

structure ForecastSummary {
    @required
    name: String
    weather: ForecastSummaryWeather
    status: ForecastSummaryStatuses
}

@pattern("^\\d{1,3} degree$")
string ForecastSummaryWeather

@pattern("^Wind: \\d{1,3}Kmph$|^Humidity: \\d{1,3}%$")
string WindOrHumidity

@length(min: 2, max: 2)
list ForecastSummaryStatuses {
    member: WindOrHumidity
}

apply GetForecast @examples([
    {
        title: "page1"
        input: {
            cityId: "all"
            page: 1
        }
        output: {
            page: 1,
            per_page: 3,
            total: 7,
            total_pages: 3,
            data: [
                {
                    "name": "Dallas",
                    "weather": "12 degree",
                    "status": [
                        "Wind: 2Kmph",
                        "Humidity: 5%"
                    ]
                },
                {
                    "name": "Dallupura",
                    "weather": "10 degree",
                    "status": [
                        "Wind: 9Kmph",
                        "Humidity: 14%"
                    ]
                },
                {
                    "name": "Vallejo",
                    "weather": "1 degree",
                    "status": [
                        "Wind: 24Kmph",
                        "Humidity: 56%"
                    ]
                }
            ]
        }
    }
    {
        title: "page2"
        input: {
            cityId: "all"
            page: 2
        }
        output: {
            "page": 2,
            "per_page": 3,
            "total": 7,
            "total_pages": 3,
            "data": [
                {
                    "name": "Montreal",
                    "weather": "17 degree",
                    "status": [
                        "Wind: 42Kmph",
                        "Humidity: 10%"
                    ]
                },
                {
                    "name": "Sofia",
                    "weather": "25 degree",
                    "status": [
                        "Wind: 1Kmph",
                        "Humidity: 15%"
                    ]
                },
                {
                    "name": "Varna",
                    "weather": "30 degree",
                    "status": [
                        "Wind: 2Kmph",
                        "Humidity: 62%"
                    ]
                }
            ]
        }
    }
    {
        title: "page3"
        input: {
            cityId: "all"
            page: 3
        }
        output: {
            "page": 3,
            "per_page": 3,
            "total": 7,
            "total_pages": 3,
            "data": [
                {
                    "name": "Chicago",
                    "weather": "23 degree",
                    "status": [
                        "Wind: 8Kmph",
                        "Humidity: 5%"
                    ]
                }
            ]
        }
    }
    // {
    //     title: "Error example for MyOperation"
    //     input: {
    //         cityId: "unknown"
    //     }
    //     error: {
    //         shapeId: NoSuchResource
    //         // content: {
    //         //     message: "Invalid 'foo'. Special character not allowed."
    //         // }
    //     },
    //     // allowConstraintErrors: true
    // }
])
