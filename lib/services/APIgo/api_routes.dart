class ApiRoutes {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String ProtectedUrl = '$baseUrl/protected';

  // Auth
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/inscription';

  // Utilisateur
  static const String getCurrentUser = '$ProtectedUrl/getUser';
  static const String getAllUsers = '$ProtectedUrl/getUsers';
  static const String updateGenres = '$ProtectedUrl/updateGenres';
  static const String updateUser = '$ProtectedUrl/updateUser';
  static const String updatePassword = '$ProtectedUrl/updatePassword';
  static const String deleteUser = '$ProtectedUrl/deleteUser';

  // Likes / Dislikes / Vu
  static const String addLike = '$ProtectedUrl/addLike';
  static const String addDislike = '$ProtectedUrl/addDislike';
  static const String deleteLike = '$ProtectedUrl/deleteLike';
  static const String deleteDislike = '$ProtectedUrl/deleteDislike';
  static const String addSeenMovie = '$ProtectedUrl/addSeenMovie';
  static const String deleteSeenMovie = '$ProtectedUrl/deleteSeenMovie';

  // Amis
  static const String addFriendRequest = '$ProtectedUrl/addFriendRequest';
  static const String friendRequestResponse = '$ProtectedUrl/friendRequestResponse';
  static const String getFriendRequests = '$ProtectedUrl/getFriendRequests';
  static const String getFriends = '$ProtectedUrl/getfriends';
  static const String deleteFriend = '$ProtectedUrl/deleteFriend';

  // Recommandations
  static const String getRecommandation = '$ProtectedUrl/getRecommandation';
  static const String getRecommandationFriends = '$ProtectedUrl/getRecommandationFriends';

  // Contribution
  static const String addContribution = '$ProtectedUrl/addContribution';
  static const String getContributorContributions = '$ProtectedUrl/getContributorContributions';

  // Admin
  static const String updateUserRights = '$ProtectedUrl/updateUserRights';
  static const String getContributions = '$ProtectedUrl/contributions';
  static const String checkContribution = '$ProtectedUrl/checkContribution';
  static const String deleteUserByEmail = '$ProtectedUrl/deleteUserByEmail';
  static const String deleteContent = '$ProtectedUrl/deleteMovieByID';


}