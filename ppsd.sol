// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract ppsd is ERC20 {
    uint private price = 370000000000000;
    address payable forwardingAddress = payable(0x3B06b969289E9c04BFe39D3A394c40d45A1B2018);
    address private owner;
    
    constructor() ERC20("PPSD", "PPSD") {
        owner = msg.sender;
       	_mint(owner, 1_000_000 * (10 ** uint256(decimals())));
        _mint(address(this), 1_000_000 * (10 ** uint256(decimals())));
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "This operation is only allowed to the owner.");
        _;
    }

    function isValidAddress(address addr) internal view returns (bool) {
        uint256 size;
		assembly { size := extcodesize(addr) }
        return size == 40;
    }
    
    function changePrice(uint256 newPrice) external onlyOwner {
    	require(newPrice != 0, "Token price cannot be 0.");
        price = newPrice;
    }
    
    function changeForwardingAddress(address newAddress) external onlyOwner {
        require(newAddress != address(0), "New address can't be null.");
		require(isValidAddress(newAddress), "Invalid address specified");
        forwardingAddress = payable(newAddress);
    }
    
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New address can't be null.");
		require(isValidAddress(newOwner), "Invalid address specified");
        owner = newOwner;
    }
    
    function retrieveTokens() external onlyOwner {
        uint256 amount = balanceOf(address(this));
        _transfer(address(this), owner, amount);
    }
    
    receive() external payable{
        uint256 amount = msg.value * (10 ** decimals()) / price;
        _transfer(address(this), msg.sender, amount);
        forwardingAddress.transfer(address(this).balance);
    }
}
