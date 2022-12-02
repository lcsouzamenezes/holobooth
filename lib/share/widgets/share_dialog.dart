import 'package:flutter/material.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photo_booth/photo_booth.dart';
import 'package:io_photobooth/share/widgets/facebook_button.dart';
import 'package:io_photobooth/share/widgets/share_preview_photo.dart';
import 'package:io_photobooth/share/widgets/share_social_media_clarification.dart';
import 'package:io_photobooth/share/widgets/twitter_button.dart';
import 'package:photobooth_ui/photobooth_ui.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({super.key, required this.image});

  final PhotoboothCameraImage image;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PhotoboothColors.whiteBackground,
            PhotoboothColors.white,
          ],
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 60,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SharePreviewPhoto(
                      image: image,
                    ),
                    const SizedBox(height: 60),
                    SelectableText(
                      l10n.shareDialogHeading,
                      key: const Key('shareDialog_heading'),
                      style: theme.textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SelectableText(
                      l10n.shareDialogSubheading,
                      key: const Key('shareDialog_subheading'),
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        TwitterButton(),
                        SizedBox(width: 36),
                        FacebookButton(),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const SocialMediaShareClarificationNote(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 24,
            child: IconButton(
              icon: const Icon(
                Icons.clear,
                color: PhotoboothColors.black54,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}