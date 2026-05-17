// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_jitsi_meet/otel_jitsi_meet.dart';
import 'package:test/test.dart';

void main() {
  group('otel_jitsi_meet', () {
    test('suppression toggles in zone', () async {
      expect(jitsiMeetInstrumentationSuppressed(), isFalse);
      await runWithoutJitsiMeetInstrumentationAsync(() async {
        expect(jitsiMeetInstrumentationSuppressed(), isTrue);
      });
      expect(jitsiMeetInstrumentationSuppressed(), isFalse);
    });

    test('JitsiMeetResult fields default null', () {
      const r = JitsiMeetResult();
      expect(r.statusCode, isNull);
    });
  });
}
