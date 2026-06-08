import 'package:flutter/material.dart';

import 'package:kultux/config/app_colors.dart';
import 'package:kultux/config/app_text_styles.dart';
import 'package:kultux/core/models/legal.dart';
import 'package:kultux/data/repository/legal_repository.dart';

class LegalDialog extends StatelessWidget {
  final bool isPrivacy;

  const LegalDialog({super.key, required this.isPrivacy});

  static Future<void> show(BuildContext context, {required bool isPrivacy}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => LegalDialog(isPrivacy: isPrivacy),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: .min,
        children: [
          Container(
       //     width: 360,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Row(children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.black,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isPrivacy ? 'Política de privacidad' : 'Términos y Condiciones',
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],),

                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.black),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints()
                )
              ],
            ),
          ),
          Flexible(
            child: FutureBuilder<List<Legal>>(
              future: LegalRepository.loadLegal(isPrivacy),
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return const Center(
                    child: CircularProgressIndicator()
                  );
                }
                final sections = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:16
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: sections.map((section) {
                      return Column(
                        crossAxisAlignment: .start,
                        children: [
                          if(section.title.isNotEmpty)
                            _TextSection(
                              text: section.title,
                              isTitle: true
                            ),
                          _TextSection(
                            text:section.text,
                            isTitle:false,
                            isFooter: section.isFooter
                          )
                        ],
                      );
                    }).toList(),
                  )
                );

              }
            )
          )
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  final String text;
  final bool isTitle;
  final bool isFooter;

  const _TextSection({super.key, required this.text, required this.isTitle, this.isFooter = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: isFooter
          ? AppTextStyles.legalDialogFooter
          : isTitle
            ? AppTextStyles.legalDialogTitle
            : AppTextStyles.legalDialogText,
    );
  }
}
