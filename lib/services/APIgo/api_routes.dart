class ApiRoutes {
  static const String baseUrl = 'http://localhost:3000/api';

  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/inscription';
  static const String getCurrentUser = '$baseUrl/protected/getUser';
  static const String getAllUsers = '$baseUrl/protected/getUsers';
  static const String updateGenres = '$baseUrl/protected/updateGenres';
  static const String updateUser = '$baseUrl/protected/updateUser';
  static const String updatePassword = '$baseUrl/protected/updatePassword';
  static const String deleteUser = '$baseUrl/protected/deleteUser';
  static const String addLike = '$baseUrl/protected/addLike';
  static const String addDislike = '$baseUrl/protected/addDislike';
}
