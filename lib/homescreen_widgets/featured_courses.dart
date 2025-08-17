import 'package:flutter/material.dart';
import 'package:elearn/providers/course_provider.dart';

import '../screens/course_detail_screen.dart';

class FeaturedCourses extends StatelessWidget {
  const FeaturedCourses({
    super.key,
    required this.courseProvider,
  });

  final CourseProvider courseProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(   // <-- return here
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courseProvider.courses.length > 5
          ? 5
          : courseProvider.courses.length,
      itemBuilder: (ctx, i) {
        final course = courseProvider.courses[i];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => CourseDetailScreen(course: course),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            child: Row(
              children: [
                if (course.courseImage?.url != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: Image.network(
                      course.courseImage!.url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) =>
                      const Icon(Icons.error, size: 50),
                    ),
                  )
                else
                  const SizedBox(
                    width: 100,
                    height: 100,
                    child: Icon(Icons.book, size: 50),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${course.level} • ${course.duration} min",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\K${course.price?.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
