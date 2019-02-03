# Flickr App

An app written in a day as part of a coding challenge using [Flickr's APIs](https://www.flickr.com/services/api/) to browse and search recent images.

![](demo.gif)

## Features

- View recent photos uploaded to Flicker
- Search the latest public photos posted to Flickr
- View total search result count
- View large resolution images
- Optimised image loading
- Image caching
- Animations

There are 3 screens in the app, the home screen, the photo screen and the search screen.

### Future

- Pagination
- Pull to refresh

## Approach

I used Alamofire for the requests as it made parsing the JSON responses simpler, for a bigger project I would have used my own wrapper that integrates with Core Data to give more power implementing features.

```
JSON → Core Data object → NSFetchedResultsController
```

A deep diff framework is useful when it comes to updates, I included DeepDiff in this project with plans to implement pagination and pull to refresh but it was not needed.

### Prerequisites

[CocoaPods](https://cocoapods.org)

### Installing

Navigate to the project directory and run

```
pod install
```

then open

```
Flickr.xcworkspace
```

## Built With

- [Swift](https://github.com/apple/swift)
- [Alamofire](https://github.com/Alamofire/Alamofire)\*
- [DeepDiff](https://github.com/onmyway133/DeepDiff)\*

\*not really needed, but sped up development

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
