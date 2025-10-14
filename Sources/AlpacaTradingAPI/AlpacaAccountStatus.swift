//
//  AlpacaAccountStatus.swift
//  TradeBot
//
//  Created by Peijun Zhao on 10/1/25.
//


/// Represents the status of an Alpaca trading account.
public enum AlpacaAccountStatus: String, Codable, Hashable, Sendable {
    /// The account is onboarding.
    case ONBOARDING
    
    /// The account application submission failed for some reason.
    case SUBMISSION_FAILED
    
    /// The account application has been submitted for review.
    case SUBMITTED
    
    /// The account information is being updated.
    case ACCOUNT_UPDATED
    
    /// The final account approval is pending.
    case APPROVAL_PENDING
    
    /// The account is active for trading.
    case ACTIVE
    
    /// The account application has been rejected.
    case REJECTED
}
