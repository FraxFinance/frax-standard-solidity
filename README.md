# Code Style Quality

# Frax Style Guide (Work In Progress)

## The intention of this style guide is first and foremost to increase readability of code and reduce the potential for bugs.  Readability reduces overhead for new readers which includes colleagues and most importantly auditors.  Additionally, consistency reduces cognitive overhead.  When people read our code they should walk away feeling “Holy shit these guys are obsessed”. This comes with trade-offs, most obvious the speed at which code is **********initially********** written.

## This style guide is meant to be collaborative and in its current state is just a first pass (with some highly opinionated items), so if you disagree please reach out or make a PR instead of just ignoring it.  Good programmers are flexible and the guide is pointless if we don’t follow it.

## Repo

use kebab-case for repo names and folder names

use PascalCase for file names containing Contracts

- one contract per file
- utilize index style imports to consolidate multiple small items into one import if necessary

use camelCase for files containing multiple libraries or free function collections

all solidity should be in a src directory which contains contracts, test, and script folders 

## Misc

Prefer node module imports over github imports for secure code, latest code can be unstable, and npm packages are typically release candidates

## Language Features

Do not rely on via-ir to solve stack-too-deep errors, refactor instead

## Source File Structure

### File Structure

license

pragma

Frax Ascii art

imports

Contract

import order
imports should occur in the following order:
packages
contracts
interfaces

- within each category should be imported

import named files like import { SomeContract } from "./someContract.sol"; - This solves a lot of issues with naming collisions and makes compilation faster and makes verified code smaller

Call inherited contract constructors in the order they are inherited

Use named input params when invoking functions, this reduces overhead for auditors and reduces potential bugs

## Naming

immutable and constant variables should be CONSTANT_CASE

When testing a contract, File name should end/start with Test

internal and private functions should be prepended with an underscore _someInternalFunction _somePrivateFunction

Avoid abbreviations and acronyms in variables names, prefer descriptive variable names when possible

all other variables use camelCase (use google algorithm for acronyms)
i.e. FxsErc20 not FXSERC20, someVarVeFxs, Gohm

Use underscore to differentiate between memory and storage variables and to avoid naming collisions with storage variables

Give as descriptive a name as possible, within reason. Do not worry about saving horizontal space as it is far more important to make your code immediately understandable by a new reader. Do not use abbreviations that are ambiguous or unfamiliar to readers outside your project, and do not abbreviate by deleting letters within a word.

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

Method names
Method names are written in camelCase. 

Method names are typically verbs or verb phrases. For example, sendMessage or stopProcess. Getter and setter methods for properties are never required, but if they are used they should be named getFoo (or optionally isFoo or hasFoo for booleans), or setFoo(value) for setters.

Enum names are written in PascalCase, similar to classes, and should generally be singular nouns. Individual items within the enum are named in CONSTANT_CASE.

6.2.7 Parameter names
Parameter names are written in camelCase and prepended with an _ if memory or without to designate storage pointers

6.2.8 Local variable names
Local variable names are written in _camelCase.

| Prose form | Correct | Incorrect |
| --- | --- | --- |
| XML HTTP request | XmlHttpRequest | XMLHTTPRequest |
| new customer ID | newCustomerId | newCustomerID |
| inner stopwatch | innerStopwatch | innerStopWatch |
| supports IPv6 on iOS? | supportsIpv6OnIos | supportsIPv6OnIOS |
| YouTube importer | YouTubeImporter | YoutubeImporter* |

## Code Structure / Architecture

Be thoughtful about breaking up code and inheriting.  One pattern used in fraxlend is a separation of view helper functions and the core logic.  This is a separation by threat model. 

Group related code together, be thoughtful about the order in which you would like to present information to a new reader.  For internal functions, events, or errors used in a single place, group them next to the external function they are used in.  If they are used in multiple places follow guidelines below.  

Within a contract code should be in the following order:

storage variables

constructor

internals/helpers used in multiple places

external functions

custom errors

Events should be defined in interface.

Avoid public functions, instead define an internal and external version of the function.  This allows optimizer to work better.

Explicitly assign default values to names return params for maximum readability

Empty catch blocks should have comments explaining why they are acceptable

Separate calculations and storage mutation functions when possible.  This aids in testing and separation of concerns, helps adhere to checks-effects-interactions patterns

Avoid mutations when possible, prefer ternaries for conditional assignments, gas savings is not a good reason to mutate.  Write readable code then optimize gas when necessary

Avoid modifiers, create internal functions in the form of _requireCondition() which will revert on failure.  This allows optimizer to reduce bytecode more efficiently, works better IDE and analysis tools, and increases code intention without needing to jump to modifier definition.  Also order of execution is explicit

Use custom errors over require statements, saves both byte code and gas

## Pre-Audit Checklist

- 100% coverage
- Helper library to wrap functions which return tuples, use a doube underscore __nameOfFunction convention
- Have harness contract to expose internal functions for unit testing
- Example deployment instructions
- Slither and Mythril instructions
- Video walkthrough of each external function flow
- Access control documentation
- Threat modeling documentation
- Full natspec with slither @optional items included
    - Heavy commenting aimed at new reader
- No TODO, console.log, or commented out code