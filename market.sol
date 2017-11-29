pragma solidity ^0.4.11;


contract NameReceiver {
    address DexNS_Storage_addr = 0x3d0e09b25b1f13A443D4ddEDd79F6f4343CC8A25;
    DexNS_Storage dxnss = DexNS_Storage(DexNS_Storage_addr);
    
    address DexNS_Frontend_addr = dxnss.frontend_contract();
    DexNS_Frontend dxns = DexNS_Frontend(DexNS_Frontend_addr);
    
    struct Selling {
        address addr;
        uint256 price;
        bool approved;
    }

    event logString(Selling);
    address public owner;
    mapping(string => Selling) selling;
    Selling public myStruct;
    


    modifier only_owner
    {
        if ( msg.sender != owner )
            revert();
        _;
    }

    modifier only_name_owner(string _name)
    {
        if ( msg.sender != dxns.ownerOf(_name) )
            revert();
        _;
    }

    function getStruct(string _name) constant returns (address addr){
        return selling[_name].addr;
    }
    
    function registerName(string _name) payable returns (bool ok){
            return dxns.registerName(_name);
    }

    function onNameOwnerChanged(string _name, address _sender, bytes _data){
        if(checkValidity(_name)){
            //add to the struct
            selling[_name]=Selling(_sender,0,false);
            //also change destination for this contract
            dxns.updateName(_name, address(this));
            //add metadata
            if(_data.length > 0) {
                 this.call.value(0)(_data);
            }
        }

    }
    
    function approveSell(string _name, uint256 _price) returns (bool ok){
        if ((selling[_name].addr==msg.sender) && (!selling[_name].approved)) {
            selling[_name].approved=true;
            //store price in wei
            selling[_name].price=_price * 1000000000000000000;
            return true;
        }else{
            return false;
        }
    }

    function changePrice(string _name, uint256 _price){

    }
    
    function buyName(string _name, bytes _data) payable returns (bool ok){
        // if ((selling[_name].addr != 0) && (selling[_name].approved) && (selling[_name].price <= msg.value) && (checkValidity(_name))){
                //Change ownership & destination to msg.sender
                if ((selling[_name].price <= msg.value) && (checkValidity(_name)) && (selling[_name].approved) ){
                dxns.updateName(_name, msg.sender);
                dxns.changeNameOwner(_name, msg.sender, _data);
                //Send money to previous owner
                selling[_name].addr.transfer(msg.value);
                // //Delete struct
                delete selling[_name];
                return true;
             }
        else{
            return false;
        }
        
    }

    //Check validity of a name
    function checkValidity(string _name) constant returns (bool valid){
        return dxns.endtimeOf(_name) > now;
    }
    
    function getPrice(string _name) constant returns (uint256 price){
        if(selling[_name].approved){
            //return ether price
            return (selling[_name].price / 1000000000000000000) ;
        }else{
            return 0;
        }
        
    }

    //Seller changed his mind and wants his name back
    function revertSell(string _name, bytes _data) only_name_owner(_name) {
        if ((selling[_name].addr == msg.sender) && (selling[_name].approved) && checkValidity(_name)){
            dxns.updateName(_name,selling[_name].addr);
            dxns.changeNameOwner(_name,selling[_name].addr, _data);
        }
    }

    function change_Owner(address _newOwner) only_owner
    {
        owner = _newOwner;
    }

    function dispose() only_owner
    {
        selfdestruct(owner);
    }
}

contract DexNS_Frontend
{
    function registerName(string) returns (bool) { }
    function changeNameOwner(string, address, bytes) { }
    function updateName(string, address) { }
    function ownerOf(string) returns (address) { }
    function addressOf(string) returns (address) { }
    function endtimeOf(string) returns (uint) { }
}
contract DexNS_Storage
{
    function frontend_contract() returns (address){}

}

