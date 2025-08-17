import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../lesson_widgets/hybrid_video_player.dart';
import '../models/course_model.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Course Image
            if (course.courseImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  course.courseImage!.url,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            // Title & meta
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${course.level ?? "N/A"} • ${course.duration} hrs • ${course.language ?? "Unknown"}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              course.price != null
                  ? "K${course.price!.toStringAsFixed(2)}"
                  : "Free",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              course.description ?? "No description available.",
              style: const TextStyle(fontSize: 16),
            ),

            const Divider(height: 32),

            // Instructors
            if (course.instructors.isNotEmpty) ...[
              const Text(
                "Instructor(s)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...course.instructors.map((inst) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(inst.name),
                subtitle: Text(
                  inst.bio ?? "No bio available",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              const Divider(height: 32),
            ],

            // Lessons with YouTube video preview
            if (course.lessons.isNotEmpty) ...[
              const Text(
                "Lessons",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...course.lessons.map((lesson) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    title: Text(lesson.title),
                    subtitle: Text("${lesson.duration} min"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(lesson.content ?? ""),
                      ),
                      if (lesson.videoUrl != null) ...[
                        const SizedBox(height: 12),
                        if (lesson.videoUrl != null)
                          HybridYouTubePlayer(videoUrl: lesson.videoUrl!),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
