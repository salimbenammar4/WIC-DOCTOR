import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../models/speciality_model.dart';
import '../../../routes/app_routes.dart';

class SpecialityListItemWidget extends StatelessWidget {
  final Speciality speciality;
  final String? heroTag;

  SpecialityListItemWidget({Key? key, required this.speciality, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: Ui.getBoxDecoration(
          border: Border.fromBorderSide(BorderSide.none),
          gradient: LinearGradient(
              colors: [speciality.color.withOpacity(0.6), speciality.color.withOpacity(0.1)],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.topEnd,
              stops: [0.0, 0.5],
              tileMode: TileMode.clamp)),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Get.theme.colorScheme.secondary.withOpacity(0.08),
        onTap: () {
          Get.toNamed(Routes.SPECIALITY, arguments: speciality);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: 70,
              child: (speciality.image.url.toLowerCase().endsWith('.svg')
                  ? SvgPicture.network(
                speciality.image.url,
                color: speciality.color,
                height: 100,
              )
                  : CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: speciality.image.url,
                placeholder: (context, url) => Image.asset(
                  'assets/img/loading.gif',
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error_outline),
              )),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                speciality.name,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Get.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
