/*! @file ABLLink.h
 *  @copyright 2016, Ableton AG, Berlin. All rights reserved.
 *
 *  @brief Cross-device shared tempo and quantized beat grid API for iOS
 *
 *  @discussion Provides zero configuration peer discovery on a local
 *  wired or wifi network between multiple instances running on
 *  multiple devices. When peers are connected in a link session, they
 *  share a common tempo and quantized beat grid.
 *
 *  Each instance of the library has its own beat timeline that starts
 *  when the library is initialized and runs until the library
 *  instance is destroyed. Clients can reset the beat timeline in
 *  order to align it with an app's beat position when starting
 *  playback.
 *
 *  The library provides one timeline capture/commit function pair for
 *  use in the audio thread and one for the main application
 *  thread. In general, modifying the Link timeline should be done in
 *  the audio thread for the most accurate timing results. The ability
 *  to modify the Link timeline from application threads should only
 *  be used in cases where an application's audio thread is not
 *  actively running or if it doesn't generate audio at all. Modifying
 *  the Link timeline from both the audio thread and an application
 *  thread concurrently is not advised and will potentially lead to
 *  unexpected behavior.
 */

#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif
  /*! @brief Reference to an instance of the library. */
  typedef struct ABLLink* ABLLinkRef;

  /*! @brief Initialize the library, providing an initial tempo.
   */
  ABLLinkRef ABLLinkNew(double initialBpm);

  /*! @brief Destroy the library instance and cleanup its associated
   *  resources.
   */
  void ABLLinkDelete(ABLLinkRef);

  /*! @brief Set whether Link should be active or not.
   *
   *  @discussion When Link is active, it advertises itself on the
   *  local network and initiates connections with other peers. It
   *  is active by default after init.
   */
  void ABLLinkSetActive(ABLLinkRef, bool active);

  /*! @brief Is Link currently enabled by the user?
   *
   *  @discussion The enabled status is only controllable by the user
   *  via the Link settings dialog and is not controllable
   *  programmatically.
   */
  bool ABLLinkIsEnabled(ABLLinkRef);

  /*! @brief Is Link currently connected to other peers? */
  bool ABLLinkIsConnected(ABLLinkRef);

  /*! @brief Called if Session Tempo changes.
   *
   *  @param the new session tempo in bpm
   *
   *  @discussion This is a stable value that is appropriate for display
   *  to the user.
   */
  typedef void (*ABLLinkSessionTempoCallback)(
    double sessionTempo,
    void *context);

  /*! @brief Called if isEnabled state changes.
   *
   *  @param isEnabled Whether Link is currently enabled
   */
  typedef void (*ABLLinkIsEnabledCallback)(
    bool isEnabled,
    void *context);

  /*! @brief Called if isConnected state changes.
   *
   *  @param isConnected Whether Link is currently connected to other
   *  peers.
   */
  typedef void (*ABLLinkIsConnectedCallback)(
    bool isConnected,
    void *context);

  /*! @brief Invoked on the main thread when the tempo of the Link
   *  session changes.
   */
  void ABLLinkSetSessionTempoCallback(
    ABLLinkRef,
    ABLLinkSessionTempoCallback callback,
    void* context);

  /*! @brief Invoked on the main thread when the user changes the
   *  enabled state of the library via the Link settings view.
   */
  void ABLLinkSetIsEnabledCallback(
    ABLLinkRef,
    ABLLinkIsEnabledCallback callback,
    void* context);

  /*! @brief Invoked on the main thread when the isConnected state
   *  of the library changes.
   */
  void ABLLinkSetIsConnectedCallback(
    ABLLinkRef,
    ABLLinkIsConnectedCallback callback,
    void* context);

  /*! @brief A reference to a representation of a mapping between time
   *  and beats for varying quanta.
   */
  typedef struct ABLLinkTimeline* ABLLinkTimelineRef;

  /*! @brief Capture the current Link timeline from the audio thread.
   *
   *  @discussion This function is lockfree and should ONLY be called
   *  in the audio thread. It must not be accessed from any other
   *  threads. The returned reference refers to a snapshot of the
   *  current Link state, so it should be captured and used in a local
   *  scope. Storing the Timeline for later use in a different context
   *  is not advised because it will provide an outdated view on the
   *  Link state.
   */
  ABLLinkTimelineRef ABLLinkCaptureAudioTimeline(ABLLinkRef);

  /*! @brief Commit the given timeline to the Link session from the
   *  audio thread.
   *
   *  @discussion This function is lockfree and should ONLY be called
   *  in the audio thread. The given timeline will replace the current
   *  Link timeline. Modifications to the session based on the new
   *  timeline will be communicated to other peers in the session.
   */
  void ABLLinkCommitAudioTimeline(ABLLinkRef, ABLLinkTimelineRef);

  /*! @brief Capture the current Link timeline from the main
   *  application thread.
   *
   *  @discussion This function provides the ability to query the Link
   *  timeline from the main application thread and should only be
   *  used from that thread. The returned Timeline stores a snapshot
   *  of the current Link state, so it should be captured and used in
   *  a local scope. Storing the Timeline for later use in a different
   *  context is not advised because it will provide an outdated view
   *  on the Link state.
   */
  ABLLinkTimelineRef ABLLinkCaptureAppTimeline(ABLLinkRef);

  /*! @brief Commit the timeline to the Link session from the main
   *  application thread.
   *
   *  @discussion This function should ONLY be called in the main
   *  thread. The given timeline will replace the current Link
   *  timeline. Modifications to the session based on the new timeline
   *  will be communicated to other peers in the session.
   */
  void ABLLinkCommitAppTimeline(ABLLinkRef, ABLLinkTimelineRef);


  /*! @section ABLLinkTimeline functions
   *
   *  The following functions all query or modify aspects of a
   *  captured timeline. Modifications made to a timeline will never
   *  be seen by other peers in a session until they are committed
   *  using the appropriate function above.
   *
   *  Time value parameters for the following functions are specified
   *  as hostTimeAtOutput. Host time refers to the system time unit
   *  used by the mHostTime member of AudioTimeStamp and the
   *  mach_absolute_time function. hostTimeAtOutput refers to the host
   *  time at which a sound reaches the audio output of a device. In
   *  order to determine the host time at the device output, the
   *  AVAudioSession.outputLatency property must be taken into
   *  consideration along with any additional buffering latency
   *  introduced by the software.
   */

  /*! @brief The tempo of the given timeline, in Beats Per Minute.
   *
   *  @discussion This is a stable value that is appropriate for display
   *  to the user. Beat time progress will not necessarily match this tempo
   *  exactly because of clock drift compensation.
   */
  double ABLLinkGetTempo(ABLLinkTimelineRef);

  /*! @brief Set the timeline tempo to the given bpm value, taking
   *  effect at the given host time.
   */
  void ABLLinkSetTempo(
    ABLLinkTimelineRef,
    double bpm,
    uint64_t hostTimeAtOutput);

  /*! @brief: Get the beat value corresponding to the given host time
   *  for the given quantum.
   *
   *  @discussion: The magnitude of the resulting beat value is
   *  unique to this Link instance, but its phase with respect to
   *  the provided quantum is shared among all session
   *  peers. For non-negative beat values, the following
   *  property holds: fmod(ABLLinkBeatAtTime(tl, ht, q), q) ==
   *  ABLLinkPhaseAtTime(tl, ht, q).
   */
  double ABLLinkBeatAtTime(
    ABLLinkTimelineRef,
    uint64_t hostTimeAtOutput,
    double quantum);

  /*! @brief Get the host time at which the sound corresponding to the
   *  given beat time and quantum reaches the device's audio output.
   *
   *  @discussion: The inverse of ABLLinkBeatAtTime, assuming
   *  a constant tempo.
   *
   *  ABLLinkBeatAtTime(tl, ABLLinkTimeAtBeat(tl, b, q), q) == b.
   */
  uint64_t ABLLinkTimeAtBeat(
    ABLLinkTimelineRef,
    double beatTime,
    double quantum);

  /*! @brief Get the phase for a given beat time value on the shared
   *  beat grid with respect to the given quantum.
   *
   *  @discussion This function allows access to the phase
   *  of a host time as described above with respect to a quantum.
   *  The returned value will be in the range [0, quantum].
   */
  double ABLLinkPhaseAtTime(
    ABLLinkTimelineRef,
    uint64_t hostTimeAtOutput,
    double quantum);

  /*! @brief: Attempt to map the given beat time to the given host
   *  time in the context of the given quantum.
   *
   *  @discussion: This function behaves differently depending on the
   *  state of the session. If no other peers are connected,
   *  then this instance is in a session by itself and is free to
   *  re-map the beat/time relationship whenever it pleases.
   *
   *  If there are other peers in the session, this instance
   *  should not abruptly re-map the beat/time relationship in the
   *  session because that would lead to beat discontinuities among
   *  the other peers. In this case, the given beat will be mapped
   *  to the next time value greater than the given time with the
   *  same phase as the given beat.
   *
   *  This function is specifically designed to enable the concept of
   *  "quantized launch" in client applications. If there are no other
   *  peers in the session, then an event (such as starting
   *  transport) happens immediately when it is requested. If there
   *  are other peers, however, we wait until the next time at which
   *  the session phase matches the phase of the event, thereby
   *  executing the event in-phase with the other peers in the
   *  session. The client only needs to invoke this method to
   *  achieve this behavior and should not need to explicitly check
   *  the number of peers.
   */
  void ABLLinkRequestBeatAtTime(
    ABLLinkTimelineRef,
    double beatTime,
    uint64_t hostTimeAtOutput,
    double quantum);

  /*! @brief: Rudely re-map the beat/time relationship for all peers
   *  in a session.
   *
   *  @discussion: DANGER: This function should only be needed in
   *  certain special circumstances. Most applications should not
   *  use it. It is very similar to ABLLinkRequestBeatAtTime except that it
   *  does not fall back to the quantizing behavior when it is in a
   *  session with other peers. Calling this method will
   *  unconditionally map the given beat time to the given host time and
   *  broadcast the result to the session. This is very anti-social
   *  behavior and should be avoided.
   *
   *  One of the few legitimate uses of this method is to
   *  synchronize a Link session with an external clock source. By
   *  periodically forcing the beat/time mapping according to an
   *  external clock source, a peer can effectively bridge that
   *  clock into a Link session. Much care must be taken at the
   *  application layer when implementing such a feature so that
   *  users do not accidentally disrupt Link sessions that they may
   *  join.
   */
  void ABLLinkForceBeatAtTime(
    ABLLinkTimelineRef,
    double beatTime,
    uint64_t hostTimeAtOutput,
    double quantum);

#ifdef __cplusplus
}
#endif
