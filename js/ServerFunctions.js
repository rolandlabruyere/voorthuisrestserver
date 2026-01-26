
function TServerMethods1(connectionInfo)
{
  this.executor = new ServerFunctionExecutor("TServerMethods1",connectionInfo);

  /*
   * @param Value [in] - Type on server: string
   * @return result - Type on server: string
   */
  this.RestDispatcher = function(Value) {
    var returnObject = this.executor.executeMethod("RestDispatcher", "GET", [Value], arguments[1], true, arguments[2], arguments[3]);
    if (arguments[1] == null) {
      if (returnObject != null && returnObject.result != null && isArray(returnObject.result)) {
        var resultArray = returnObject.result;
        var resultObject = new Object();
        resultObject.Value = Value;
        resultObject.result = resultArray[0];
        return resultObject;
      }
      return returnObject;
    }
  };

  this.RestDispatcher_URL = function(Value) {
    return this.executor.getMethodURL("RestDispatcher", "GET", [Value], arguments[1])[0];
  };
}

var JSProxyClassList = {
  "DSAdmin": ["GetPlatformName","ClearResources","FindPackages","FindClasses","FindMethods","CreateServerClasses","DropServerClasses","CreateServerMethods","DropServerMethods","GetServerClasses","ListClasses","DescribeClass","ListMethods","DescribeMethod","GetServerMethods","GetServerMethodParameters","GetDatabaseConnectionProperties","GetDSServerName","ConsumeClientChannel","ConsumeClientChannelTimeout","CloseClientChannel","RegisterClientCallbackServer","UnregisterClientCallback","BroadcastToChannel","BroadcastObjectToChannel","NotifyCallback","NotifyObject"],
  "TServerMethods1": ["EchoString","RestDispatcher"]
};

