import 'package:flutter/widgets.dart';

/// A [TextEditingController] extended to provide custom masks to flutter
class MaskedTextController extends TextEditingController {
  MaskedTextController({
    @required this.mask,
    String text,
    Map<String, RegExp> translator,
  })  : assert(mask != null),
        super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      updateText(this.text);
    });

    _lastUpdatedText = '';
    updateText(this.text);
  }

  /// The current applied mask
  String mask;

  /// Translator from mask characters to [RegExp]
  Map<String, RegExp> translator;

  String _lastUpdatedText;

  /// Default [RegExp] for each character available for the mask
  ///
  /// 'A' represents a letter of the alphabet
  /// '0' represents a numeric character
  /// '@' represents a alphanumeric character
  /// '*' represents any character
  static Map<String, RegExp> getDefaultTranslator() => {
        'A': RegExp(r'[A-Za-z]'),
        '0': RegExp(r'[0-9]'),
        '@': RegExp(r'[A-Za-z0-9]'),
        '*': RegExp(r'.*')
      };

  /// Corresponding to [TextEditingController.text]
  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
    }
  }

  /// Replaces [mask] with a [newMask] and moves cursor to the end if
  /// [shouldMoveCursorToEnd] is true
  void updateMask(String newMask, {bool shouldMoveCursorToEnd = true}) {
    mask = newMask;
    updateText(text);

    if (shouldMoveCursorToEnd) {
      moveCursorToEnd();
    }
  }

  /// Updates the current [text] with a new one applying the [mask]
  void updateText(String newText) {
    assert(newText != null, 'Text must not be null');
    text = (newText != null) ? _applyMask(mask, newText) : '';
    _lastUpdatedText = text;
    moveCursorToEnd();
  }

  /// Moves cursor to the end of the text
  void moveCursorToEnd() {
    // only moves the cursor if text is not selected
    if (selection.baseOffset == selection.extentOffset) {
      selection = TextSelection.fromPosition(
        TextPosition(offset: (_lastUpdatedText ?? '').length),
      );
    }
  }

  String _applyMask(String mask, String value) {
    final result = StringBuffer('');
    var maskCharIndex = 0;
    var valueCharIndex = 0;

    while (maskCharIndex != mask.length && valueCharIndex != value.length) {
      final maskChar = mask[maskCharIndex];
      final valueChar = value[valueCharIndex];

      // value equals mask, just write value to the buffer
      if (maskChar == valueChar) {
        result.write(maskChar);
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match with the current mask character
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar].hasMatch(valueChar)) {
          result.write(valueChar);
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not a masked value, fixed char on mask
      result.write(maskChar);
      maskCharIndex += 1;
    }

    return result.toString();
  }
}
