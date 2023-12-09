// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InDance is Ownable, ERC20 {
    struct Dancer {
        uint256 level;
        uint256 params;
    }

    struct Tuple {
        uint256 elem1;
        uint256 elem2;
    }

    struct DancerBuyData {
        uint256 level;
        uint256 coinsPerMinute;
        uint256 price;
    }

    struct DanceFloor {
        Dancer[9] dancers;
        uint256 base_tokens_per_second;
    }

    mapping(address => DanceFloor[]) floors;
    mapping(address => uint256) floors_num;
    mapping(address => uint256) last_claimed;
    mapping(address => uint256) tokens_per_second;

    uint256 constant FLOOR_PRICE = 100;
    uint256 constant INITIAL_TOKEN_DROP = 10;

    constructor() Ownable(msg.sender) ERC20("In Dance", "IND") {}

    function getGameData(address user) external view returns (Tuple[10] memory result) {
        uint256 lastFloorId = floors_num[user];

        if (lastFloorId == 0) {
            revert("NOFL");
        }

        // Compatibility with rust contracts
        lastFloorId -= 1;

        Dancer[9] memory floor = getDanceFloor(user, lastFloorId);

        for (uint256 i = 0; i < 9; i++) {
            result[i] = Tuple(floor[i].level, floor[i].params);
        }

        uint256 balance = balanceOf(user);
        uint256 claimable = this.getClaimable(user);
        uint256 userTokensPerSecond = tokens_per_second[user];
        result[9].elem1 = balance + claimable;
        result[9].elem2 = userTokensPerSecond;
    }

    function getDancersToBuy() public pure returns (DancerBuyData[5] memory) {
        return [
            DancerBuyData(1, 2, 5),
            DancerBuyData(2, 5, 15),
            DancerBuyData(3, 10, 25),
            DancerBuyData(4, 100, 200),
            DancerBuyData(5, 5000, 10000)
        ];
    }

    function getClaimable(address user) public view returns (uint256) {
        uint256 lastClaimedTime = last_claimed[user];

        uint256 claimPending = 0;

        if (lastClaimedTime > 0) {
            uint256 userTokensPerMinute = tokens_per_second[user];
            uint256 timeDiff = block.timestamp - lastClaimedTime;
            claimPending += timeDiff * userTokensPerMinute;
        }

        return claimPending;
    }

    function claim() public returns (uint256 totalClaim) {
        totalClaim = _claim(msg.sender);
    }

    function getDanceFloor(
        address user,
        uint256 floorId
    ) public view returns (Dancer[9] memory) {
        DanceFloor[] storage userFloors = floors[user];
        DanceFloor storage floor = userFloors[floorId];
        return floor.dancers;
    }

    function buyDancer(uint256 level) public {
        _claim(msg.sender);

        if (level == 0) {
            revert("ZLVL");
        }

        DancerBuyData memory buyData = getDancersToBuy()[level - 1];

        uint256 price = buyData.price * 10 ** 18;

        if (balanceOf(msg.sender) < price) {
            revert("NOMO");
        }

        // Burn token
        _update(msg.sender, address(0), price);

        uint256 floorsNum = floors_num[msg.sender];

        if (floorsNum == 0) {
            revert("NOFL");
        }

        uint256 lastFloorId = floorsNum - 1;

        uint256 lastDancerId = 0;

        for (uint256 i = 0; i < 9; i++) {
            if (floors[msg.sender][lastFloorId].dancers[i].level > 0) {
                lastDancerId++;
            } else {
                break;
            }
        }

        if (lastDancerId == 9) {
            revert("FULL");
        }

        floors[msg.sender][lastFloorId].base_tokens_per_second +=
            buyData.coinsPerMinute *
            10 ** 18;
        tokens_per_second[msg.sender] += buyData.coinsPerMinute * 10 ** 18;

        floors[msg.sender][lastFloorId].dancers[lastDancerId].level = level;
        floors[msg.sender][lastFloorId].dancers[lastDancerId].params = block
            .timestamp;
    }

    function buyFloor() public {
        uint256 floorsNum = floors_num[msg.sender];

        // Only first floor is free
        if (floorsNum > 0) {
            uint256 price = FLOOR_PRICE * 10 ** 18;
            uint256 balance = balanceOf(msg.sender);

            if (balance < price) {
                revert("NOMO");
            }

            // Burn token
            _update(msg.sender, address(0), price);

            uint256 lastDancerId = 0;
            uint256 lastFloorId = floorsNum - 1;

            for (uint256 i = 0; i < 9; i++) {
                if (floors[msg.sender][lastFloorId].dancers[i].level > 0) {
                    lastDancerId++;
                } else {
                    break;
                }
            }

            if (lastDancerId < 9) {
                revert("NOTF");
            }
        } else {
            _update(address(0), msg.sender, INITIAL_TOKEN_DROP * 10 ** 18);
        }

        floors_num[msg.sender] += 1;
        floors[msg.sender].push();
    }

    function _claim(address user) private returns (uint256 totalClaim) {
        uint256 lastClaimedTime = last_claimed[user];

        last_claimed[user] = block.timestamp;

        uint256 claimPending = 0;

        if (lastClaimedTime == 0) {
            return 0;
        }

        uint256 userTokensPerMinute = tokens_per_second[user];
        uint256 timeDiff = block.timestamp - lastClaimedTime;

        claimPending += timeDiff * userTokensPerMinute;


        totalClaim = claimPending;
    }
}
