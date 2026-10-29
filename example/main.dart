// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_jitsi_meet/otel_jitsi_meet.dart';

/// Traces Jitsi Meet calls with OpenTelemetry.
///
/// `otel_jitsi_meet` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Jitsi Meet call in
/// [tracedJitsiMeet]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'jitsi-meet-example');

  // Traces a Jitsi Meet call.
  final jitsiMeetId = await tracedJitsiMeet<String>(
    operation: 'create',
    invoke: () async {
      // Make the Jitsi Meet call here, then report what it returned.
      const id = 'jitsi_meet_8f3a2c';
      return const JitsiMeetCallResult(
          value: id,
          result: JitsiMeetResult(
              tenant: 'example',
              roomName: 'example',
              roomJid: 'roomj_8f3a2c',
              participantId: 'participant_8f3a2c',
              displayName: 'example',
              mediaType: 'standard',
              isModerator: true,
              participantCount: 3,
              durationMs: 120,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedJitsiMeet create returned $jitsiMeetId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutJitsiMeetInstrumentationAsync.
  await runWithoutJitsiMeetInstrumentationAsync(
    () => tracedJitsiMeet<String>(
      operation: 'create',
      invoke: () async {
        const id = 'jitsi_meet_8f3a2c';
        return const JitsiMeetCallResult(
            value: id,
            result: JitsiMeetResult(
                tenant: 'example',
                roomName: 'example',
                roomJid: 'roomj_8f3a2c',
                participantId: 'participant_8f3a2c',
                displayName: 'example',
                mediaType: 'standard',
                isModerator: true,
                participantCount: 3,
                durationMs: 120,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
