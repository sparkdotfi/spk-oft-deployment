// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IEndpointV2 {
    function getConfig(address receiver, address uln, uint32 eid, uint32 configType) external view returns (bytes memory);
}

// DevTools imports
import { TestHelperOz5 } from "@layerzerolabs/test-devtools-evm-foundry/contracts/TestHelperOz5.sol";

contract SpkBscBridgeConfigTest is TestHelperOz5 {

    struct UlnConfig {
        uint64    confirmations;
        // we store the length of required DVNs and optional DVNs instead of using DVN.length directly to save gas
        uint8     requiredDVNCount; // 0 indicate DEFAULT, NIL_DVN_COUNT indicate NONE (to override the value of default)
        uint8     optionalDVNCount; // 0 indicate DEFAULT, NIL_DVN_COUNT indicate NONE (to override the value of default)
        uint8     optionalDVNThreshold; // (0, optionalDVNCount]
        address[] requiredDVNs; // no duplicates. sorted an an ascending order. allowed overlap with optionalDVNs
        address[] optionalDVNs; // no duplicates. sorted an an ascending order. allowed overlap with requiredDVNs
    }

    address internal constant LAYERZERO_ENDPOINT_V2 = 0x1a44076050125825900e736c501f859c50fE728c; // Same address on Ethereum Mainnet and BSC.

    function test_ETH_SendConfig() external {
        vm.createSelectFork(vm.envString("ETH_MAINNET_RPC_URL"));

        IEndpointV2 endpoint = IEndpointV2(LAYERZERO_ENDPOINT_V2);

        bytes memory configBytes = endpoint.getConfig(
            0xAfF2e841851700D1Fc101995Ee6b81Ae21Bb87D7,  // OApp Address on Ethereum Mainnet
            0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1,  // Send Uln on Ethereum Mainnet
            30102,  // eid 30102 is for BSC
            2       // configType 2 is for UlnConfig
        );
        UlnConfig memory config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        15,                                         "confirmations should be 15");
        assertEq(config.requiredDVNCount,     4,                                          "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     type(uint8).max,                            "optionalDVNCount should be NIL_DVN_COUNT");
        assertEq(config.optionalDVNThreshold, 0,                                          "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  4,                                          "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                                          "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      0x380275805876Ff19055EA900CDb2B46a94ecF20D, "first DVN should be Horizen");
        assertEq(config.requiredDVNs[1],      0x589dEDbD617e0CBcB916A9223F4d1300c294236b, "second DVN should be LayerZero Labs");
        assertEq(config.requiredDVNs[2],      0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd, "third DVN should be Canary");
        assertEq(config.requiredDVNs[3],      0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5, "fourth DVN should be Nethermind");
    }

    function test_ETH_ReceiveConfig() external {
        vm.createSelectFork(vm.envString("ETH_MAINNET_RPC_URL"));

        IEndpointV2 endpoint = IEndpointV2(LAYERZERO_ENDPOINT_V2);

        bytes memory configBytes = endpoint.getConfig(
            0xAfF2e841851700D1Fc101995Ee6b81Ae21Bb87D7,  // OApp Address on Ethereum Mainnet
            0xc02Ab410f0734EFa3F14628780e6e695156024C2,  // Receive Uln on Ethereum Mainnet
            30102,  // eid 30102 is for BSC
            2       // configType 2 is for UlnConfig
        );
        UlnConfig memory config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        20,                                         "confirmations should be 20");
        assertEq(config.requiredDVNCount,     4,                                          "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     type(uint8).max,                            "optionalDVNCount should be NIL_DVN_COUNT");
        assertEq(config.optionalDVNThreshold, 0,                                          "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  4,                                          "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                                          "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      0x380275805876Ff19055EA900CDb2B46a94ecF20D, "first DVN should be Horizen");
        assertEq(config.requiredDVNs[1],      0x589dEDbD617e0CBcB916A9223F4d1300c294236b, "second DVN should be LayerZero Labs");
        assertEq(config.requiredDVNs[2],      0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd, "third DVN should be Canary");
        assertEq(config.requiredDVNs[3],      0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5, "fourth DVN should be Nethermind");
    }

    function test_BSC_SendConfig() external {
        vm.createSelectFork(vm.envString("BSC_MAINNET_RPC_URL"));

        IEndpointV2 endpoint = IEndpointV2(LAYERZERO_ENDPOINT_V2);

        bytes memory configBytes = endpoint.getConfig(
            0xAfF2e841851700D1Fc101995Ee6b81Ae21Bb87D7,  // OApp Address on BSC Mainnet
            0x9F8C645f2D0b2159767Bd6E0839DE4BE49e823DE,  // Send Uln on BSC Mainnet
            30101,  // eid 30101 is for Ethereum Mainnet
            2       // configType 2 is for UlnConfig
        );
        UlnConfig memory config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        20,                                         "confirmations should be 20");
        assertEq(config.requiredDVNCount,     4,                                          "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     type(uint8).max,                            "optionalDVNCount should be NIL_DVN_COUNT");
        assertEq(config.optionalDVNThreshold, 0,                                          "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  4,                                          "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                                          "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      0x247624e2143504730aeC22912ed41F092498bEf2, "first DVN should be Horizen");
        assertEq(config.requiredDVNs[1],      0x31F748a368a893Bdb5aBB67ec95F232507601A73, "second DVN should be Nethermind");
        assertEq(config.requiredDVNs[2],      0xfA9bA83C102283958B997Adc8B44ED3A3CdB5dDa, "third DVN should be Canary");
        assertEq(config.requiredDVNs[3],      0xfD6865c841c2d64565562fCc7e05e619A30615f0, "fourth DVN should be LayerZero Labs");
    }

    function test_BSC_ReceiveConfig() external {
        vm.createSelectFork(vm.envString("BSC_MAINNET_RPC_URL"));

        IEndpointV2 endpoint = IEndpointV2(LAYERZERO_ENDPOINT_V2);

        bytes memory configBytes = endpoint.getConfig(
            0xAfF2e841851700D1Fc101995Ee6b81Ae21Bb87D7,  // OApp Address on BSC Mainnet
            0xB217266c3A98C8B2709Ee26836C98cf12f6cCEC1,  // Receive Uln on BSC Mainnet
            30101,  // eid 30101 is for Ethereum Mainnet
            2       // configType 2 is for UlnConfig
        );
        UlnConfig memory config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        15,                                         "confirmations should be 15");
        assertEq(config.requiredDVNCount,     4,                                          "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     type(uint8).max,                            "optionalDVNCount should be NIL_DVN_COUNT");
        assertEq(config.optionalDVNThreshold, 0,                                          "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  4,                                          "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                                          "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      0x247624e2143504730aeC22912ed41F092498bEf2, "first DVN should be Horizen");
        assertEq(config.requiredDVNs[1],      0x31F748a368a893Bdb5aBB67ec95F232507601A73, "second DVN should be Nethermind");
        assertEq(config.requiredDVNs[2],      0xfA9bA83C102283958B997Adc8B44ED3A3CdB5dDa, "third DVN should be Canary");
        assertEq(config.requiredDVNs[3],      0xfD6865c841c2d64565562fCc7e05e619A30615f0, "fourth DVN should be LayerZero Labs");
    }

}
