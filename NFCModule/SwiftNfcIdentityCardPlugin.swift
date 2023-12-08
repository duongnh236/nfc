import UIKit
import Foundation
import CoreNFC

@available(iOS 14, *)
public class SwiftNfcIdentityCardPlugin: NSObject {

  public  func scanPassport(_ idNumber: String, dateOfBirth: String, dateOfExpiry: String, result: @escaping ([String: Any]) -> Void ) {

          let passportReader = PassportReader()
          let df = DateFormatter()
          df.timeZone = TimeZone(secondsFromGMT: 0)
          df.dateFormat = "YYMMdd"

          let pptNr = idNumber
          let dob = dateOfBirth
          let doe = dateOfExpiry

          let passportUtils = PassportUtils()
          let mrzKey = passportUtils.getMRZKey( passportNumber: pptNr, dateOfBirth: dob, dateOfExpiry: doe)

              Task {
                  let customMessageHandler : (NFCViewDisplayMessage) -> String? = { (displayMessage) in
                      switch displayMessage {
                      case .requestPresentPassport:
                          return "Quý khách vui lòng giữ yên vị trí thẻ CCCD và điện thoại."
                      default:
                          // Return nil for all other messages so we use the provided default
                          return nil
                      }
                  }

                  do {
                      let passport = try await passportReader.readPassport( mrzKey: mrzKey, customDisplayMessage:customMessageHandler)
                      let errors = passport.verificationErrors.map{($0.localizedDescription)}.joined(separator: "-")
                      DispatchQueue.main.async {

                          var _result: [String: Any] = ["status": "0" ,"state":"","errorMessage": errors ,"message":"success", "code":"200","data": [
                              "idNumber": passport.identityNumber ?? "",
                              "fullName": passport.userName ?? "",
                              "dateOfBirth": passport.birthDay ?? "",
                              "gender": passport.sex ?? "",
                              "nationality": passport.nationality ,
                              "ethnic": passport.ethnic ?? "",
                              "religion": passport.religion ?? "",
                              "placeOfOrigin": passport.homeTown ?? "",
                              "placeOfResidence": passport.address ?? "",
                              "dateOfExpiry": passport.endDay ?? "",
                              "personalIdentification": passport.identifyingCharacteristics ,
                              "dateOfIssuance": passport.startDay ?? "",
                              "parentName": "\(String(describing: passport.fatherName ?? "") ), \(String(describing: passport.motherName ?? "") )",
                              "spouseName": passport.wifeName ?? "",
                              "oldIdNumber": passport.oldIdentityCard ?? "",
                              "chipId": passport.chipID ,
                              "image": self.convertImageToBase64String(img: passport.passportImage!),
                              "sodFile": self.convertBytesToBase64String(passport.rawDataSOD),
                              "comFile": self.convertBytesToBase64String(passport.rawDataCOM),
                              "DG1": self.convertBytesToBase64String(passport.rawDataDG1),
                              "DG14": self.convertBytesToBase64String(passport.rawDataDG14),
                              "DG15": self.convertBytesToBase64String(passport.rawDataDG15),
                              "DG13": self.convertBytesToBase64String(passport.rawDataDG13),
                              "DG2Raw": self.convertBytesToBase64String(passport.rawDataDG2),
                              "activeAuthenticationPassed": passport.activeAuthenticationPassed ? "1" : "0",
                              "isVerify": passport.documentSigningCertificateVerified && passport.passportDataNotTampered ? "1" : "0"

                          ]]
                          guard var _data = _result["data"] as? [String : Any] else { return }
                          _data.updateValue(passport.sodGroupIds, forKey: "sodGroupIds")
                          _result["data"] = _data
                          result(_result)
                      }
                  } catch let er as NFCPassportReaderError {
                      DispatchQueue.main.async {
                          let _result: [String: Any] = ["status": "0" ,"state":"", "errorMessage": er.value, "message":"failed", "code":"500","data": ""]
                          result(_result)
                      }
                  } catch let error {
                      let errorMessage = error.localizedDescription
                      DispatchQueue.main.async {
                          let _result: [String: Any] = ["status": "0" ,"state":"", "errorMessage": errorMessage, "message":"failed", "code":"500","data": ""]
                          result(_result)
                      }
                  }
              }
      }
    public  func convertImageToBase64String (img: UIImage) -> String {
          return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }

   public func checkAvailableNFC() -> Bool {
            if NFCNDEFReaderSession.readingAvailable {
                return true
            } else {
                return false
            }
        }
     public func checkiOSVersion() -> Bool {
            if #available(iOS 14.0, *) {
               return true
            } else {
               return false
            }
        }
    public func convertBytesToBase64String(_ bytes: [UInt8]) -> String {
        let data = NSData(bytes: bytes, length: bytes.count)
        let base64String = data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        return base64String
    }
}
