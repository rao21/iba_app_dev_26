import 'package:flutter/foundation.dart';
import 'package:iba_app_dev_26/features/shop/data/menu_repository.dart';
import 'package:iba_app_dev_26/features/shop/models/dish.dart';


enum MenuStatus { loading, ready, error }

class MenuProvider extends ChangeNotifier {
  MenuProvider(this._repository);

  final MenuRepository _repository;

  MenuStatus _status = MenuStatus.loading;
  List<Dish> _dishes = [];

  MenuStatus get status => _status;
  List<Dish> get dishes => _dishes;

  Future<void> load() async {
    try {
      _dishes = await _repository.load();
      _status = MenuStatus.ready;
    } catch (e) {
      _status = MenuStatus.error;
    }
    notifyListeners();
  }

  Future<void> retry() {
    _status = MenuStatus.loading;
    notifyListeners();
    return load();
  }
}
