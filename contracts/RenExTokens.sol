pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
@title A registry of tokens that can be traded on RenEx
@author Republic Protocol
*/
contract RenExTokens is Ownable {
    using SafeMath for uint256;

    /********** ENUMS *********************************************************/
    // Once a token is registered, its address and tokens can't be changed
    // If an ERC20 token's contract is upgraded with a new address, a new token
    // code should be used
    enum TokenStatus {
        NeverRegistered,
        Registered,
        Deregistered
    }

    /********** STRUCTS *******************************************************/
    struct TokenDetails {
        address addr;
        uint8 decimals;
        TokenStatus status;
    }

    /********** STORAGE ******************************************************/
    mapping(uint32 => TokenDetails) public tokens;

    /********** EVENTS *******************************************************/
    event LogTokenRegistered(uint32 tokenCode, ERC20 tokenAddress, uint8 tokenDecimals);
    event LogTokenDeregistered(uint32 tokenCode);

    /********** EXTERNAL FUNCTIONS *******************************************/
    /// @notice Sets a token as being registered and stores its details (only-owner)
    /// @param _tokenCode a unique 32-bit token identifier
    /// @param _tokenAddress the address of the ERC20-compatible token
    /// @param _tokenDecimals the decimals to use for the token
    function registerToken(uint32 _tokenCode, ERC20 _tokenAddress, uint8 _tokenDecimals) external onlyOwner {
        TokenStatus previousStatus = tokens[_tokenCode].status;
        require(previousStatus != TokenStatus.Registered, "already registered");

        tokens[_tokenCode].status = TokenStatus.Registered;

        if (previousStatus == TokenStatus.NeverRegistered) {
            tokens[_tokenCode].addr = _tokenAddress;
            tokens[_tokenCode].decimals = _tokenDecimals;
        }

        emit LogTokenRegistered(_tokenCode, _tokenAddress, _tokenDecimals);
    }

    /// @notice Sets a token as being deregistered
    /// @param _tokenCode the unique 32-bit token identifier
    function deregisterToken(uint32 _tokenCode) external onlyOwner {
        require(tokens[_tokenCode].status == TokenStatus.Registered, "not registered");

        tokens[_tokenCode].status = TokenStatus.Deregistered;

        emit LogTokenDeregistered(_tokenCode);
    }
}