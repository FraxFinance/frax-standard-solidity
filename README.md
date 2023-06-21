# Frax Style Guide (Work In Progress)

## The intention of this style guide is first and foremost to increase readability of code and reduce the potential for bugs.  Readability reduces overhead for new readers which includes colleagues and most importantly auditors.  Additionally, consistency reduces cognitive overhead.  When people read our code they should walk away feeling “Holy shit these guys are obsessed”. This comes with trade-offs, most obvious the speed at which code is **********initially********** written.

## This style guide is meant to be collaborative and in its current state is just a first pass (with some highly opinionated items), so if you disagree please reach out or make a PR instead of just ignoring it.  Good programmers are flexible and the guide is pointless if we don’t follow it.

# Principles

### Optimize for the reader (auditor) and fellow developers, not the writer

We explicitly optimize for the experience of the reader, not the writer.  Implicitly this means that the speed of writing new code will decrease.  The ultimate goal of these rules is to provide a framework that allows new readers the ability to quickly understand the codebase and to reduce the surface area for auditor focus.

### Be consistent

Good engineers are flexible not dogmatic, don’t mix and match styles.  Consistency reduces cognitive overhead for readers.

# Repository

### Use kebab-case for repository names and folder names

Example: `@FraxFinance/fraxlend-dev`

### Use `-dev` suffix to indicate internal repos, public repos should have the same name without `-dev`

Example:
Private Repo: `fraxlend-dev`
Public Repo: `fraxlend`

### Utilize forge + prettier as the default formatter

This repo contains a .prettierrc.json file for use with prettier.  Prettier is significantly smarter and has better line-wrapping heuristics than forge

### Utilize solhint as the default linter

This repo contains a .solhint.json file for use with solhint

### Utilize husky and lint-staged to lint all files pre-commit

This repo has an example `.lintstagedrc` file and `.husky` folder for reference

## File Names

### One Contract/Interface/Library per File

Utilize an import file if you would like to group files together by namespace for easy importing

Example:

```solidity
// This file aggregates the different contracts and should be named appropriately
import { SomeContract } from ".SomeContract.sol";
import { SomeContract1 } from ".SomeContract1.sol";
import { SomeContract2 } from ".SomeContract2.sol";
import { SomeContract3 } from ".SomeContract3.sol";
```

### Use PascalCase.sol for file names containing Contracts

### Use IPascalCase.sol for file names containing interfaces

### File Name should exactly match the name of the contract/interface/library

### Files containing tests should start with word `Test` and end with `.t.sol`

Example: `TestFraxlendPairCore.t.sol`

### Use camelCase for files containing a group of free functions

Example: `deployFunctions.sol` (contains no contracts just a collection of free functions)

### Root directory should contains `src`, `test`, `script` directories

`src` contains contracts and interfaces which are deployed

`test` contains test contracts

`script` contains files for scripting including repo management and deploy scripts

# Misc

### Use npm to install github dependencies
Why: submodules dont provide lockfiles or commit binding.  We need to be sure that we are running/deploying the exact same code across machines.<br>
Why: Breaking changes are common and explicitly upgrading can prevent issues across machines

### Prefer node_module packages over github packages for secure code

Why: Latest code can be unstable and npm packages are typically release candidates

### Use Proper licenses

Proprietary: `// SPDX-License-Identifier: BUSL-1.1`

Open and composable: TODO

# Language Features

### Do not rely on via-ir to solve stack-too-deep errors

Why: via-ir is slow and reduces testing speed.  If reaching `stack too deep` your code complexity is probably too high.  For src code, reduce complexity, for tests use param/return structs.

### Use named input params when invoking functions
Required for functions with 2+ parameters

Example:

```solidity
function fooBar(address _foo, address _bar) internal;

//Good
fooBar({ _foo: address(123), _bar: address(345)});

//Bad
fooBar(address(345), address(123));
```

Why: 

- Reduces potential bugs introduced during refactors which change order of functions
- Reduces overhead for readers as code intention is more clear, eliminates need to look at function definition

# Source File Structure

### File Structure should be in the following order:

1. license
2. pragma
3. Frax Ascii art
4. imports
5. ConstructorParams Struct
6. Contract

### Imports should occur in the following order:

1. github packages
2. node_module packages
3. contracts
4. interfaces
- within each category, items should be alphabetical

### Use named imports { SomeContract } from "./SomeContract.sol";

