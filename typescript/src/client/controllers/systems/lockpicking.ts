/*
 just an simple insperation
 needs sum work btw to ur core or ur ui or just use np-ui send message..
*/

var checked = false;

export function DoorLockCheck() {
    if (checked == true) {
        exports['np-ui'].SetUIFocus(true, true);
        console.log("Door Opened.");
        exports['np-ui'].SetUIFocus(false, false);
    }
    else
    {
        console.log("Door Locked.");
        //todo ui showing
    }
}