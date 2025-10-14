//
//  AlpacaAccount.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//


import Foundation

/// Alpaca Trading API "Get Account" response.
/// Numeric amounts are strings in the API response.
/// See: https://paper-api.alpaca.markets/v2/account
public struct AlpacaAccount: Codable, Hashable, Sendable, Identifiable {
    // MARK: - Identity & Status

    /// Account ID.
    public let id: String

    /// Account number.
    public let account_number: String

    /// See detailed account statuses below.
    public let status: AlpacaAccountStatus

    /// The current status of the crypto enablement. See detailed crypto statuses below.
    public let crypto_status: String

    /// "USD"
    public let currency: String

    // MARK: - Cash & Equity

    /// Cash balance.
    public let cash: String

    /// Total value of cash + holding positions (Equivalent to the equity field).
    public let portfolio_value: String

    /// Current available non-margin dollar buying power.
    public let non_marginable_buying_power: String

    /// The fees collected.
    public let accrued_fees: String

    /// Cash pending transfer in.
    public let pending_transfer_in: String?

    /// Cash pending transfer out.
    public let pending_transfer_out: String?

    // MARK: - Flags

    /// Whether or not the account has been flagged as a pattern day trader.
    public let pattern_day_trader: Bool

    /// User setting. If `true`, the account is not allowed to place orders.
    public let trade_suspended_by_user: Bool

    /// If `true`, the account is not allowed to place orders.
    public let trading_blocked: Bool

    /// If `true`, the account is not allowed to request money transfers.
    public let transfers_blocked: Bool

    /// If `true`, the account activity by user is prohibited.
    public let account_blocked: Bool

    // MARK: - Timestamps & Permissions

    /// Timestamp this account was created at.
    public let created_at: String

    /// Flag to denote whether or not the account is permitted to short.
    public let shorting_enabled: Bool

    // MARK: - Market Values

    /// Real-time MtM value of all long positions held in the account.
    public let long_market_value: String

    /// Real-time MtM value of all short positions held in the account.
    public let short_market_value: String

    /// `cash` + `long_market_value` + `short_market_value`.
    public let equity: String

    /// Equity as of previous trading day at 16:00:00 ET.
    public let last_equity: String

    // MARK: - Margin & Buying Power

    /// Buying power (BP) multiplier that represents account margin classification.
    /// Valid values: 1 (standard limited margin 1x), 2 (Reg T 2x intraday & overnight), 4 (PDT 4x intraday, 2x overnight).
    public let multiplier: String

    /// Current available $ buying power.
    /// If multiplier = 4, this is your daytrade buying power = (last equity - (last) maintenance_margin) * 4;
    /// If multiplier = 2, buying power = max(equity – initial_margin, 0) * 2;
    /// If multiplier = 1, buying_power = cash.
    public let buying_power: String

    /// Reg T initial margin requirement (continuously updated value).
    public let initial_margin: String

    /// Maintenance margin requirement (continuously updated value).
    public let maintenance_margin: String

    /// Value of special memorandum account (will be used at a later date to provide additional buying_power).
    public let sma: String

    /// The current number of daytrades that have been made in the last 5 trading days (inclusive of today).
    public let daytrade_count: Int

    /// Your maintenance margin requirement on the previous trading day.
    public let last_maintenance_margin: String

    /// Your buying power for day trades (continuously updated value).
    public let daytrading_buying_power: String

    /// Your buying power under Regulation T (your excess equity times your margin multiplier).
    public let regt_buying_power: String
}
