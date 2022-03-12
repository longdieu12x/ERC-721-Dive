//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

contract ERC721 {
    mapping(address => uint256) internal _balances;
    mapping(uint256 => address) internal _owners;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => address) private _tokenApprovals;
    // EVENTS
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    // returns number of nft of an owner
    function balanceOf(address _owner) external view returns (uint256) {
        require(
            _owner != address(0),
            "Address of owner is zero, please try again !"
        );
        return _balances[_owner];
    }

    // find owner of nft
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _owners[_tokenId];
        require(owner != address(0), "Token ID does not exist!");
        return owner;
    }

    // enable or disable an operator
    function setApprovalForAll(address _operator, bool _approved) external {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // check if an address is an operator for another address
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        return _operatorApprovals[_owner][_operator];
    }

    // approve for an address right for 1 nft
    function approve(address _approved, uint256 _tokenId) public payable {
        address owner = ownerOf(_tokenId);
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender) == true,
            "You have no right!!!"
        );
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    // return address of who can operate this token
    function getApproved(uint256 _tokenId) public view returns (address) {
        require(
            _owners[_tokenId] != address(0),
            "There doesn't exist this token!"
        );
        return _tokenApprovals[_tokenId];
    }

    // transfer nft from 1 address to another address
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable {
        address owner = ownerOf(_tokenId);

        require(getApproved(_tokenId) == msg.sender, "You have no right!!!");
        require(owner == _from, "From address is not the owner !");
        require(_to != address(0), "To address is invalid !");
        require(
            _owners[_tokenId] != address(0),
            "There doesn't exist this token!"
        );

        approve(address(0), _tokenId);
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    // standard transferFrom method
    // check if receiver smart contract is capable of receiving nft
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public payable {
        transferFrom(_from, _to, _tokenId);
        require(_checkOnERC721Received(), "Receiver not implemented");
    }

    // simple version of check for nft receivability of a smart contract
    function _checkOnERC721Received() private pure returns (bool) {
        return true;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    // EIPS165 proposal: query if a contract implements another interface
    function supportInterface(bytes4 interfaceID)
        public
        pure
        virtual
        returns (bool)
    {
        return interfaceID == 0x80ac58cd;
    }
}
