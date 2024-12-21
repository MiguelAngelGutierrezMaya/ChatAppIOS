//
//  Ext_CustomInputView.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 20/12/24.
//

import Foundation

extension CustomInputView {
    @objc func handleCancelButton() {
        resetView()
        recorder.stopRecording()
        stopTimer()
    }
    
    @objc func handleSendRecordButton() {
        recorder.stopRecording()
        
        /// TODO: - take the record and send it to the server
        let name = recorder.getRecordings.last ?? ""
        guard let audioURL = recorder.getAudioURL(name: name) else { return }
        self.delegate?.inputViewForAudio(self, audioURL: audioURL)
        
        resetView()
    }
    
    func resetView() {
        recordStackView.isHidden = true
        stackView.isHidden = false
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateTime),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        duration = 0.0
        self.timerLabel.text = duration.timeStringFormatter
    }
    
    @objc func updateTime() {
        if recorder.isRecording && !recorder.isPlaying {
            duration += 1
            self.timerLabel.text = duration.timeStringFormatter
        } else {
            stopTimer()
        }
    }
}
