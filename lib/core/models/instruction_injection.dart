enum InstructionInjectionRole { user, assistant, system }

extension InstructionInjectionRoleJson on InstructionInjectionRole {
  static InstructionInjectionRole fromJson(dynamic value) {
    final v = (value ?? '').toString().trim().toUpperCase();
    switch (v) {
      case 'USER':
        return InstructionInjectionRole.user;
      case 'ASSISTANT':
        return InstructionInjectionRole.assistant;
      case 'SYSTEM':
      default:
        return InstructionInjectionRole.system;
    }
  }

  String toJson() {
    return switch (this) {
      InstructionInjectionRole.user => 'USER',
      InstructionInjectionRole.assistant => 'ASSISTANT',
      InstructionInjectionRole.system => 'SYSTEM',
    };
  }
}

class InstructionInjection {
  final String id;
  final String title;
  final String prompt;
  final String group;
  final InstructionInjectionRole role;

  const InstructionInjection({
    required this.id,
    required this.title,
    required this.prompt,
    this.group = '',
    this.role = InstructionInjectionRole.system,
  });

  InstructionInjection copyWith({
    String? id,
    String? title,
    String? prompt,
    String? group,
    InstructionInjectionRole? role,
  }) {
    return InstructionInjection(
      id: id ?? this.id,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      group: group ?? this.group,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'prompt': prompt,
    'group': group,
    'role': role.toJson(),
  };

  static InstructionInjection fromJson(Map<String, dynamic> json) =>
      InstructionInjection(
        id: (json['id'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        prompt: (json['prompt'] as String?) ?? '',
        group: (json['group'] as String?) ?? '',
        role: InstructionInjectionRoleJson.fromJson(json['role']),
      );
}
