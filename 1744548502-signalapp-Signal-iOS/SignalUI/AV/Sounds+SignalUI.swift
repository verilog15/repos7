//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

public import SignalServiceKit

extension Sounds {

    private static func shouldAudioPlayerLoop(forSound sound: Sound) -> Bool {
        guard case .standard(let standardSound) = sound else { return false }
        switch standardSound {
        case .callConnecting, .callOutboundRinging:
            return true
        default:
            return false
        }
    }

    public static func audioPlayer(forSound sound: Sound, audioBehavior: AudioBehavior) -> AudioPlayer? {
        guard let soundUrl = sound.soundUrl(quiet: false) else {
            return nil
        }
        let player = AudioPlayer(decryptedFileUrl: soundUrl, audioBehavior: audioBehavior)
        if shouldAudioPlayerLoop(forSound: sound) {
            player.isLooping = true
        }
        return player
    }
}
