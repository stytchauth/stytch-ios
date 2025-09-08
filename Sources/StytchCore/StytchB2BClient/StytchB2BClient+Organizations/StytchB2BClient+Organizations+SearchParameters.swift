import Foundation
@preconcurrency import SwiftyJSON

public extension StytchB2BClient.Organizations {
    struct SearchParameters: Codable, Sendable {
        let query: SearchQuery?
        let cursor: String?
        let limit: Int?

        /// * Data class used for wrapping the parameters necessary to search members
        /// - Parameters:
        ///   - query: The optional query object contains the operator, i.e.
        ///   AND or OR, and the operands that will filter your results. Only an operator is required.
        ///   If you include no operands, no filtering will be applied.
        ///   If you include no query object, it will return all Members with no filtering applied.
        ///   - cursor: The cursor field allows you to paginate through your results.
        ///   Each result array is limited to 1000 results. If your query returns more than 1000 results,
        ///   you will need to paginate the responses using the cursor. If you receive a response that includes a non-null
        ///   next_cursor in the results_metadata object, repeat the search call with the next_cursor value
        ///   set to the cursor field to retrieve the next page of results.
        ///   Continue to make search calls until the next_cursor in the response is null.
        ///   - limit: The number of search results to return per page.
        ///   The default limit is 100. A maximum of 1000 results can be returned by a single search request.
        ///   If the total size of your result set is greater than one page size, you must paginate the response. See the cursor field.
        public init(
            query: SearchQuery? = nil,
            cursor: String? = nil,
            limit: Int? = nil
        ) {
            self.query = query
            self.cursor = cursor
            self.limit = limit
        }
    }
}

public extension StytchB2BClient.Organizations.SearchParameters {
    struct SearchQuery: Codable, Sendable {
        private enum CodingKeys: String, CodingKey {
            case searchOperator = "operator"
            case searchOperandsJSON = "operands"
        }

        let searchOperator: SearchOperator
        let searchOperandsJSON: JSON

        /// - Parameters:
        ///   - searchOperator: An instance of SearchQueryOperand 'OR' or 'AND'
        ///   - searchOperands: An array of SearchQueryOperand(s) created via 'SearchParameters.searchQueryOperand(...)'
        public init(searchOperator: SearchOperator, searchOperands: [any SearchQueryOperand]) {
            self.searchOperator = searchOperator
            let searchOperandsJSONArray = searchOperands.map(\.json)
            searchOperandsJSON = JSON(searchOperandsJSONArray)
        }
    }
}

public extension StytchB2BClient.Organizations.SearchParameters {
    enum SearchOperator: String, Codable, Sendable {
        // swiftlint:disable:next identifier_name
        case OR
        case AND
    }
}

/// A generic protocol to define operand types generating the JSON needed for a search query.
public protocol SearchQueryOperand: Sendable {
    var filterName: String { get }
    var filterValueJSON: JSON { get }
}

extension SearchQueryOperand {
    var json: JSON {
        ["filter_name": JSON(stringLiteral: filterName), "filter_value": filterValueJSON]
    }
}

public extension StytchB2BClient.Organizations.SearchParameters {
    struct SearchQueryOperandStringArray: SearchQueryOperand {
        public let filterName: String
        let filterValue: [String]

        public var filterValueJSON: JSON {
            let filterValues = filterValue.map { JSON(stringLiteral: $0) }
            return JSON(filterValues)
        }

        init(filterName: String, filterValue: [String]) {
            self.filterName = filterName
            self.filterValue = filterValue
        }
    }

    struct SearchQueryOperandString: SearchQueryOperand {
        public let filterName: String
        let filterValue: String

        public var filterValueJSON: JSON {
            JSON(stringLiteral: filterValue)
        }

        init(filterName: String, filterValue: String) {
            self.filterName = filterName
            self.filterValue = filterValue
        }
    }

    struct SearchQueryOperandBool: SearchQueryOperand {
        public let filterName: String
        let filterValue: Bool

        public var filterValueJSON: JSON {
            JSON(booleanLiteral: filterValue)
        }

        init(filterName: String, filterValue: Bool) {
            self.filterName = filterName
            self.filterValue = filterValue
        }
    }
}

public extension StytchB2BClient.Organizations.SearchParameters {
    /// An enum to define all the possible filter names that can be used for a serach query.
    /// Each one maps to a concrete implementation of a SearchQueryOperand.
    enum SearchQueryOperandFilterNames: String {
        case memberIds = "member_ids"
        case memberEmails = "member_emails"
        case memberEmailFuzzy = "member_email_fuzzy"
        case memberIsBreakglass = "member_is_breakglass"
        case statuses
        case memberMfaPhoneNumbers = "member_mfa_phone_numbers"
        case memberMfaPhoneNumberFuzzy = "member_mfa_phone_number_fuzzy"
        case memberPasswordExists = "member_password_exists"
        case memberRoles = "member_roles"

        var isSearchQueryOperandStringArray: Bool {
            self == .memberIds || self == .memberEmails || self == .statuses || self == .memberMfaPhoneNumbers || self == .memberRoles
        }

        var isSearchQueryOperandString: Bool {
            self == .memberEmailFuzzy || self == .memberMfaPhoneNumberFuzzy
        }

        var isSearchQueryOperandBool: Bool {
            self == .memberIsBreakglass || self == .memberPasswordExists
        }
    }
}

public extension StytchB2BClient.Organizations.SearchParameters {
    /// A factory to generate the correct search query operand type for the corresponding filter name.
    /// If a mismatched search query operand type and filter name is passed in it will return a nil value.
    /// - Parameters:
    ///   - filterName: An instance of SearchQueryOperandFilterNames
    ///   - filterValue: A value of one of three types, [String], String or Bool.
    /// - Returns: A concrete implementation of a SearchQueryOperand or nil.
    static func searchQueryOperand(filterName: SearchQueryOperandFilterNames, filterValue: Any) -> SearchQueryOperand? {
        if let filterValue = filterValue as? [String], filterName.isSearchQueryOperandStringArray == true {
            return SearchQueryOperandStringArray(filterName: filterName.rawValue, filterValue: filterValue)
        } else if let filterValue = filterValue as? String, filterName.isSearchQueryOperandString == true {
            return SearchQueryOperandString(filterName: filterName.rawValue, filterValue: filterValue)
        } else if let filterValue = filterValue as? Bool, filterName.isSearchQueryOperandBool == true {
            return SearchQueryOperandBool(filterName: filterName.rawValue, filterValue: filterValue)
        } else {
            return nil
        }
    }
}