Why:
- [Forge best practices](https://book.getfoundry.sh/tutorials/best-practices)
- Reduces the need for the reader to have additional context when coming across an identifier.  Because identifiers are otherwise inherited, the location of an identifier is not known to the reader without a global search or IDE tooling
- Solves issues with naming collisions
- Makes compilation (and therefore testing) faster and makes verified code smaller

### Call inherited contract constructors in the order they are inherited

Why: Helps solve stack-too-deep errors, consistency, reinforces order of constructor execution

## Naming

### Immutable and constant variables should be CONSTANT_CASE

### Internal and private functions should be prepended with an underscore _someInternalFunction _somePrivateFunction

## Avoid abbreviations and acronyms in variables names, prefer descriptive variable names

Code should be self-documenting.  Give as descriptive a name as possible. It is far more important to make your code immediately understandable by a new reader than to optimize line wrapping. Do not use abbreviations that are ambiguous or unfamiliar to readers outside your project, and do not abbreviate by deleting letters within a word.

| Allowed |  |
| --- | --- |
| errorCount | No abbreviation. |
| dnsConnectionIndex | Most people know what "DNS" stands for. |
| referrerUrl | Ditto for "URL". |
| customerId | "Id" is both ubiquitous and unlikely to be misunderstood. |

| Disallowed |  |
| --- | --- |
| n | Meaningless. |
| nErr | Ambiguous abbreviation. |
| nCompConns | Ambiguous abbreviation. |
| wgcConnections | Only your group knows what this stands for. |
| pcReader | Lots of things can be abbreviated "pc". |
| cstmrId | Deletes internal letters. |
| kSecondsPerDay | Do not use Hungarian notation. |

## Method names

### Method names are written in camelCase and are typically verbs or verb phrases

Example: sendMessage or stopProcess. 

### Enum names are written in PascalCase and should generally be singular nouns. Individual items within the enum are named in CONSTANT_CASE.

### Parameter names are written in camelCase and prepended with an _ if memory or without to designate storage pointers

Example:

```solidity
function sendMessage(string memory _messageBody, string storage messageHeader); 
```

### Storage variable names are written in camelCase

### Local variable names are written in _camelCase and prepended with an underscore to differentiate from storage variables

## Use google’s camelCase algorithm to handle acronyms/abbreviations and edge cases
Additional Info: [Google camelCase Algorithm](https://google.github.io/styleguide/jsguide.html#naming-camel-case-defined)<br>
Additional clarity: for words like iOS veFXS or gOhm, when prefix letter is single treat as one word, when prefix letters are >1 (frxETH or veFXS) treat prefix as separate word:

| Prose form | Correct | Incorrect |
| --- | --- | --- |
| veFXS | veFxs | veFXS |
| some gOhm item | someGohmItem | someGOHMItem |
| XML HTTP request | xmlHttpRequest | XMLHTTPRequest |
| iOS | ios | IOS |
| new customer ID | newCustomerId | newCustomerID |
| inner stopwatch | innerStopwatch | innerStopWatch |
| supports IPv6 on iOS? | supportsIpv6OnIos | supportsIPv6OnIOS |
| YouTube importer | youTubeImporter | YoutubeImporter* |
| gOHM ERC-20 | gohmErc20 | gOHMERC20 |
| some veFXS item | someVeFxsItem | someVeFXSItem |

## Code Structure / Architecture

### Be thoughtful about breaking up code and inheriting.
One pattern used in fraxlend is a separation of view helper functions and the core logic.  This is a separation by threat model. 

 ### Group related code together
 Be thoughtful about the order in which you would like to present information to a new reader.  For internal functions used in a single place, group them next to the external function they are used in.  If they are used in multiple places follow guidelines below.  

### Within a contract code should be in the following order:
[Open for discussion on this item]

1. storage variables
2. constructor
3. internals/helpers used in multiple places
4. external functions
5. custom errors
6. Events should be defined in the interface.


### Explicitly assign default values to named return params for maximum readability

### Empty catch blocks should have comments explaining why they are acceptable

### [Important] Separate calculation and storage mutation functions when possible.
This aids in testing and separation of concerns, helps adhere to checks-effects-interactions patterns.  For calculations, use storage pointers as arguments to reduce SLOADs if necessary.  Allows for the creation of preview functions to create a preview of some action, this is required for compose-ability (see ERC4626 for an example of preview functions)<br>
See: TODO: governance example in delegation

### Avoid mutations when possible
Gas savings is not a good reason to mutate.  Write readable code then optimize gas when necessary. Makes debugging easier and code understanding more clear.

### Avoid modifiers unless you need to take action both before and after function invocation
Create internal functions in the form of _requireCondition() which will revert on failure.
Why: This allows optimizer to reduce bytecode more efficiently, works better with IDE and analysis tools, and increases code intention without needing to jump to modifier definition.  Also order of execution is explicit. [Exception: when you need to run code both BEFORE and AFTER the wrapped function]
``` solidity
    // BAD
    modifier TimelockOnly() {
        if (msg.sender != TIMELOCK_ADDRESS) revert()
    }

    function WithdrawFees() TimelockOnly {
        // some code
    }

    // GOOD
    function _requireSenderIsTimelock() internal {
        if (msg.sender != TIMELOCK_ADDRESS) revert Unauthorized();
    }

    function WithdrawFees() {
        _requireSenderIsTimelock();
        // some code
    }
```


### Use custom errors over require statements, saves both byte code and gas
```solidity
    // Bad
    function _requireSenderIsTimelock() internal {
        require(msg.sender = TIMELOCK_ADDRESS, "unauthorized");
    }

    // Good
    function _requireSenderIsTimelock() internal {
        if (msg.sender != TIMELOCK_ADDRESS) revert Unauthorized();
    }
```


### Dont return expressions, instead assign named return param variable


# Tests
### Separate scenario setup and test functions.
Why: Tests for impure functions should be tested under a variety of state conditions.  Separating test assertions and scenario setups allows for re-using code across multiple scenarios. See 

### Write tests in a way that you can run the test suite against deployed contracts afterwards
See: [Frax Governance Test Example](https://github.com/FraxFinance/frax-governance-dev/blob/098a14115b447f4de94902a4ff13882ac1059ee5/test/TestFraxGovernorFork.t.sol)<br>
See: [Fraxlend Oracles Test Example](https://github.com/FraxFinance/fraxlend-oracles-dev/blob/master/test/e2e/TestFraxUsdcCurveLpDualOracle.t.sol)

### Utilize fuzz tests

### Separate helpers to separate file

### Create invariant assertions that can be used in multiple places

### Dont sleep on echidna

# Pre-Audit Checklist

- 100% test coverage
- Adheres to style guide
- Example deployment instructions
- Slither and Mythril instructions and remaining issues addressed
- Video walkthrough of each external function flow
- Access control documentation
- Threat modeling documentation
- Heavy commenting aimed at new reader
- No TODO, console.log, or commented out code
