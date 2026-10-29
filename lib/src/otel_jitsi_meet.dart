// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_jitsi_meet_suppression.dart';

class JitsiMeetResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class JitsiMeetCallResult<T> {
  /// Creates a call result.
  const JitsiMeetCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final JitsiMeetResult? result;
}

Future<T> tracedJitsiMeet<T>({
  required String operation,
  required Future<JitsiMeetCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (jitsiMeetInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_jitsi_meet');
  final span = t.startSpan('jitsi $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'jitsi')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.tenant != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('jitsi.tenant', res.tenant!)]));
      }
      if (res.roomName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('jitsi.room.name', res.roomName!)]));
      }
      if (res.roomJid != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('jitsi.room.jid', res.roomJid!)]));
      }
      if (res.participantId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('jitsi.participant.id', res.participantId!)
        ]));
      }
      if (res.displayName != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'jitsi.participant.display_name',
            res.displayName!,
          )
        ]));
      }
      if (res.mediaType != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('jitsi.media.type', res.mediaType!)]));
      }
      if (res.isModerator != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeBool(
            'jitsi.participant.is_moderator',
            res.isModerator!,
          )
        ]));
      }
      if (res.participantCount != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt(
            'jitsi.room.participant_count',
            res.participantCount!,
          )
        ]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('jitsi.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('jitsi.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'jitsi.error',
          )
        ]));
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
