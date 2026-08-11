class AppConstants {
  // Precompilato con BCrypt (cost 12): BCrypt.hashpw('user', BCrypt.gensalt(logRounds: 12))
  static const String hashedAdminPassword =
      r'$2a$12$q2XCzgJQ9EuUp08Z0K/rGuVoz2vnb0xcd6BrXap/WtK8YgUJ0EzO6';
  static const String adminUsername = 'user';
}
