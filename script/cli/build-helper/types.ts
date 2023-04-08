export interface AbiItem {
  inputs: Input[];
  stateMutability?: StateMutability;
  type: ABIType;
  name: string;
  anonymous?: boolean;
  outputs: Input[];
}

export interface Input {
  internalType: InternalTypeEnum;
  name: string;
  type: InternalTypeEnum;
  indexed?: boolean;
  components?: Input[];
}

export enum InternalTypeEnum {
  Address = "address",
  Bool = "bool",
  Bytes = "bytes",
  ContractIERC20 = "contract IERC20",
  ContractIRateCalculatorV2 = "contract IRateCalculatorV2",
  String = "string",
  StructFraxlendPairCoreCurrentRateInfo = "struct FraxlendPairCore.CurrentRateInfo",
  StructVaultAccount = "struct VaultAccount",
  Tuple = "tuple",
  TypeAddress = "address[]",
  Uint128 = "uint128",
  Uint184 = "uint184",
  Uint256 = "uint256",
  Uint32 = "uint32",
  Uint64 = "uint64",
  Uint8 = "uint8",
}

export enum StateMutability {
  Nonpayable = "nonpayable",
  Pure = "pure",
  View = "view",
}

export enum ABIType {
  Constructor = "constructor",
  Error = "error",
  Event = "event",
  Function = "function",
}

export interface StructItem {
  name: string;
  type: string;
}

export interface Struct {
  name: string;
  items: StructItem[];
}

export interface Func {
  name: string;
  args: { name: string; type: string }[];
}

export interface OutputItem {
  struct: Struct;
  func: Func;
}
