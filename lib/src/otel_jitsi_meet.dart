// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_jitsi_meet_suppression.dart';

class JitsiMeetResult {
  const JitsiMeetResult({
    this.tenant,
    this.roomName,
    this.roomJid,
    this.participantId,
    this.displayName,
    this.mediaType,
    this.isModerator,
    this.participantCount,
    this.durationMs,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? tenant;
  final String? roomName;
  final String? roomJid;
  final String? participantId;
  final String? displayName;
  final String? mediaType;
  final bool? isModerator;
  final int? participantCount;
  final int? durationMs;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class JitsiMeetCallResult<T> {
  const JitsiMeetCallResult({required this.value, this.result});
  final T value;
  final JitsiMeetResult? result;
}

Future<T> tracedJitsiMeet<T>({
  required String operation,
  required Future<JitsiMeetCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (jitsiMeetInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_jitsi_meet');
  final span = t.startSpan('jitsi $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'jitsi');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.tenant != null) {
        span.setStringAttribute('jitsi.tenant', res.tenant!);
      }
      if (res.roomName != null) {
        span.setStringAttribute('jitsi.room.name', res.roomName!);
      }
      if (res.roomJid != null) {
        span.setStringAttribute('jitsi.room.jid', res.roomJid!);
      }
      if (res.participantId != null) {
        span.setStringAttribute('jitsi.participant.id', res.participantId!);
      }
      if (res.displayName != null) {
        span.setStringAttribute(
          'jitsi.participant.display_name',
          res.displayName!,
        );
      }
      if (res.mediaType != null) {
        span.setStringAttribute('jitsi.media.type', res.mediaType!);
      }
      if (res.isModerator != null) {
        span.setBoolAttribute(
          'jitsi.participant.is_moderator',
          res.isModerator!,
        );
      }
      if (res.participantCount != null) {
        span.setIntAttribute(
          'jitsi.room.participant_count',
          res.participantCount!,
        );
      }
      if (res.durationMs != null) {
        span.setIntAttribute('jitsi.duration', res.durationMs!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('jitsi.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'jitsi.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
