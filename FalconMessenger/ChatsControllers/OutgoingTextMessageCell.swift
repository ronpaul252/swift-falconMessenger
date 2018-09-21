//
//  OutgoingTextMessageCell.swift
//  Pigeon-project
//
//  Created by Roman Mizin on 8/8/17.
//  Copyright © 2017 Roman Mizin. All rights reserved.
//

import UIKit
import SafariServices


class OutgoingTextMessageCell: BaseMessageCell {
  
  let textView: FalconTextView = {
    let textView = FalconTextView()
    textView.textContainerInset = UIEdgeInsetsMake(textViewTopInset, outgoingTextViewLeftInset, textViewBottomInset, outgoingTextViewRightInset)
    textView.textColor = ThemeManager.currentTheme().outgoingBubbleTextColor

    return textView
  }()
  
  override func setupViews() {
    super.setupViews()
    textView.delegate = self
    bubbleView.addSubview(textView)
    contentView.addSubview(deliveryStatus)
    bubbleView.addSubview(timeLabel)
    timeLabel.backgroundColor = .clear
    timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
    bubbleView.tintColor = ThemeManager.currentTheme().outgoingBubbleTintColor
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    bubbleView.tintColor = ThemeManager.currentTheme().outgoingBubbleTintColor
  }
  
  func setupData(message: Message) {
    self.message = message
    guard let messageText = message.text else { return }
    textView.text = messageText
    timeLabel.text = self.message?.convertedTimestamp
    bubbleView.frame = setupBubbleViewFrame(message: message)
    textView.frame.size = CGSize(width: bubbleView.frame.width, height: bubbleView.frame.height)
    timeLabel.frame.origin = CGPoint(x: bubbleView.frame.width-timeLabel.frame.width-5, y: bubbleView.frame.height-timeLabel.frame.height-5)
    
    if let isCrooked = self.message?.isCrooked, isCrooked {
      bubbleView.image = ThemeManager.currentTheme().outgoingBubble
    } else {
      bubbleView.image = ThemeManager.currentTheme().outgoingPartialBubble
    }
  }
  
  fileprivate func setupBubbleViewFrame(message: Message) -> CGRect {
    guard let portaritEstimate = message.estimatedFrameForText?.width, let landscapeEstimate = message.landscapeEstimatedFrameForText?.width else { return CGRect() }

    let portraitX = frame.width - portaritEstimate - BaseMessageCell.outgoingMessageHorisontalInsets - BaseMessageCell.scrollIndicatorInset
    let portraitFrame = setupFrameWithLabel(portraitX, BaseMessageCell.bubbleViewMaxWidth,
                                            portaritEstimate, BaseMessageCell.outgoingMessageHorisontalInsets, frame.size.height)
    let landscapeX = frame.width - landscapeEstimate - BaseMessageCell.outgoingMessageHorisontalInsets - BaseMessageCell.scrollIndicatorInset
    let landscapeFrame = setupFrameWithLabel(landscapeX, BaseMessageCell.landscapeBubbleViewMaxWidth,
                                             landscapeEstimate, BaseMessageCell.outgoingMessageHorisontalInsets, frame.size.height)
    switch UIDevice.current.orientation {
    case .landscapeLeft, .landscapeRight:
      return landscapeFrame.integral
   default:
      return portraitFrame.integral
    }
  }
}

extension OutgoingTextMessageCell: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    guard interaction != .preview else { return false }
    guard ["http", "https"].contains(URL.scheme?.lowercased() ?? "")  else { return true }
    var svc = SFSafariViewController(url: URL as URL)
    
    if #available(iOS 11.0, *) {
      let configuration = SFSafariViewController.Configuration()
      configuration.entersReaderIfAvailable = true
      svc = SFSafariViewController(url: URL as URL, configuration: configuration)
    }
    
    svc.preferredControlTintColor = FalconPalette.defaultBlue
    svc.preferredBarTintColor = ThemeManager.currentTheme().generalBackgroundColor
    chatLogController?.inputContainerView.resignAllResponders()
    chatLogController?.present(svc, animated: true, completion: nil)
    
    return false
  }
}
