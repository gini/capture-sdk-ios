//
//  ImageMetaInformationManagerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
import ImageIO

final class ImageMetaInformationManagerTests: XCTestCase {
    
    var invoiceData: Data {
        return GiniCaptureTestsHelper.fileData(named: "invoice", fileExtension: "jpg")!
    }
    var manager: ImageMetaInformationManager {
        return ImageMetaInformationManager(imageData: invoiceData, imageSource: .camera)
    }
    
    func testInitialization() {
        XCTAssertNotNil(manager.imageData, "image should not be nil")
        XCTAssertNotNil(manager.metaInformation, "meta information should not be nil")
    }
    
    func testGettingMetaInformation() {
        guard let information = manager.metaInformation else {
            return XCTFail("meta information should not be nil")
        }
        guard let exif = information[kCGImagePropertyExifDictionary as String] as? NSDictionary else {
            return XCTFail("exif information should not be nil")
        }
        let exposureTime = exif[kCGImagePropertyExifExposureTime as String]
        XCTAssert(exposureTime as? Double == 1/33, "exposure time should be set and equal to \"1/33\"")
    }
    
    func testSettingMetaInformation() {
        guard let mutableInformation = manager.metaInformation?.mutableCopy() as? NSMutableDictionary else {
            return XCTFail("failed to retrieve mutable meta information from test data")
        }
        let value = "MyCompany"
        let key = kCGImagePropertyTIFFMake as String
        mutableInformation.set(metaInformation: value as AnyObject?, forKey: key)
        XCTAssert(mutableInformation.getMetaInformation(forKey: key) as? String == value,
                  "failed to set value correctly on meta information")
    }
    
    func testFilteringAndSettingRequiredFields() {
        let mutableManager = manager
        guard let filteredData = mutableManager.imageByAddingMetadata() else {
            return XCTFail("filtered image data should not be nil")
        }
        
        let filteredManager = ImageMetaInformationManager(imageData: filteredData, imageSource: .camera)
        XCTAssertNotNil(filteredManager.imageData, "image should not be nil")
        XCTAssertNotNil(filteredManager.metaInformation, "meta information should not be nil")
        guard let mutableInformation = filteredManager.metaInformation?.mutableCopy() as? NSMutableDictionary else {
            return XCTFail("failed to retrieve mutable meta information from filtered image data")
        }
        let key = kCGImagePropertyExifUserComment as String
        XCTAssert((mutableInformation.getMetaInformation(forKey: key) as? String)?.contains("GiniCaptureVer") == true,
                  "filtered data did not set custom fields")
    }
    
    func testReadFieldEntryPointFromMetaInformation() {
        let metaManager = ImageMetaInformationManager(imageData: GiniCaptureTestsHelper.fileData(named: "testFieldEntryPoint", fileExtension: "jpg")!, imageSource: .camera)
        let metaInformation = metaManager.metaInformation as? NSMutableDictionary
        let value = "field"
        let existingUserComment = metaInformation?.getMetaInformation(forKey: kCGImagePropertyExifUserComment as String)
        let components = existingUserComment?.components(separatedBy: ",")
        let userCommentComponent = components?.filter({ (component) -> Bool in
            return component.contains("EntryPoint")
        })
        let equasionComponents = userCommentComponent?.last?.components(separatedBy: "=")
        let entryPoint = equasionComponents?.last
        XCTAssert(entryPoint == value,
                  "failed to read value for entry point correctly from meta information")
    }
    
    func testReadButtonEntryPointFromMetaInformation() {
        let config = GiniConfiguration.shared
        config.entryPoint = .button
        let metaManager = ImageMetaInformationManager(imageData: GiniCaptureTestsHelper.fileData(named: "invoice", fileExtension: "jpg")!, imageSource: .camera)
        let metaInformation = metaManager.metaInformation as? NSMutableDictionary
        let value = "button"
        let existingUserComment = metaInformation?.getMetaInformation(forKey: kCGImagePropertyExifUserComment as String)
        let components = existingUserComment?.components(separatedBy: ",")
        let userCommentComponent = components?.filter({ (component) -> Bool in
            return component.contains("EntryPoint")
        })
        let equasionComponents = userCommentComponent?.last?.components(separatedBy: "=")
        let entryPoint = equasionComponents?.last
        XCTAssert(entryPoint == value,
                  "failed to read value for entry point correctly from meta information")
    }
    
    func testAddFieldEntryPointToMetaInformation() {
        let config = GiniConfiguration.shared
        config.entryPoint = .field
        _ = manager.imageByAddingMetadata()
        let metaInformation = manager.metaInformation as? NSMutableDictionary
        let value = "field"
        let existingUserComment = metaInformation?.getMetaInformation(forKey: kCGImagePropertyExifUserComment as String)
        let components = existingUserComment?.components(separatedBy: ",")
        let userCommentComponent = components?.filter({ (component) -> Bool in
            return component.contains("EntryPoint")
        })
        let equasionComponents = userCommentComponent?.last?.components(separatedBy: "=")
        let entryPoint = equasionComponents?.last
        XCTAssert(entryPoint == value,
                  "failed to add value for entry point correctly on meta information")
    }
    
    func testAddButtonEntryPointToMetaInformation() {
        _ = manager.imageByAddingMetadata()
        let metaInformation = manager.metaInformation as? NSMutableDictionary
        let value = "button"
        let existingUserComment = metaInformation?.getMetaInformation(forKey: kCGImagePropertyExifUserComment as String)
        let components = existingUserComment?.components(separatedBy: ",")
        let userCommentComponent = components?.filter({ (component) -> Bool in
            return component.contains("EntryPoint")
        })
        let equasionComponents = userCommentComponent?.last?.components(separatedBy: "=")
        let entryPoint = equasionComponents?.last
        XCTAssert(entryPoint == value,
                  "failed to set value for entry point correctly on meta information")
    }
}
