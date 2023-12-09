// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InDance is Ownable, ERC20 {
    struct Dancer {
        uint256 level;
        uint256 params;
    }

    struct DancerBuyData {
        uint256 level;
        uint256 coinsPerMinute;
        uint256 price;
    }

    struct DanceFloor {
        Dancer[9] dancers;
        uint256 base_tokens_per_minute;
    }

    mapping(address => DanceFloor[]) floors;
    mapping(address => uint256) floors_num;
    mapping(address => uint256) last_claimed;
    mapping(address => uint256) claims;
    mapping(address => uint256) tokens_per_minute;

    uint256 constant FLOOR_PRICE = 100;

    constructor() Ownable(msg.sender) ERC20("In Dance", "IND") {}

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
        uint256 claim_ = claims[user];
        uint256 lastClaimedTime = last_claimed[user];

        uint256 claimPending = 0;

        if (lastClaimedTime > 0) {
            uint256 userTokensPerMinute = tokens_per_minute[user];
            uint256 timeDiff = block.timestamp - lastClaimedTime;
            claimPending += timeDiff * userTokensPerMinute;
        }

        return claim_ + claimPending;
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

        floors[msg.sender][lastFloorId].base_tokens_per_minute +=
            buyData.coinsPerMinute *
            10 ** 18;
        tokens_per_minute[msg.sender] += buyData.coinsPerMinute * 10 ** 18;

        floors[msg.sender][lastFloorId].dancers[lastDancerId].level = level;
        floors[msg.sender][lastFloorId].dancers[lastDancerId].params = block
            .timestamp;
    }

    function buyFloor(uint256 level) public {
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
        }

        floors_num[msg.sender] += 1;
        floors[msg.sender].push();
    }

    function _claim(address user) private returns (uint256 totalClaim) {
        uint256 claim_ = claims[user];
        uint256 lastClaimedTime = last_claimed[user];

        uint256 claimPending = 0;

        if (lastClaimedTime == 0) {
            return 0;
        }

        uint256 userTokensPerMinute = tokens_per_minute[user];
        uint256 timeDiff = block.timestamp - lastClaimedTime;

        claimPending += timeDiff * userTokensPerMinute;

        last_claimed[user] = block.timestamp;

        totalClaim = claim_ + claimPending;
    }
}
