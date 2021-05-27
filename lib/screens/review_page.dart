import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobile/models/review.dart';
import 'package:mobile/services/course_service.dart';
import 'dart:ui' as ui;

import 'package:smooth_star_rating/smooth_star_rating.dart';

class ReviewPage extends StatefulWidget {
  ReviewPage(this.courseId);
  final int courseId;
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _pageSize = 8;
  CourseData courseData = CourseData();
  int pageCounter = 0;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      pageCounter++;
      final newItems = (await courseData.getCourseReviews(
          widget.courseId, pageCounter, _pageSize))[1];
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  final PagingController<int, Review> _pagingController = PagingController(firstPageKey: 0);
  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Review>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Review>(
          itemBuilder: (context, item, index) => reviewListItem(
            review: item,
          ),
        ),
      );
  }
}

Widget reviewListItem({Review review}) {
  return Card(
    color: Colors.white10,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userFirstName != null ?
                review.userFirstName :
                'کاربر نرم افزار',
                style: TextStyle(fontSize: 16),
              ),
              // Text(
              //   courseReviewList[index].date.toLocal().toString(),
              //   style: TextStyle(fontSize: 16),
              // ),
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: SmoothStarRating(
                  size: 15,
                  allowHalfRating: false,
                  isReadOnly: true,
                  rating: double.parse(review.rating.toString()),
                  color: Colors.yellow,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            review.text,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.justify,
          ),
        )
      ],
    ),
  );
}
