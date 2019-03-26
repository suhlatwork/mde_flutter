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

// Codec for mods.de XML API
//
// - the XML API is supposed to return data encoded in UTF-8
// - it almost does, but the lowest byte is latin-9, not latin-1
// - this means 8 characters from latin-1 are not reachable directly, and 8
//   characters from latin-9 need to be recovered

import 'dart:convert';

import 'latin9.dart';

final Encoding mdeCodec = _MDECodec();

final Converter<List<int>, String> mdeXmlDecoder = utf8.decoder
    .fuse(_MDEDecoderLatin9Recovery())
    .fuse(_MDEDecoderUnicodeRecovery());

class _MDECodec extends Encoding {
  @override
  String get name => latin9.name;

  @override
  Converter<List<int>, String> get decoder =>
      latin9.decoder.fuse(_MDEDecoderUnicodeRecovery());

  @override
  Converter<String, List<int>> get encoder =>
      _MDEEncoderUnicodeRecovery().fuse(latin9.encoder);
}

class _MDEDecoderLatin9Recovery extends Converter<String, String> {
  @override
  String convert(String input) {
    List<int> runes = input.runes.toList();
    List<int> result = List<int>(runes.length);
    for (int i = 0; i < runes.length; i++) {
      int rune = runes[i];
      if (rune == 0xa4) {
        rune = 0x20ac;
      } else if (rune == 0xa6) {
        rune = 0x160;
      } else if (rune == 0xa8) {
        rune = 0x161;
      } else if (rune == 0xb4) {
        rune = 0x17d;
      } else if (rune == 0xb8) {
        rune = 0x17e;
      } else if (rune == 0xbc) {
        rune = 0x152;
      } else if (rune == 0xbd) {
        rune = 0x153;
      } else if (rune == 0xbe) {
        rune = 0x178;
      }
      result[i] = rune;
    }
    return String.fromCharCodes(result);
  }

  @override
  _MDEDecoderLatin9RecoverySink startChunkedConversion(Sink<String> sink) =>
      _MDEDecoderLatin9RecoverySink(sink);
}

class _MDEDecoderLatin9RecoverySink extends Sink<String> {
  Sink<String> _sink;
  _MDEDecoderLatin9RecoverySink(this._sink);

  @override
  void add(String input) {
    _sink.add(_MDEDecoderLatin9Recovery().convert(input));
  }

  @override
  void close() {
    _sink.close();
    _sink = null;
  }
}

class _MDEDecoderUnicodeRecovery extends Converter<String, String> {
  @override
  String convert(String input) {
    return input.replaceAllMapped(RegExp(r'&#\d+;'), (match) {
      return String.fromCharCode(
          int.parse(input.substring(match.start + 2, match.end - 1)));
    }).replaceAllMapped(RegExp(r'&#x[0-9a-f]+;'), (match) {
      return String.fromCharCode(int.parse(
          input.substring(match.start + 3, match.end - 1),
          radix: 16));
    });
  }

  @override
  _MDEDecoderUnicodeRecoverySink startChunkedConversion(Sink<String> sink) =>
      _MDEDecoderUnicodeRecoverySink(sink);
}

class _MDEDecoderUnicodeRecoverySink extends Sink<String> {
  Sink<String> _sink;
  _MDEDecoderUnicodeRecoverySink(this._sink);

  @override
  void add(String input) {
    _sink.add(_MDEDecoderUnicodeRecovery().convert(input));
  }

  @override
  void close() {
    _sink.close();
    _sink = null;
  }
}

class _MDEEncoderUnicodeRecovery extends Converter<String, String> {
  @override
  String convert(String input) {
    List<int> runes = input.runes.toList();
    List<int> result = List<int>();
    for (int i = 0; i < runes.length; i++) {
      int rune = runes[i];
      if (rune != 0x20ac &&
          rune != 0x160 &&
          rune != 0x161 &&
          rune != 0x17d &&
          rune != 0x17e &&
          rune != 0x152 &&
          rune != 0x153 &&
          rune != 0x178 &&
          (rune < 0 ||
              rune == 0xa4 ||
              rune == 0xa6 ||
              rune == 0xa8 ||
              rune == 0xb4 ||
              rune == 0xb8 ||
              rune == 0xbc ||
              rune == 0xbd ||
              rune == 0xbe ||
              rune > 255)) {
        result.addAll('&#x${rune.toRadixString(16)};'.codeUnits);
      } else {
        result.add(rune);
      }
    }
    return String.fromCharCodes(result);
  }

  @override
  _MDEEncoderUnicodeRecoverySink startChunkedConversion(Sink<String> sink) =>
      _MDEEncoderUnicodeRecoverySink(sink);
}

class _MDEEncoderUnicodeRecoverySink extends Sink<String> {
  Sink<String> _sink;
  _MDEEncoderUnicodeRecoverySink(this._sink);

  @override
  void add(String input) {
    _sink.add(_MDEEncoderUnicodeRecovery().convert(input));
  }

  @override
  void close() {
    _sink.close();
    _sink = null;
  }
}
