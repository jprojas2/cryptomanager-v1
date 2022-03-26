import 'package:crypto_manager/models/user_configuration.dart';
import 'package:crypto_manager/services/price_finder.dart';

class Valorizable {
  Map<String, double> _profitabilities = {};
  late PriceFinder priceFinder;
  late String? coin;

  Valorizable(this.coin);

  double? profitability(String period) {
    return _profitabilities[period];
  }

  Future<void> computeProfitabilities(List<String> periods,
      [PriceFinder? _priceFinder]) async {
    await Future.wait(
        periods.map((v) => computeProfitability(v, _priceFinder)));
  }

  Future<void> computeProfitability(String period,
      [PriceFinder? _priceFinder]) async {
    UserConfiguration userConfiguration =
        await UserConfiguration.getConfiguration();
    if (!userConfiguration.calculateProfitability) return;
    print("Computing profit ${period}: " + coin!);
    PriceFinder pf = _priceFinder != null ? _priceFinder : priceFinder;
    switch (period) {
      case "1h":
        {
          double _currentPrice = await pf.currentPrice(coin);
          DateTime anHourAgo = (new DateTime.now())
              .subtract(new Duration(minutes: Duration.minutesPerHour));
          double _historicPrice = await pf.historicPrice(coin!, anHourAgo);
          if (_historicPrice != 0.0)
            _profitabilities[period] = _currentPrice / _historicPrice - 1.0;
        }
        break;
      case "24h":
        {
          (priceFinder);
          double _currentPrice = await pf.currentPrice(coin);
          print(_currentPrice);
          DateTime aDayAgo = (new DateTime.now())
              .subtract(new Duration(minutes: Duration.minutesPerDay));
          double _historicPrice = await pf.historicPrice(coin!, aDayAgo);
          if (_historicPrice != 0.0)
            _profitabilities[period] = _currentPrice / _historicPrice - 1.0;
        }
        break;
      case "1w":
        {
          double _currentPrice = await priceFinder.currentPrice(coin);
          DateTime aWeekAgo = (new DateTime.now())
              .subtract(Duration(minutes: 7 * Duration.minutesPerDay))
              .add(Duration(minutes: 120));
          double _historicPrice =
              await priceFinder.historicPrice(coin!, aWeekAgo);
          if (_historicPrice != 0.0)
            _profitabilities[period] = _currentPrice / _historicPrice - 1.0;
        }
        break;
      default:
        {}
        break;
    }
    print("Computed profit ${period}: " + coin!);
  }
}
