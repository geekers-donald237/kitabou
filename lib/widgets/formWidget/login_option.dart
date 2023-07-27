import 'package:flutter/material.dart';
import 'package:flutter_hotel_app_ui/utils/localfiles.dart';

class LoginOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BuildButton(
          iconImage: Image(
            height: 20,
            width: 20,
            image: AssetImage(Localfiles.facebook),
          ),
          textButton: 'Facebook',
        ),
        BuildButton(
          iconImage: Image(
            height: 20,
            width: 20,
            image: AssetImage(Localfiles.twitter),
          ),
          textButton: 'Twitter',
        ),
      ],
    );
  }
}

class BuildButton extends StatelessWidget {
  final Image iconImage;
  final String textButton;
  BuildButton({required this.iconImage, required this.textButton});
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Container(
      height: mediaQuery.height * 0.06,
      width: mediaQuery.width * 0.36,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconImage,
          SizedBox(
            width: 5,
          ),
          Text(textButton),
        ],
      ),
    );
  }
}
