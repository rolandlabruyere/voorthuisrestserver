function formatIp(myIp){
	const ipParts = myIp.split(".");
	for(let i = 0; i < ipParts.length; i++){
	  switch (ipParts[i].length){
	  case 1: ipParts[i] = "00" + ipParts[i]; break;
	  case 2: ipParts[i] = "0" + ipParts[i]; break;
	  default: ipParts[i];
	  }
	}
	return ipParts[0] + "." + ipParts[1] + "." + ipParts[2] + "." + ipParts[3]
}
