import '../network/json_helpers.dart';

class ActionResult {
  const ActionResult({
    required this.message,
    this.success = true,
    this.threadId = 0,
  });

  final String message;
  final bool success;
  final int threadId;

  factory ActionResult.fromJson(
    Map<String, dynamic> json, {
    String fallbackMessage = 'Action completed.',
  }) {
    return ActionResult(
      message: stringValue(json['message'], fallback: fallbackMessage),
      success: boolValue(json['success'], fallback: true),
      threadId: intValue(json['thread_id']),
    );
  }
}
