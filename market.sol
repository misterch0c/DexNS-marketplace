pragma solidity ^0.4.11;

contract marketfinal {
    address DexNS_Storage_addr = 0x4A74DdaEdaaf2a277E0F4cc56D31A69022A8fCC5;
    address DexNS_Frontend_addr = DexNS_Storage(DexNS_Storage_addr).frontend_contract();
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

    
    function  registerNameProxy(string _name) payable returns (bool ok){
            return dxns.registerName(_name);
    }

    function onNameOwnerChanged(string _name, address _sender){
        if(checkValidity(_name)){
            selling[_name]=Selling(msg.sender,0,false);
            //also changes the destination of the name
            dxns.updateName(_name,address(this));
        }
    }
    
    function approveSell(string _name, uint256 _price) returns (bool ok){
        if ((dxns.ownerOf(_name)==address(this)) && (dxns.addressOf(_name)==address(this))){
            selling[_name].approved=true;
            selling[_name].price=_price;
            return true;
        }
    }
    
    function buyName(string _name) payable returns (bool ok){
        //Check if name is to name, if price is ok & sell is approved
        if ((selling[_namen].addr != 0) && (selling[_name].approved) && (selling[_namen].price <= msg.value) && checkValidity(n)){
                //Change ownership & destination to msg.sender
                dxns.updateName(_name,msg.sender);
                dxns.changeNameOwner(_name,msg.sender);
                //Send money to previous owner
                selling[_name].addr.transfer(msg.value);
                //Delete struct
                delete selling[_name];
                return true;
            }
        
    }

    //Check validity of a name
    function checkValidity(string _name) constant returns (bool ok){
        return dxns.endTimeOf(n) < now;
    }
    
    function getPrice(string _name)  returns (uint256 price){
        if(selling[_name].approved){
            return (selling[_name].price);
        }
        return 0;
    }

}

contract DexNS_Frontend
{
    function registerName(string) returns (bool) { }
    function changeNameOwner(string, address) { }
    function updateName(string, address) { }
    function ownerOf(string) returns (address) { }
    function addressOf(string) returns (address) { }
    function endTimeOf(string) returns (uint) { }
}
contract DexNS_Storage
{
    

}

