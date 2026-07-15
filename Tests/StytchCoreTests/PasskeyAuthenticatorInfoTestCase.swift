import Foundation
import XCTest
@testable import StytchCore

/// Builds synthetic WebAuthn attestation objects for exercising `PasskeyAuthenticatorInfo` parsing.
enum AttestationObjectFixture {
    /// iCloud Keychain's published AAGUID, fbfc3007-154e-4ecc-8c0b-6e020557d7bd.
    static let iCloudKeychainAAGUIDBytes: [UInt8] = [
        0xFB, 0xFC, 0x30, 0x07, 0x15, 0x4E, 0x4E, 0xCC,
        0x8C, 0x0B, 0x6E, 0x02, 0x05, 0x57, 0xD7, 0xBD,
    ]

    static let iCloudKeychainAAGUID = UUID(uuidString: "FBFC3007-154E-4ECC-8C0B-6E020557D7BD")!

    /// UP | UV | BE | BS | AT
    static let syncedPasskeyFlags: UInt8 = 0b0101_1101

    static func authenticatorData(flags: UInt8, aaguid: [UInt8]? = nil) -> Data {
        var bytes = [UInt8](repeating: 0, count: 32) // rpIdHash
        bytes.append(flags)
        bytes.append(contentsOf: [0, 0, 0, 0]) // signCount
        if let aaguid {
            bytes.append(contentsOf: aaguid)
            bytes.append(contentsOf: [0x00, 0x02]) // credentialId length
            bytes.append(contentsOf: [0xAB, 0xCD]) // credentialId
        }
        return Data(bytes)
    }

    static func attestationObject(authenticatorData: Data, authDataFirst: Bool = false) -> Data {
        var fmtPair: [UInt8] = [0x63] // text(3)
        fmtPair.append(contentsOf: Array("fmt".utf8))
        fmtPair.append(0x64) // text(4)
        fmtPair.append(contentsOf: Array("none".utf8))

        var attStmtPair: [UInt8] = [0x67] // text(7)
        attStmtPair.append(contentsOf: Array("attStmt".utf8))
        attStmtPair.append(0xA0) // map(0)

        var authDataPair: [UInt8] = [0x68] // text(8)
        authDataPair.append(contentsOf: Array("authData".utf8))
        authDataPair.append(contentsOf: [0x58, UInt8(authenticatorData.count)]) // bytes(one-byte length)
        authDataPair.append(contentsOf: [UInt8](authenticatorData))

        var bytes: [UInt8] = [0xA3] // map(3)
        if authDataFirst {
            bytes += authDataPair + fmtPair + attStmtPair
        } else {
            bytes += fmtPair + attStmtPair + authDataPair
        }
        return Data(bytes)
    }

    static func attestationObject(flags: UInt8, aaguid: [UInt8]? = nil) -> Data {
        attestationObject(authenticatorData: authenticatorData(flags: flags, aaguid: aaguid))
    }
}

final class PasskeyAuthenticatorInfoTestCase: XCTestCase {
    func testParsesAAGUIDAndBackupFlags() throws {
        let info = try XCTUnwrap(
            PasskeyAuthenticatorInfo(
                attestationObject: AttestationObjectFixture.attestationObject(
                    flags: AttestationObjectFixture.syncedPasskeyFlags,
                    aaguid: AttestationObjectFixture.iCloudKeychainAAGUIDBytes
                )
            )
        )
        XCTAssertEqual(info.aaguid, AttestationObjectFixture.iCloudKeychainAAGUID)
        XCTAssertTrue(info.isBackupEligible)
        XCTAssertTrue(info.isBackedUp)
    }

    func testZeroAAGUIDParsesAsNil() throws {
        // UP | UV | AT, with an all-zero AAGUID
        let info = try XCTUnwrap(
            PasskeyAuthenticatorInfo(
                attestationObject: AttestationObjectFixture.attestationObject(
                    flags: 0b0100_0101,
                    aaguid: [UInt8](repeating: 0, count: 16)
                )
            )
        )
        XCTAssertNil(info.aaguid)
        XCTAssertFalse(info.isBackupEligible)
        XCTAssertFalse(info.isBackedUp)
    }

    func testBackupFlagsParseWithoutAttestedCredentialData() throws {
        // UP | BE | BS, without the AT flag — no attested credential data follows
        let info = try XCTUnwrap(
            PasskeyAuthenticatorInfo(
                attestationObject: AttestationObjectFixture.attestationObject(flags: 0b0001_1001)
            )
        )
        XCTAssertNil(info.aaguid)
        XCTAssertTrue(info.isBackupEligible)
        XCTAssertTrue(info.isBackedUp)
    }

    func testMapKeyOrderDoesNotMatter() throws {
        let attestationObject = AttestationObjectFixture.attestationObject(
            authenticatorData: AttestationObjectFixture.authenticatorData(
                flags: AttestationObjectFixture.syncedPasskeyFlags,
                aaguid: AttestationObjectFixture.iCloudKeychainAAGUIDBytes
            ),
            authDataFirst: true
        )
        let info = try XCTUnwrap(PasskeyAuthenticatorInfo(attestationObject: attestationObject))
        XCTAssertEqual(info.aaguid, AttestationObjectFixture.iCloudKeychainAAGUID)
    }

    func testMalformedAttestationObjectReturnsNil() {
        XCTAssertNil(PasskeyAuthenticatorInfo(attestationObject: Data()))
        XCTAssertNil(PasskeyAuthenticatorInfo(attestationObject: Data("fake_attestation_data".utf8)))

        // A top-level array rather than a map
        XCTAssertNil(PasskeyAuthenticatorInfo(attestationObject: Data([0x81, 0x00])))

        // A valid attestation object with its tail truncated
        let valid = AttestationObjectFixture.attestationObject(
            flags: AttestationObjectFixture.syncedPasskeyFlags,
            aaguid: AttestationObjectFixture.iCloudKeychainAAGUIDBytes
        )
        XCTAssertNil(PasskeyAuthenticatorInfo(attestationObject: valid.dropLast(10)))
    }

    func testTruncatedAuthenticatorDataReturnsNil() {
        let attestationObject = AttestationObjectFixture.attestationObject(
            authenticatorData: Data([UInt8](repeating: 0, count: 10))
        )
        XCTAssertNil(PasskeyAuthenticatorInfo(attestationObject: attestationObject))
    }
}
