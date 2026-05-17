# otel_jitsi_meet

Dartastic OpenTelemetry bridge for Jitsi Meet (open-source video conferencing).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_jitsi_meet/otel_jitsi_meet.dart';

await tracedJitsiMeet<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return JitsiMeetCallResult(value: r, result: JitsiMeetResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutJitsiMeetInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
