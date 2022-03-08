//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// this is how to implement ERC20 token and using it to create an ico period

interface ERC20Interface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);

    function approve(address spender, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

contract Cryptos is ERC20Interface {
    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint256 public decimals = 0; //18
    uint256 public override totalSupply;

    address public founder;
    mapping(address => uint256) public balances; // balances[0xda4...] = 100
    mapping(address => mapping(address => uint256)) allowed; //0x11(owner) allow 0x22 (spender) ---- 100 tokens

    constructor() {
        totalSupply = 100000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens)
        public
        virtual
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= tokens);
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokens)
        public
        virtual
        override
        returns (bool success)
    {
        require(
            balances[msg.sender] >= tokens,
            "You request more token than owner has!"
        );
        require(tokens > 0);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public virtual override returns (bool success) {
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);

        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][to] -= tokens;

        return true;
    }
}

contract CryptosICO is Cryptos {
    address public admin;
    address payable public deposit; // account that store the money (Ethereum)
    uint256 tokenPrice = 0.001 ether; // 1 eth = 1000 CRPT
    uint256 public hardCap = 300 ether;
    uint256 public raisedAmount;
    uint256 public saleStart = block.timestamp; // ICO start rightaway
    uint256 public saleEnd = block.timestamp + 604800; // ICO end in 1 week
    uint256 public tokenTradeStart = saleEnd + 604800; // Can sell in a week after ICO
    uint256 public maxInvestment = 5 ether;
    uint256 public minInvestment = 0.1 ether;

    enum State {
        beforeStart,
        running,
        afterEnd,
        halted
    }
    State public icoState;

    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    // MODIFIERS
    modifier onlyAdmin() {
        require(msg.sender == admin, "You are not admin");
        _;
    }

    //EVENTS
    event Invest(address invester, uint256 value, uint256 tokens);

    // FUNCTIONS
    function halt() public onlyAdmin {
        icoState = State.halted;
    }

    function resume() public onlyAdmin {
        icoState = State.running;
    }

    function changeDepositAddress(address payable new_deposit)
        public
        onlyAdmin
    {
        deposit = new_deposit;
    }

    function getCurrentState() public view returns (State) {
        return
            (icoState == State.halted)
                ? State.halted
                : (block.timestamp < saleStart)
                ? State.beforeStart
                : (block.timestamp >= saleStart && block.timestamp <= saleEnd)
                ? State.running
                : State.afterEnd;
    }

    function invest() public payable returns (bool) {
        icoState = getCurrentState();
        require(icoState == State.running, "ICO event is not running!");
        require(
            msg.value >= minInvestment && msg.value <= maxInvestment,
            "You need to pay more than 0.01 ether and less than 5 ether!"
        );
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap, "Out of maximum!");

        uint256 tokens = msg.value / tokenPrice;
        require(
            balances[founder] >= tokens,
            "The owner is lack of Cryptos token!"
        );

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);
        emit Invest(msg.sender, msg.value, tokens);
        return true;
    }

    receive() external payable {
        invest();
    }

    // ICO locking
    function transfer(address to, uint256 tokens)
        public
        virtual
        override
        returns (bool success)
    {
        // Add more conditions to transfer function
        require(block.timestamp > tokenTradeStart);
        super.transfer(to, tokens); // super == Cryptos
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public virtual override returns (bool success) {
        // require ()
        require(block.timestamp > tokenTradeStart);
        super.transferFrom(from, to, tokens);
        return true;
    }

    function burn() public returns (bool) {
        icoState = getCurrentState();
        require(
            icoState == State.afterEnd,
            "You can not burn the token at this time!"
        );
        balances[founder] = 0;
        return true;
    }
}
