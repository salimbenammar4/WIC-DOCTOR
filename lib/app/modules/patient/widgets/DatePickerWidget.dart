import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatelessWidget {
  final RxString selectedDate = "".obs;
  final RxString ages = "".obs;
  final String labelText;
  final IconData iconData;
  final String hintText;
  final Function(String) onDateSelected;
  final String initialValue; // Add initialValue to the widget

  DatePickerWidget({
    required this.labelText,
    required this.iconData,
    required this.hintText,
    required this.onDateSelected,
    required this.initialValue, // Accept initialValue
  });

  @override
  Widget build(BuildContext context) {
    // Set initial value if it is not empty
    if (initialValue.isNotEmpty) {
      selectedDate.value = initialValue;
      final DateTime initialDate = DateFormat('yyyy-MM-dd').parse(initialValue);

      // Calculate age based on the initial date
      final today = DateTime.now();
      int age = today.year - initialDate.year;
      if (initialDate.month > today.month ||
          (initialDate.month == today.month && initialDate.day > today.day)) {
        age--;
      }
      ages.value = "Age: $age";
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 350, // same width as in DropDownList
          child: GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900), // Earliest date
                lastDate: DateTime.now(), // Latest date
              );
              if (pickedDate != null) {
                // Calculate age
                final today = DateTime.now();
                int age = today.year - pickedDate.year;
                if (pickedDate.month > today.month ||
                    (pickedDate.month == today.month &&
                        pickedDate.day > today.day)) {
                  age--;
                }
                ages.value = "Age: $age";
                selectedDate.value = DateFormat('yyyy-MM-dd').format(pickedDate);
                onDateSelected(selectedDate.value);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: labelText.tr,
                hintText: hintText.tr,
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.merge(
                  const TextStyle(color: Colors.grey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(iconData, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      return Text(
                        ages.value.isEmpty
                            ? hintText.tr
                            : ages.value,
                        style: Theme.of(context).textTheme.bodyMedium?.merge(
                          const TextStyle(color: Colors.black),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
