//
//  DataGroup13.swift
//  NFCPassportReader
//
//  Created by DuongNguyen on 07/09/2022.
//

import Foundation
@available(iOS 13, macOS 10.15, *)
public class DataGroup13 : DataGroup {
    
    public private(set) var identityNumber : String?
    public private(set) var userName : String?
    public private(set) var birthDay : String?
    public private(set) var sex : String?
    public private(set) var nationality : String?
    public private(set) var ethnic: String?
    public private(set) var religion: String?
    public private(set) var homeTown: String?
    public private(set) var address: String?
    public private(set) var identifyingCharacteristics: String?
    public private(set) var startDay: String?
    public private(set) var endDay: String?
    public private(set) var fatherName: String?
    public private(set) var motherName: String?
    public private(set) var wifeName: String?
    public private(set) var oldIdentityCard: String?
    public private(set) var chipID: String?
    public private(set) var rawData: [UInt8]?
    
    required init( _ data : [UInt8] ) throws {
        try super.init(data)
        datagroupType = .DG13
    }
    
    func findSameGroup() {
        
    }
    override func parse(_ data: [UInt8]) throws {
        arrayBytes.removeAll()
        self.rawData = data

        let twTLV = try TWTLV.init(data: data)
        let value = twTLV.printableTlv()
        var tlvData: [String] = value.1
        
        let _index: Int = tlvData.firstIndex(of: "0D") ?? 0
        tlvData.insert("0D", at: _index + 2)
        
        tlvData.enumerated().forEach { (index, value) in
           
            switch (value) {
            case "0101":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                self.identityNumber = String(data: d!, encoding: .utf8)
                break
            case "02":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                self.userName = String(data: d!, encoding: .utf8)
                break
            case "03":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                self.birthDay  = String(data: d!, encoding: .utf8)
                break
            case "04":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                 self.sex = String(data: d!, encoding: .utf8)
                break
            case "05":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                 self.nationality = String(data: d!, encoding: .utf8)
                break
            case "06":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                 self.ethnic = String(data: d!, encoding: .utf8)
                break
            case "07":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                 self.religion = String(data: d!, encoding: .utf8)
                break
            case "08":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                 self.homeTown = String(data: d!, encoding: .utf8)
                break
            case "09":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                 self.address = String(data: d!, encoding: .utf8)
                break
            case "0A":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                self.identifyingCharacteristics = String(data: d!, encoding: .utf8)
                break
            case "0B":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                self.startDay = String(data: d!, encoding: .utf8)
                break
            case "0C":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                self.endDay = String(data: d!, encoding: .utf8)
                break
            case "0D":
                if (self.fatherName == nil) {
                    let _value = tlvData[index + 1]
                    let d = Data(fromHexEncodedString: _value)
                    self.fatherName = String(data: d!, encoding: .utf8)
                } else {
                    let _value = tlvData[index + 1]
                    let d = Data(fromHexEncodedString: _value)
                    self.motherName = String(data: d!, encoding: .utf8)
                }
                
                break
            case "0E":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                self.wifeName = String(data: d!, encoding: .utf8)
                break
            case "0F":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                self.oldIdentityCard = String(data: d!, encoding: .utf8)
                break
            case "10":
                let _value = tlvData[index + 1]
                let d = Data(fromHexEncodedString: _value)
                self.chipID = String(data: d!, encoding: .utf8)
                break
            default:
                break
            }
        }
        
    }


}

extension String {
    
    func hexToString()->String{
        
        var finalString = ""
        let chars = Array(self)
        
        for count in stride(from: 0, to: chars.count - 1, by: 2){
            let firstDigit =  Int.init("\(chars[count])", radix: 16) ?? 0
            let lastDigit = Int.init("\(chars[count + 1])", radix: 16) ?? 0
            let decimal = firstDigit * 16 + lastDigit
            let decimalString = String(format: "%c", decimal) as String
            finalString.append(Character.init(decimalString))
        }
        return finalString
        
    }
}
extension Data {

    // From http://stackoverflow.com/a/40278391:
    init?(fromHexEncodedString string: String) {

        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }

        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }
}
