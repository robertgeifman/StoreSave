//
//  ProDisplayXDRView.swift
//  Pro Display XDR ScreenSaver
//
//  Created by OrigamiDream on 29/06/2019.
//  Copyright © 2019 Avis Studio. All rights reserved.
//

import Cocoa
import ScreenSaver
import AVKit
import AVFoundation
import MediaPlayer

class ProDisplayXDRView: ScreenSaverView {
	let controller = AVPlayerView()
	var player: AVPlayer!
	var playerLayer: AVPlayerLayer!
	var items: [AVPlayerItem] = []

	override class func performGammaFade() -> Bool { true }

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	override init?(frame: NSRect, isPreview: Bool) {
		super.init(frame: frame, isPreview: isPreview)

		let bundle = Bundle(for: type(of: self))
		items = ["Demo loop 2017", "Demo loop 2018", "Demo loop 2019"].compactMap {
			bundle.url(forResource: $0, withExtension: "mp4").map { AVPlayerItem(url: $0) }
		}

		NotificationCenter.default.addObserver(self, selector: #selector(removePlayer(_:)),
			name: NSWorkspace.willSleepNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(removePlayer(_:)),
			name: NSWorkspace.willPowerOffNotification, object: nil)
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		guard !items.isEmpty else {
			return NSAttributedString(string: "No videos", attributes: [
				.foregroundColor: NSColor.white,
			]).draw(at: NSPoint(x: 100, y: 100))
		}
	}

	override func stopAnimation() {
		super.stopAnimation()

		if let player { player.pause() }
		if let playerLayer { playerLayer.removeFromSuperlayer() }
		playerLayer = nil
		player = nil
	}
	override func startAnimation() {
		super.startAnimation()
		if player == nil {
			player = AVPlayer(playerItem: items.randomElement()!)
			player.preventsDisplaySleepDuringVideoPlayback = true
			playerLayer = AVPlayerLayer(player: player)
			playerLayer.videoGravity = .resize
			playerLayer.frame = bounds
			self.layer?.addSublayer(playerLayer)

			NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)),
				name: .AVPlayerItemDidPlayToEndTime, object: nil)
		}
		
		player.play()
	}

	@objc
	func removePlayer(_ notification: Notification) {
		if let player { player.pause() }
		if let playerLayer { playerLayer.removeFromSuperlayer() }
		playerLayer = nil
		player = nil
	}
	@objc
	func playerItemDidPlayToEndTime(_ notification: Notification) {
//		if items.count > 1 {
//			var item = items.randomElement()!
//			while player.currentItem == item {
//				item = items.randomElement()!
//			}
//			player.replaceCurrentItem(with: item)
//		}
		player.seek(to: CMTime.zero)
		player.play()
	}
}
