// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { OFTFeeAdapter } from "./OFTFeeAdapter.sol";

contract SPKOFTAdapter is OFTFeeAdapter {
    constructor(address _token, address _lzEndpoint, address _owner) OFTFeeAdapter(_token, _lzEndpoint, _owner) {}
}