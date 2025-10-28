import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  @JsonKey(name: 'roles')
  final List<String>? roles;
  @JsonKey(name: 'permissions')
  final List<String>? permissions;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.roles,
    this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    if (permissions == null) return false;
    return permissions!.contains(permission);
  }

  /// Check if user has any of the given permissions
  bool hasAnyPermission(List<String> requiredPermissions) {
    if (permissions == null) return false;
    return requiredPermissions.any((p) => permissions!.contains(p));
  }
}
