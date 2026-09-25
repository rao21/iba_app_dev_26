import 'package:flutter/material.dart';
import 'package:iba_app_dev_26/activities/api_client.dart';
import 'package:iba_app_dev_26/activities/error.dart';
import 'package:iba_app_dev_26/activities/models.dart';

enum ViewState { loading, success, error, empty }

class UserListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<UserModel> _allUsers = [];
  List<UserModel> _visibleUsers = [];
  final Set<int> _favoriteIds = {};

  ViewState state = ViewState.loading;
  String errorMessage = '';
  String searchQuery = '';
  bool showFavoritesOnly = false;

  List<UserModel> get users => _visibleUsers;

  bool isFavorite(int id) => _favoriteIds.contains(id);

  Future<void> loadUsers() async {
    state = ViewState.loading;
    notifyListeners();

    try {
      _allUsers = await _apiService.fetchUsers();
      _applyFilters();
    } on NoInternetException catch (e) {
      state = ViewState.error;
      errorMessage = e.message;
    } on ServerException catch (e) {
      state = ViewState.error;
      errorMessage = e.message;
    } on DataParsingException catch (e) {
      state = ViewState.error;
      errorMessage = e.message;
    } catch (e) {
      state = ViewState.error;
      errorMessage = 'Something went wrong. Please try again';
    }
    notifyListeners();
  }

  void toggleFavorite(int id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setShowFavoritesOnly(bool value) {
    showFavoritesOnly = value;
    _applyFilters();
    notifyListeners();
  }

  // Filters the already-fetched list locally — no re-calling the API.
  void _applyFilters() {
    var list = _allUsers;

    if (showFavoritesOnly) {
      list = list.where((u) => _favoriteIds.contains(u.id)).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((u) => u.name.toLowerCase().contains(q)).toList();
    }

    _visibleUsers = list;
    state = _visibleUsers.isEmpty && _allUsers.isNotEmpty
        ? ViewState.empty
        : ViewState.success;
  }
}
