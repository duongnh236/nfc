//
//  NFCViewDisplayMessage.swift
//  NFCPassportReader
//
//  Created by Andy Qua on 09/02/2021.
//

import Foundation

@available(iOS 13, macOS 10.15, *)
public enum NFCViewDisplayMessage {
    case requestPresentPassport
    case authenticatingWithPassport(Int)
    case readingDataGroupProgress(DataGroupId, Int)
    case error(NFCPassportReaderError)
    case successfulRead
}

@available(iOS 13, macOS 10.15, *)
extension NFCViewDisplayMessage {
    public var description: String {
        switch self {
            case .requestPresentPassport:
                return "Quý khách vui lòng giữ yên vị trí thẻ CCCD và điện thoại"
            case .authenticatingWithPassport(let progress):
                let progressString = handleProgress(percentualProgress: progress)
                return "Đang xác thực.....\n\n\(progressString)"
            case .readingDataGroupProgress(let dataGroup, let progress):
                let progressString = handleProgress(percentualProgress: progress)
                return "Đang đọc \(dataGroup).....\n\n\(progressString)"
            case .error(let tagError):
                switch tagError {
                    case NFCPassportReaderError.TagNotValid:
                        return "Lỗi đọc thông tin từ CCCD."
                    case NFCPassportReaderError.TimeOut:
                        return "Quá thời gian quét CCCD. Vui lòng thử lại."
                    case NFCPassportReaderError.MoreThanOneTagFound:
                        return "Lỗi đọc thông tin từ CCCD."
                    case NFCPassportReaderError.ConnectionError:
                        return "Mất kết nối. Vui lòng thử lại."
                    case NFCPassportReaderError.InvalidMRZKey:
                        return "Lỗi xác thực."
                    case NFCPassportReaderError.ResponseError(let description, let sw1, let sw2):
                        return "Lỗi hệ thống. \(description) - (0x\(sw1), 0x\(sw2)"
                    default:
                        return "Sorry, there was a problem reading the passport. Please try again"
                }
            case .successfulRead:
                return "Đọc thành công"
        }
    }
    
    func handleProgress(percentualProgress: Int) -> String {
        let p = (percentualProgress/20)
        let full = String(repeating: "🟢 ", count: p)
        let empty = String(repeating: "⚪️ ", count: 5-p)
        return "\(full)\(empty)"
    }
}
