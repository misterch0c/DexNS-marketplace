pragma solidity ^0.4.11;

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

    
    function  registerNameProxy(string myName) payable returns (bool ok){
            return dxns.registerName(myName);
    }
    
    //Initiate selling
    function sellName(string n, uint256 sellPrice) constant returns (bool ok){
        address supposedOwner = msg.sender;

        //if the caller is the owner of the name
        if(dxnss.ownerOf(n)==supposedOwner)
        {
            //add to mapping
            selling[n]=Selling(msg.sender,sellPrice,false);
            return true;
        }else{
           return false;
        }
    }
    
    //Verify that previous owner changed the ownership of the name for this contract
    function approveSell(string n) constant returns (bool ok){
        if ((dnxss.ownerOf(n)==this.address) && (dxns.addressOf(n)==this.address)){
            selling[n].approved=true;
            return true;
        }
        
    }
    
    function buyName(string n){
        //Check if name is to name, if price is ok & sell is approved
        if ((selling[n].addr != 0) && (selling[n].approved) && (selling[n].price <= msg.value)){
                //Change ownership & destination to msg.sender
                dxns.updateName(n,msg.sender);
                dxns.changeNameOwner(n,msg.sender);
                //Send money to previous owner
                selling[n].addr.transfer(msg.value);
                //Delete struct
                delete selling[n];
            }
        
    }

    //Check validity of a name
    function checkValidity(string n){
        dxns.endTimeOf(n);
    }
    
    function getSelling() constant returns (address a,  uint256 p){
        return (myStruct.addr,  myStruct.price);
    }
    
    function getPrice(string n)  returns (uint256 p){
        if(selling[n].approved){
            return (selling[n].price);
        }
        return 0;
    }

}

contract DexNS_Frontend
{
    function registerName(string) returns (bool) { }
    function changeNameOwner(string, address) { }
    function updateName(string, address) { }
}
contract DexNS_Storage
{
    function ownerOf(string) returns (address) { }

}

