// mde_flutter - A cross platform viewer for the mods.de forum.
// Copyright (C) 2019  Sebastian Uhl
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Codec for latin-9 (ISO-8859-15)
//
// - latin-9 is a one byte decoding
// - Flutter internally uses UTF-16 for its Strings
// - for character values between 0 and 255, UTF-16 corresponds to latin-1
// - 8 characters are different between latin-1 and latin-9

import 'dart:convert';
import 'dart:typed_data';

const Latin9Codec latin9 = Latin9Codec();

class Latin9Codec extends Encoding {
  const Latin9Codec();

  @override
  String get name => 'iso-8859-15';

  @override
  Latin9Encoder get encoder => const Latin9Encoder();

  @override
  Latin9Decoder get decoder => const Latin9Decoder();
}

class Latin9Encoder extends Converter<String, List<int>> {
  const Latin9Encoder();

  @override
  Uint8List convert(String input) {
    List<int> runes = input.runes.toList();
    Uint8List result = Uint8List(runes.length);
    for (int i = 0; i < runes.length; i++) {
      int rune = runes[i];
      if (rune == 0x20ac) {
        rune = 0xa4;
      } else if (rune == 0x160) {
        rune = 0xa6;
      } else if (rune == 0x161) {
        rune = 0xa8;
      } else if (rune == 0x17d) {
        rune = 0xb4;
      } else if (rune == 0x17e) {
        rune = 0xb8;
      } else if (rune == 0x152) {
        rune = 0xbc;
      } else if (rune == 0x153) {
        rune = 0xbd;
      } else if (rune == 0x178) {
        rune = 0xbe;
      } else if (rune < 0 ||
          rune == 0xa4 ||
          rune == 0xa6 ||
          rune == 0xa8 ||
          rune == 0xb4 ||
          rune == 0xb8 ||
          rune == 0xbc ||
          rune == 0xbd ||
          rune == 0xbe ||
          rune > 255) {
        throw ArgumentError.value(
            input, "string", "Contains invalid characters.");
      }
      result[i] = rune;
    }
    return result;
  }
}

class Latin9Decoder extends Converter<List<int>, String> {
  const Latin9Decoder();

  @override
  String convert(List<int> input) {
    for (int i = 0; i < input.length; i++) {
      int codeUnit = input[i];
      if (codeUnit < 0 || codeUnit > 255) {
        throw FormatException("Invalid value in input: $codeUnit");
      } else if (codeUnit == 0xa4) {
        codeUnit = 0x20ac;
      } else if (codeUnit == 0xa6) {
        codeUnit = 0x160;
      } else if (codeUnit == 0xa8) {
        codeUnit = 0x161;
      } else if (codeUnit == 0xb4) {
        codeUnit = 0x17d;
      } else if (codeUnit == 0xb8) {
        codeUnit = 0x17e;
      } else if (codeUnit == 0xbc) {
        codeUnit = 0x152;
      } else if (codeUnit == 0xbd) {
        codeUnit = 0x153;
      } else if (codeUnit == 0xbe) {
        codeUnit = 0x178;
      }
      input[i] = codeUnit;
    }
    return String.fromCharCodes(input);
  }

  @override
  _Latin9DecoderSink startChunkedConversion(Sink<String> sink) =>
      _Latin9DecoderSink(sink);
}

class _Latin9DecoderSink extends Sink<List<int>> {
  Sink<String> _sink;
  _Latin9DecoderSink(this._sink);

  @override
  void add(List<int> input) {
    _sink.add(Latin9Decoder().convert(input));
  }

  @override
  void close() {
    _sink.close();
    _sink = null;
  }
}
