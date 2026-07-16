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

    address internal constant LAYERZERO_ENDPOINT_V2   = 0x1a44076050125825900e736c501f859c50fE728c;  // Same address on Ethereum Mainnet and BSC.
    address internal constant OAPP                    = 0xAfF2e841851700D1Fc101995Ee6b81Ae21Bb87D7;  // Same address on Ethereum Mainnet and BSC.
    address internal constant RECEIVE_ULN_BSC_MAINNET = 0xB217266c3A98C8B2709Ee26836C98cf12f6cCEC1;  // Receive Uln on BSC Mainnet
    address internal constant RECEIVE_ULN_ETH_MAINNET = 0xc02Ab410f0734EFa3F14628780e6e695156024C2;  // Receive Uln on Ethereum Mainnet
    address internal constant SEND_ULN_BSC_MAINNET    = 0x9F8C645f2D0b2159767Bd6E0839DE4BE49e823DE;  // Send Uln on BSC Mainnet
    address internal constant SEND_ULN_ETH_MAINNET    = 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1;  // Send Uln on Ethereum Mainnet

    address internal constant BSC_CANARY_DVN         = 0xfA9bA83C102283958B997Adc8B44ED3A3CdB5dDa;  // Canary on BSC Mainnet
    address internal constant BSC_GOOGLE_DVN         = 0xD56e4eAb23cb81f43168F9F45211Eb027b9aC7cc;  // Google on BSC Mainnet
    address internal constant BSC_HORIZEN_DVN        = 0x247624e2143504730aeC22912ed41F092498bEf2;  // Horizen on BSC Mainnet
    address internal constant BSC_LAYERZERO_LABS_DVN = 0xfD6865c841c2d64565562fCc7e05e619A30615f0;  // LayerZero Labs on BSC Mainnet
    address internal constant BSC_NETHERMIND_DVN     = 0x31F748a368a893Bdb5aBB67ec95F232507601A73;  // Nethermind on BSC Mainnet

    address internal constant ETH_CANARY_DVN         = 0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd;  // Canary on Ethereum Mainnet
    address internal constant ETH_GOOGLE_DVN         = 0xD56e4eAb23cb81f43168F9F45211Eb027b9aC7cc;  // Google on Ethereum Mainnet
    address internal constant ETH_HORIZEN_DVN        = 0x380275805876Ff19055EA900CDb2B46a94ecF20D;  // Horizen on Ethereum Mainnet
    address internal constant ETH_LAYERZERO_LABS_DVN = 0x589dEDbD617e0CBcB916A9223F4d1300c294236b;  // LayerZero Labs on Ethereum Mainnet
    address internal constant ETH_NETHERMIND_DVN     = 0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5;  // Nethermind on Ethereum Mainnet

    uint32 internal constant BSC_EID = 30102;  // eid 30102 is for BSC to Ethereum Mainnet
    uint32 internal constant ETH_EID = 30101;  // eid 30101 is for Ethereum Mainnet to BSC

    uint32 internal constant CONFIG_TYPE = 2;  // configType 2 is for UlnConfig

    function test_ETH_SendConfig() external {
        // Before config

        vm.createSelectFork(getChain("mainnet").rpcUrl);

        IEndpointV2 endpoint = IEndpointV2(LAYERZERO_ENDPOINT_V2);

        bytes memory configBytes = endpoint.getConfig(
            OAPP,                  // OApp Address on Ethereum Mainnet
            SEND_ULN_ETH_MAINNET,  // Send Uln on Ethereum Mainnet
            BSC_EID,               // eid 30102 is for BSC
            CONFIG_TYPE            // configType 2 is for UlnConfig
        );
        UlnConfig memory config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        15,                     "confirmations should be 15");
        assertEq(config.requiredDVNCount,     2,                      "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     0,                      "optionalDVNCount should be 0");
        assertEq(config.optionalDVNThreshold, 0,                      "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  2,                      "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                      "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      ETH_LAYERZERO_LABS_DVN, "first DVN should be LayerZero Labs");
        assertEq(config.requiredDVNs[1],      ETH_GOOGLE_DVN,         "second DVN should be Google");

        // After config

        vm.createSelectFork(vm.envString("ETH_MAINNET_RPC_URL"));

        configBytes = endpoint.getConfig(
            OAPP,                  // OApp Address on Ethereum Mainnet
            SEND_ULN_ETH_MAINNET,  // Send Uln on Ethereum Mainnet
            BSC_EID,               // eid 30102 is for BSC
            CONFIG_TYPE            // configType 2 is for UlnConfig
        );
        config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        15,                     "confirmations should be 15");
        assertEq(config.requiredDVNCount,     4,                      "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     0,                      "optionalDVNCount should be 0");
        assertEq(config.optionalDVNThreshold, 0,                      "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  4,                      "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                      "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      ETH_HORIZEN_DVN,        "first DVN should be Horizen");
        assertEq(config.requiredDVNs[1],      ETH_LAYERZERO_LABS_DVN, "second DVN should be LayerZero Labs");
        assertEq(config.requiredDVNs[2],      ETH_CANARY_DVN,         "third DVN should be Canary");
        assertEq(config.requiredDVNs[3],      ETH_NETHERMIND_DVN,     "fourth DVN should be Nethermind");
    }

    function test_ETH_ReceiveConfig() external {
        // Before config

        vm.createSelectFork(getChain("mainnet").rpcUrl);

        IEndpointV2 endpoint = IEndpointV2(LAYERZERO_ENDPOINT_V2);

        bytes memory configBytes = endpoint.getConfig(
            OAPP,                     // OApp Address on Ethereum Mainnet
            RECEIVE_ULN_ETH_MAINNET,  // Receive Uln on Ethereum Mainnet
            BSC_EID,                  // eid 30102 is for BSC
            CONFIG_TYPE               // configType 2 is for UlnConfig
        );
        UlnConfig memory config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        20,                     "confirmations should be 20");
        assertEq(config.requiredDVNCount,     2,                      "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     0,                      "optionalDVNCount should be 0");
        assertEq(config.optionalDVNThreshold, 0,                      "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  2,                      "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                      "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      ETH_LAYERZERO_LABS_DVN, "first DVN should be LayerZero Labs");
        assertEq(config.requiredDVNs[1],      ETH_GOOGLE_DVN,         "second DVN should be Google");

        // After config

        vm.createSelectFork(vm.envString("ETH_MAINNET_RPC_URL"));

        configBytes = endpoint.getConfig(
            OAPP,                     // OApp Address on Ethereum Mainnet
            RECEIVE_ULN_ETH_MAINNET,  // Receive Uln on Ethereum Mainnet
            BSC_EID,                  // eid 30102 is for BSC
            CONFIG_TYPE               // configType 2 is for UlnConfig
        );
        config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        20,                     "confirmations should be 20");
        assertEq(config.requiredDVNCount,     4,                      "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     0,                      "optionalDVNCount should be 0");
        assertEq(config.optionalDVNThreshold, 0,                      "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  4,                      "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                      "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      ETH_HORIZEN_DVN,        "first DVN should be Horizen");
        assertEq(config.requiredDVNs[1],      ETH_LAYERZERO_LABS_DVN, "second DVN should be LayerZero Labs");
        assertEq(config.requiredDVNs[2],      ETH_CANARY_DVN,         "third DVN should be Canary");
        assertEq(config.requiredDVNs[3],      ETH_NETHERMIND_DVN,     "fourth DVN should be Nethermind");
    }

    function test_BSC_SendConfig() external {
        // Before config

        vm.createSelectFork(getChain("bnb_smart_chain").rpcUrl);

        IEndpointV2 endpoint = IEndpointV2(LAYERZERO_ENDPOINT_V2);

        bytes memory configBytes = endpoint.getConfig(
            OAPP,                  // OApp Address on BSC Mainnet
            SEND_ULN_BSC_MAINNET,  // Send Uln on BSC Mainnet
            ETH_EID,               // eid 30101 is for Ethereum Mainnet
            CONFIG_TYPE            // configType 2 is for UlnConfig
        );
        UlnConfig memory config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        20,                     "confirmations should be 20");
        assertEq(config.requiredDVNCount,     2,                      "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     0,                      "optionalDVNCount should be 0");
        assertEq(config.optionalDVNThreshold, 0,                      "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  2,                      "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                      "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      BSC_GOOGLE_DVN,         "first DVN should be Google");
        assertEq(config.requiredDVNs[1],      BSC_LAYERZERO_LABS_DVN, "second DVN should be LayerZero Labs");

        // After config

        vm.createSelectFork(vm.envString("BSC_MAINNET_RPC_URL"));

        configBytes = endpoint.getConfig(
            OAPP,                  // OApp Address on BSC Mainnet
            SEND_ULN_BSC_MAINNET,  // Send Uln on BSC Mainnet
            ETH_EID,               // eid 30101 is for Ethereum Mainnet
            CONFIG_TYPE            // configType 2 is for UlnConfig
        );
        config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        20,                     "confirmations should be 20");
        assertEq(config.requiredDVNCount,     4,                      "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     0,                      "optionalDVNCount should be 0");
        assertEq(config.optionalDVNThreshold, 0,                      "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  4,                      "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                      "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      BSC_HORIZEN_DVN,        "first DVN should be Horizen");
        assertEq(config.requiredDVNs[1],      BSC_NETHERMIND_DVN,     "second DVN should be Nethermind");
        assertEq(config.requiredDVNs[2],      BSC_CANARY_DVN,         "third DVN should be Canary");
        assertEq(config.requiredDVNs[3],      BSC_LAYERZERO_LABS_DVN, "fourth DVN should be LayerZero Labs");
    }

    function test_BSC_ReceiveConfig() external {
        // Before config

        vm.createSelectFork(getChain("bnb_smart_chain").rpcUrl);

        IEndpointV2 endpoint = IEndpointV2(LAYERZERO_ENDPOINT_V2);

        bytes memory configBytes = endpoint.getConfig(
            OAPP,                     // OApp Address on BSC Mainnet
            RECEIVE_ULN_BSC_MAINNET,  // Receive Uln on BSC Mainnet
            ETH_EID,                  // eid 30101 is for Ethereum Mainnet
            CONFIG_TYPE               // configType 2 is for UlnConfig
        );
        UlnConfig memory config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        15,                     "confirmations should be 15");
        assertEq(config.requiredDVNCount,     2,                      "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     0,                      "optionalDVNCount should be 0");
        assertEq(config.optionalDVNThreshold, 0,                      "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  2,                      "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                      "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      BSC_GOOGLE_DVN,         "first DVN should be Google");
        assertEq(config.requiredDVNs[1],      BSC_LAYERZERO_LABS_DVN, "second DVN should be LayerZero Labs");

        // After config

        vm.createSelectFork(vm.envString("BSC_MAINNET_RPC_URL"));

        configBytes = endpoint.getConfig(
            OAPP,                     // OApp Address on BSC Mainnet
            RECEIVE_ULN_BSC_MAINNET,  // Receive Uln on BSC Mainnet
            ETH_EID,                  // eid 30101 is for Ethereum Mainnet
            CONFIG_TYPE               // configType 2 is for UlnConfig
        );
        config = abi.decode(configBytes, (UlnConfig));

        assertEq(config.confirmations,        15,                     "confirmations should be 15");
        assertEq(config.requiredDVNCount,     4,                      "requiredDVNCount should be 4");
        assertEq(config.optionalDVNCount,     0,                      "optionalDVNCount should be 0");
        assertEq(config.optionalDVNThreshold, 0,                      "optionalDVNThreshold should be 4");
        assertEq(config.requiredDVNs.length,  4,                      "requiredDVNs length should be 4");
        assertEq(config.optionalDVNs.length,  0,                      "optionalDVNs length should be 0");
        assertEq(config.requiredDVNs[0],      BSC_HORIZEN_DVN,        "first DVN should be Horizen");
        assertEq(config.requiredDVNs[1],      BSC_NETHERMIND_DVN,     "second DVN should be Nethermind");
        assertEq(config.requiredDVNs[2],      BSC_CANARY_DVN,         "third DVN should be Canary");
        assertEq(config.requiredDVNs[3],      BSC_LAYERZERO_LABS_DVN, "fourth DVN should be LayerZero Labs");
    }

}
