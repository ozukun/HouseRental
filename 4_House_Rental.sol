// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";


/*
1- Call addHouseforRent to add rental house to rental list
2- giverOffer
*/


contract House_Rental {


        enum  RentalStatus{ OPEN, CLOSED }
        address null_address=0x0000000000000000000000000000000000000000;
        mapping(address => string)  private HouseIndex_List;
        uint counter=0;
        struct House{
            address LandLord;
            string  HouseIndex;  // IndexNumber as a list of values for each LandLord
            uint    rental_price;
            address Tentant;
            RentalStatus status;
        }

        House[] private Rental_House_List;
        //address owner;

        constructor() {
            //owner=msg.sender;
        }

        function  addHouseforRent(address i_LandLord,uint i_rental_price) public  {

            string memory House_Index_List;
            string memory tmp1=Strings.toString(counter);
            if (keccak256(bytes(HouseIndex_List[i_LandLord])) == keccak256(bytes("")))
            {
                House_Index_List=string( tmp1) ;
            }
            else
            {
                House_Index_List=string( abi.encodePacked(HouseIndex_List[i_LandLord],',',tmp1) );    
            }
            
            //string memory tmp2=toAsciiString(i_LandLord);

            HouseIndex_List[i_LandLord]=House_Index_List;
            Rental_House_List.push(House({
                            LandLord: i_LandLord, 
                            HouseIndex: tmp1,
                            rental_price: i_rental_price, // fix here
                            Tentant:null_address,
                            status:  RentalStatus.OPEN
                        }));
            counter=counter+1;
                    
        }


        function getHouseID(address i_LandLord) public view returns(string  memory o_HouseID) 
        {   
            string memory tmp2=toAsciiString(i_LandLord);
            return string( abi.encodePacked(tmp2,"  :: ",HouseIndex_List[i_LandLord]) );         
        }

        function getHousePrice(uint i_index_value) public view returns(uint  o_rental_price) 
        {
            return Rental_House_List[i_index_value].rental_price;
        }

        function getHouseStatus(uint i_index_value) public view returns(string memory  o_rental_status) 
        {
               if (RentalStatus.OPEN  == Rental_House_List[i_index_value].status) return "OPEN";
               if (RentalStatus.CLOSED == Rental_House_List[i_index_value].status) return "CLOSED";
            
        }

        function getRental_House_List() public view returns( House[] memory o_Rental_House_List )
        {
            return Rental_House_List;
        }


        
        function giveOffer(uint i_index_value) public payable 
        {
            require(msg.value>=Rental_House_List[i_index_value].rental_price, "Not Enough Bid");
            Rental_House_List[i_index_value].rental_price=msg.value;
            Rental_House_List[i_index_value].Tentant=msg.sender;
            Rental_House_List[i_index_value].status=RentalStatus.CLOSED;
            addBalance();
            address payable tmp1=payable( Rental_House_List[i_index_value].LandLord );
            uint tmp2=Rental_House_List[i_index_value].rental_price;
            sendViaCall(tmp1,tmp2);
        }


        
        //Empty function, funds will be stored in contract.
        function addBalance() public payable 
        {

        }


        function sendViaCall(address payable _to,uint i_rental_price) public payable 
        {
                // Call returns a boolean value indicating success or failure.
                // This is the current recommended method to use.
                (bool sent, bytes memory data) = _to.call{value: i_rental_price}("");
                require(sent, "Failed to send Ether");
        }


        function getContract() view public returns(address)
        {
            return address(this);
        }


        function getContractBalance() view public returns(uint)
        {
            return address(this).balance;
        }


        function getSenderAccount() view private returns(address)
        {
        // return owner;//msg.sender;
        }
        
        /*function getSenderBalance() private payable returns(uint)
        {
            //return msg.value;
        }*/

        //** used to convert address to string
        function toAsciiString(address x) internal pure returns (string memory) {
            bytes memory s = new bytes(40);
            for (uint i = 0; i < 20; i++) {
                bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
                bytes1 hi = bytes1(uint8(b) / 16);
                bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
                s[2*i] = char(hi);
                s[2*i+1] = char(lo);            
            }
            return string(s);
        }

        function char(bytes1 b) internal pure returns (bytes1 c) {
            if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
            else return bytes1(uint8(b) + 0x57);
        }
        //**
}