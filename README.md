<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
# Juice

A custom interpreter and DSL (domain specific language) for manipulating timeseries.  

## Examples

These are all hypothetical -- nothing is working yet.  

Get an hourly series, filter it, and aggregate it to calculate the daily mean.
```
var x = get('nepool_da_lmp_4000');
print x.timeZoneLocation;  // America/New_York 
var y = x.filter(hour in Bucket.5x16).toDaily("mean");
print y.head(); // print the first 6 observations
show y; // displays this timeseries to the chart
```

Do operations with timeseries.  Get the min and max daily temperature and calculate 
the daily average.
```
var tMin = get('noaa_kbos_daily_tmax'); 
var tMax = get('noaa_kbos_daily_tmax');
var tMean = (tMin + tMax)/2;
print tMean.head();
show tMean;
```


## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

Custom functions are implemented in the `Interpreter` 

### Credits
The implementation is based on the book [Crafting interpreters](https://craftinginterpreters.com/) 
by Robert Nystrom, in particular the Dart implementation from 
[sma/lox](https://github.com/sma/lox).