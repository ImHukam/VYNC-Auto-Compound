// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

interface SetDataInterface {
    function totalStake() external view returns (uint256);

    function totalUnstake() external view returns (uint256);
}

contract VyncBusdPoolInfo is Ownable {
    SetDataInterface data;
    address public VyncBusd;

    uint256 s; // total staking
    uint256 u; // total unstaking
    uint256 b; // available Staking
    uint256 pl = 1000000; // yearly interst;
    bool r_ed = false; // r enable disable
    uint256 r; // extra apr basesd on yearly interst
    uint256 apr = 1 * 1e18; //daily apr
    uint256 a; // total apr: r+apr;
    uint256 compoundRate = 600; // compound rate in seconds
    uint256 up = 50; // unstake percentage
    uint256 maxStakePerTx = 5000 * 1e18; // in 18 decimal
    uint256 maxUnstakePerTx = 5000 * 1e18;
    uint256 totalStakePerUser = 20000 * 1e18;
    uint256 public price=1*1e18; // in 18 decimal
    address public priceSetAddress;
    uint256 public slippage = 3; //can be modify using set_slippage() function(between 1-90%)
    uint256 aprChangeTimestamp;
    uint256 aprChangePercentage;
    bool aprIncrease;

    function poolInfo()
        external
        view
        returns (
            uint256 _s,
            uint256 _u,
            uint256 _b,
            uint256 _pl,
            bool _r_ed,
            uint256 _r,
            uint256 _apr,
            uint256 _a,
            uint256 _compoundRate,
            uint256 _up
        )
    {
        (_s, , ) = set_sub();
        (, _u, ) = set_sub();
        (, , _b) = set_sub();
        _pl = pl;
        _r_ed = r_ed;
        _r = set_r();
        _apr = apr;
        _a = set_a();
        _compoundRate = compoundRate;
        _up = up;
    }

    function returnData()
        external
        view
        returns (
            uint256 _a,
            uint256 _compoundRate,
            uint256 _up
        )
    {
        _a = set_a();
        _compoundRate = compoundRate;
        _up = up;
    }

    function returnAprData()
        external
        view
        returns (
            uint256 _aprChangeTimestamp,
            uint256 _aprChangePercentage,
            bool _aprIncrease
        )
    {
        _aprChangeTimestamp = aprChangeTimestamp;
        _aprChangePercentage = aprChangePercentage;
        _aprIncrease = aprIncrease;
    }

    function returnMaxStakeUnstakePrice()
        external
        view
        returns (
            uint256 _maxStakePerTx,
            uint256 _maxUnstakePerTx,
            uint256 _totalStakePerUser,
            uint256 _price
        )
    {
        _maxStakePerTx = maxStakePerTx;
        _maxUnstakePerTx = maxUnstakePerTx;
        _totalStakePerUser = totalStakePerUser;
        _price= price;
    }

    function set_VyncBusd(address _VyncBusd) public onlyOwner {
        VyncBusd = _VyncBusd;
        data = SetDataInterface(_VyncBusd);
    }

    // set staking,unstaking, available staking
    function set_sub()
        private
        view
        returns (
            uint256 _s,
            uint256 _u,
            uint256 _b
        )
    {
        _s = data.totalStake();
        _u = data.totalUnstake();
        _b = _s - _u;
    }

    //set pl
    function set_pl(uint256 _pl) public onlyOwner {
        pl = _pl;
    }

    //set r_ed
    function set_r_ed(bool _r_ed) public onlyOwner {
        r_ed = _r_ed;
    }

    //set r
    function set_r() private view returns (uint256 _r) {
        uint256 _b = data.totalStake() - data.totalUnstake();
        if (r_ed == true) {
            uint256 _pl = pl;
            _r = _b / _pl;
        }
        if (r_ed == false) {
            _r = 0;
        }
    }

    //set apr
    function set_apr(uint256 newApr) public onlyOwner {
        aprIncrease = apr>newApr? false:true;
        uint256 diff= apr>newApr ? (apr-newApr): (newApr - apr);
        aprChangePercentage = (diff*100)/ apr;

        apr = newApr;
        aprChangeTimestamp=block.timestamp;
    }

    //set a
    function set_a() private view returns (uint256 _a) {
        uint256 _r = set_r();
        _a = apr + _r;
    }

    //set compound rate
    function setCompoundRate(uint256 _compoundRate) public onlyOwner {
        compoundRate = _compoundRate;
    }

    //set up
    function set_up(uint256 _up) public onlyOwner {
        require(
            _up >= 0 && _up <= 100,
            "invalid percentage, input between 0 to 100"
        );
        up = _up;
    }

    function set_maxStakePerTx(uint256 _amount) public onlyOwner {
        maxStakePerTx = _amount;
    }

    function set_maxUnstakePerTx(uint256 _amount) public onlyOwner {
        maxUnstakePerTx = _amount;
    }

    function set_totalStakePerUser(uint256 _amount) public onlyOwner {
        totalStakePerUser = _amount;
    }

    function setPrice(uint256 _price) public {
        require(
            msg.sender == priceSetAddress,
            "only priceSetAddress can change price"
        );
        price = _price;
    }

    function changePriceSetAddress(address _address) public onlyOwner {
        require(
            _address != address(0),
            "can not set zero address for price set address"
        );
        priceSetAddress = _address;
    }

   function set_slippage(uint256 _slippage) public onlyOwner {
        require(_slippage > 0 && _slippage <= 90, "invalid slippage range");
        slippage = _slippage;
    }

    function swapAmountCalculation(uint256 _amount) external view returns(uint256 amount){
    }
}