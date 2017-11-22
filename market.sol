pragma solidity ^0.4.8;

contract marketfinal {
    address DexNS_Frontend_addr = 0x4c3032756d5884D4cAeb2F1eba52cDb79235C2CA;
    address DexNS_Storage_addr = 0x4A74DdaEdaaf2a277E0F4cc56D31A69022A8fCC5;
    DexNS_Storage dxnss = DexNS_Storage(DexNS_Storage_addr);
    DexNS_Frontend dxns = DexNS_Frontend(DexNS_Frontend_addr);

    struct Selling {
        address addr;
        uint256 price;
        bool approved;
    }

    event logString(Selling);

    mapping(string => Selling) selling;
    Selling public myStruct;


    function  registerNameProxy(string myName) public payable returns (bool ok){
            return dxns.registerName(myName);
    }
    
    //Initiate selling
    function sellName(string n, uint256 sellPrice) public payable returns (bool ok){
        address supposedOwner = msg.sender;

        //if the caller is the owner of the name
        if(dxns.ownerOf(n)==supposedOwner && checkValidity(n))
        {
            //add to mapping
            selling[n]=Selling(msg.sender,sellPrice,false);
            return true;
        }else{
           return false;
        }
    }

    //Verify that previous owner changed the ownership of the name for this contract
    function approveSell(string n) public returns (bool ok){
        if ((dxns.ownerOf(n)==address(this)) && (dxns.addressOf(n)==address(this))){
            selling[n].approved=true;
            return true;
        }
    }

    function buyName(string n) public payable returns (bool ok){
        //Check if name is to name, if price is ok & sell is approved
        if ((selling[n].addr != 0) && (selling[n].approved) && (selling[n].price <= msg.value) && checkValidity(n)){
                //Change ownership & destination to msg.sender
                dxns.updateName(n,msg.sender);
                dxns.changeNameOwner(n,msg.sender);
                //Send money to previous owner
                selling[n].addr.transfer(msg.value);
                //Delete struct
                delete selling[n];
                return true;
            }

    }

    //Check validity of a name
    function checkValidity(string n) public view returns (bool ok){
        return dxns.endTimeOf(n) < now;
    }

    function getPrice(string n) public view returns (uint256 p) {
        if(selling[n].approved){
            return (selling[n].price);
        }
        return 0;
    }

}

contract DexNS_Frontend
{
    function registerName(string) public pure returns (bool) { }
    function changeNameOwner(string, address) public pure { }
    function updateName(string, address) public pure { }
    function ownerOf(string) public pure returns (address) { }
    function addressOf(string) public pure returns (address) { }
    function endTimeOf(string) public pure returns (uint) { }
}
contract DexNS_Storage
{


}
