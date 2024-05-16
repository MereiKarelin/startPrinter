import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_star_printer/src/enums.dart';

/// Class to hold print commands and functions to add commands to it
class PrintCommands {
  /// list of commands to pass to the printer
  List<Map<String, dynamic>> _commands = [];

  /// get current list of commands
  List<Map<String, dynamic>> getCommands() {
    return _commands;
  }

  /// sets the encoding for text prints, [StarEncoding] available is different for each printer
  appendEncoding(StarEncoding encoding) {
    this._commands.add({"appendEncoding": encoding.text});
  }

  /// run command on printer cuter, [StarCutPaperAction] available is different for each printer
  appendCutPaper(StarCutPaperAction action) {
    this._commands.add({"appendCutPaper": action.text});
  }

  /// open cash drawer, [actionNumber] needed to based on the printer port
  openCashDrawer(int actionNumber) {
    this._commands.add({"openCashDrawer": actionNumber});
  }

  /// Prints an image with a url or a file [path].
  /// Set [bothScale] to scale the image by the [width] of receipt.
  /// Sets [absolutePosition] image absolute position.
  /// [StarAlignmentPosition] sets image alignment.
  /// [StarBitmapConverterRotation] set image rotation.
  appendBitmap({
    required String path,
    bool diffusion = true,
    int width = 576,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
  }) {
    Map<String, dynamic> command = {
      "appendBitmap": path,
    };
    command['bothScale'] = bothScale;
    command['diffusion'] = diffusion;
    command['width'] = width;

    if (absolutePosition != null)
      command['absolutePosition'] = absolutePosition;
    if (alignment != null) command['alignment'] = alignment.text;
    if (rotation != null) command['rotation'] = rotation.text;

    this._commands.add(command);
  }

  /// Prints an image with a raw data [byteData].
  /// Set [bothScale] to scale the image by the [width] of receipt.
  /// Sets [absolutePosition] image absolute position.
  /// [StarAlignmentPosition] sets image alignment.
  /// [StarBitmapConverterRotation] set image rotation.
  appendBitmapByte({
    required Uint8List byteData,
    bool diffusion = true,
    int width = 576,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
  }) {
    Map<String, dynamic> command = {
      "appendBitmapByteArray": byteData,
    };
    command['bothScale'] = bothScale;
    command['diffusion'] = diffusion;
    command['width'] = width;

    if (absolutePosition != null)
      command['absolutePosition'] = absolutePosition;
    if (alignment != null) command['alignment'] = alignment.text;
    if (rotation != null) command['rotation'] = rotation.text;

    this._commands.add(command);
  }

  /// Prints an image generated by widgets [widget].
  /// Set [bothScale] to scale the image by the [width] of receipt.
  /// Sets [absolutePosition] image absolute position.
  /// [StarAlignmentPosition] sets image alignment.
  /// [StarBitmapConverterRotation] set image rotation.
  /// Set [Duration] if you are using async widgets or widget that take time to fully build.
  /// logicalSize [Size] is the size of the device the widget is made into.
  /// imageSize [Size] is the size of image generated.
  /// sets the [TextDirection].
  appendBitmapWidget({
    required BuildContext context,
    required Widget widget,
    bool diffusion = true,
    int width = 576,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
    Duration? wait,
    Size? logicalSize,
    Size? imageSize,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    createImageFromWidget(
      context,
      widget,
      wait: wait,
      logicalSize: logicalSize,
      imageSize: imageSize,
      textDirection: textDirection,
    ).then((byte) {
      if (byte != null) {
        appendBitmapByte(
          byteData: byte,
          diffusion: diffusion,
          width: width,
          bothScale: bothScale,
          absolutePosition: absolutePosition,
          alignment: alignment,
          rotation: rotation,
        );
      } else {
        throw Exception('Error generating image');
      }
    });
  }

  /// Prints an image generated by text [text].
  /// [fontSize] sets font text size of image
  /// Set [bothScale] to scale the image by the [width] of receipt.
  /// Sets [absolutePosition] image absolute position.
  /// [StarAlignmentPosition] sets image alignment.
  /// [StarBitmapConverterRotation] set image rotation.
  appendBitmapText({
    required String text,
    int? fontSize,
    bool diffusion = true,
    int? width,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
  }) {
    Map<String, dynamic> command = {
      "appendBitmapText": text,
    };
    command['bothScale'] = bothScale;
    command['diffusion'] = diffusion;

    if (fontSize != null) command['fontSize'] = fontSize;
    if (width != null) command['width'] = width;
    if (absolutePosition != null)
      command['absolutePosition'] = absolutePosition;
    if (alignment != null) command['alignment'] = alignment.text;
    if (rotation != null) command['rotation'] = rotation.text;

    this._commands.add(command);
  }

  /// pushes a manual [command] into the command list
  push(Map<String, dynamic> command) {
    this._commands.add(command);
  }

  /// clear all commands in command list
  clear() {
    this._commands.clear();
  }

  /// Generats an image from [widget].
  /// Set [Duration] if you are using async widgets or widget that take time to fully build.
  /// logicalSize [Size] is the size of the device the widget is made into.
  /// imageSize [Size] is the size of image generated.
  /// sets the [TextDirection].
  static Future<Uint8List?> createImageFromWidget(
    BuildContext context,
    Widget widget, {
    Duration? wait,
    Size? logicalSize,
    Size? imageSize,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    logicalSize ??=
        View.of(context).physicalSize / View.of(context).devicePixelRatio;
    imageSize ??= View.of(context).physicalSize;

    assert(logicalSize.aspectRatio == imageSize.aspectRatio);

    final RenderView renderView = RenderView(
      view: WidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        // size: logicalSize,
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: textDirection,
        child: IntrinsicHeight(child: IntrinsicWidth(child: widget)),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    if (wait != null) {
      await Future.delayed(wait);
    }

    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();

    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: imageSize.width / logicalSize.width,
    );
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }
}
