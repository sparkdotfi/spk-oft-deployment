import {ExecutorOptionType} from '@layerzerolabs/lz-v2-utilities';
import {OAppEnforcedOption, OmniPointHardhat} from '@layerzerolabs/toolbox-hardhat';
import {EndpointId} from '@layerzerolabs/lz-definitions';
import {generateConnectionsConfig} from '@layerzerolabs/metadata-tools';

const ethereumContract: OmniPointHardhat = {
  eid: EndpointId.ETHEREUM_V2_MAINNET,
  contractName: 'SPKOFTAdapter',
};

const bscContract: OmniPointHardhat = {
  eid: EndpointId.BSC_V2_MAINNET,
  contractName: 'SPKOFT',
};

const EVM_ENFORCED_OPTIONS: OAppEnforcedOption[] = [
  {
    msgType: 1,
    optionType: ExecutorOptionType.LZ_RECEIVE,
    gas: 100000,
    value: 0,
  },
];

export default async function () {
  // note: pathways declared here are automatically bidirectional
  // if you declare A,B there's no need to declare B,A
  const connections = await generateConnectionsConfig([
    [
      ethereumContract, // Chain A contract
      bscContract, // Chain B contract
      [['LayerZero Labs', 'Google'], []], // [ requiredDVN[], [ optionalDVN[], threshold ] ]
      [15, 20], // [A to B confirmations, B to A confirmations]
      [EVM_ENFORCED_OPTIONS, EVM_ENFORCED_OPTIONS], // Chain B enforcedOptions, Chain A enforcedOptions
    ],
  ]);

  return {
    contracts: [
        {
            contract: ethereumContract
        },
        {
            contract: bscContract
        }
    ],
    connections,
  };
}