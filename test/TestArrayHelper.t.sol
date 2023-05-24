import "../src/FraxTest.sol";
import { ArrayHelper } from "../src/ArrayHelper.sol";

contract TestArrayHelper is FraxTest {
    using ArrayHelper for *;

    function testPush() public {
        address[] memory _myArray = new address[](3);
        _myArray.modify();
        _myArray = _myArray.concat(address(36));
        for (uint256 i = 0; i < _myArray.length; i++) {
            console.log(_myArray[i]);
        }
        assertEq(_myArray.length, 4);
    }

    function modify(address[] memory _myArray) public {
        _myArray[1] = address(26);
    }
}
