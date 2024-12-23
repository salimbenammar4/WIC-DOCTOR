import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/doctor_model.dart';
import '../../../models/review_model.dart';
import '../../../services/auth_service.dart';
import '../controllers/review_controller.dart';

class ReviewPopupWidget extends StatefulWidget {
  final Doctor doctor;  // Add clinic as a parameter
  final VoidCallback onReviewAdded;
  // Modify the constructor to accept the clinic
  ReviewPopupWidget({required this.doctor, required this.onReviewAdded});

  @override
  _ReviewPopupWidgetState createState() => _ReviewPopupWidgetState();
}

class _ReviewPopupWidgetState extends State<ReviewPopupWidget> {
  double _rating = 0;
  TextEditingController _reviewController = TextEditingController();  // Controller for the review text field

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ajoutez votre avis',
              style: Get.textTheme.titleMedium,
            ),
            SizedBox(height: 20),
            // Star Rating Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _rating >= index + 1 ? Icons.star : Icons.star_border,
                    color: Color(0xFFFFB24D),
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0; // Set the rating
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            // TextField for the review
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Get.theme.inputDecorationTheme.fillColor,
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Create a Review object and call addClinicReview
                    final review = Review(
                      user: Get.find<AuthService>().user.value,
                      rate: _rating,
                      review: _reviewController.text,
                      doctor: widget.doctor,  // Pass the clinic from the widget
                    );

                    final reviewcontroller = Get.find<ReviewsController>();  // Get the ReviewsController
                    reviewcontroller.addDoctorReview(review);
                    widget.onReviewAdded();
                    Get.back(); // Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.primary, // Apply the same primary color style
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.send, // Icon for submit button
                        color: Colors.white,
                      ),
                      SizedBox(width: 8), // Space between icon and text
                      Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Close the popup
                    Get.back();
                  },
                  child: Text('Annuler'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
