# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedJitsiMeet<T>(...)` — wraps a otel_jitsi_meet call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutJitsiMeetInstrumentation()` / `Async()`.
