# Rails Weather Forecast

This is a Rails application that provides weather forecasts for locations in the United States. It uses the Google Maps
[Geocoding API](https://developers.google.com/maps/documentation/geocoding/overview) to convert addresses into latitude
and longitude coordinates, and then fetches weather data from the
[Google Weather API](https://developers.google.com/maps/documentation/weather).

Run the application: `bin/dev`

Run the tests: `bin/rails test`

## Routing

The resulting forecast is available at a URL like `/forecasts/81435` where `81435` is a 5-digit zip code. I chose this
approach because it ensures the URL can be refreshed and shared, while still using the cached forecast data.

## Caching

In production, this application uses SolidCache to durably cache expensive geocoding results (1 week) and weather
forecasts (30 minutes). Because the system redirects the user after creating the forecast, the user will see "Cached:
Yes" when they initially create the forecast. This is because the system creates the forecast, and then immediately
fetches it from the cache to display it on the redirected page. If you enter an un-cached zip code in the URL, you'll
see "Cached No" instead.

## Design

There are no ActiveRecord models in this application. Rather, the app stores the data ephemerally in the cache. API
calls and cache lookups are managed by service objects. A handful of ActiveModel domain objects encapsulate the data
of the application.

The system parallelizes the calls to get the current conditions and the forecast data.

## Testing

Tests are minimal for this application, mainly because I was limited on time. There are controller tests, but a true
testing suite would include unit tests for the services, domain objects, and API clients, as well as browser integration
tests. Webmock ensures the tests do not make network calls.

## Future Considerations

This app currently does not support i18n, nor non-USA locations. Address lookups are cached for one week, but a
more-robust caching strategy could be warranted, since addresses and their coordinates are (generally) immutable.

Furthermore, I've implemented basic Geocoding and Weather clients. For a more robust implemenation, I'd generate a
client/types from the OpenAPI spec.