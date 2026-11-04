class User {
  const User({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
      );

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email};
}

/// O que a API devolve depois do login: o token e quem entrou.
class Session {
  const Session({required this.token, required this.user});

  final String token;
  final User user;

  factory Session.fromMap(Map<String, dynamic> map) => Session(
        token: map['token'] as String,
        user: User.fromMap(map['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {'token': token, 'user': user.toMap()};
}
