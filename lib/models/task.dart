// lib/models/task.dart

class Task {
  final String id;
  final String question;
  final String answer;
  final String? imageUrl;
  final String topic;
  final int difficulty;

  Task({
    required this.id,
    required this.question,
    required this.answer,
    this.imageUrl,
    required this.topic,
    this.difficulty = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'imageUrl': imageUrl,
    'topic': topic,
    'difficulty': difficulty,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    question: json['question'],
    answer: json['answer'],
    imageUrl: json['imageUrl'],
    topic: json['topic'],
    difficulty: json['difficulty'],
  );
}
