import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../models/faq_model.dart';

class FaqItemWidget extends StatelessWidget {
  final Faq faq;

  FaqItemWidget({Key? key, required this.faq}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      decoration: Ui.getBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              this.faq.question.toString(), // Ensure this is in String format
              style: Get.textTheme.bodyMedium,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          Divider(
            height: 30,
            thickness: 1,
            color: Get.theme.dividerColor,
          ),
          Flexible(
            child: Text(
              this.faq.answer.toString(), // Ensure this is in String format
              style: Get.textTheme.bodySmall?.copyWith(fontSize: 13),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );



  }
}
