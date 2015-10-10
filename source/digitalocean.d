module kprop.api.digitalocean.digitalocean;
import std.stdio;
import std.json;
import std.net.curl;
import std.exception:Exception,enforce,assumeUnique;
import std.conv:to;
import std.algorithm:countUntil,map,each;
import std.traits:EnumMembers;
import std.array:array,appender;
import std.format:format;
import std.variant:Algebraic;
import kprop.api.digitalocean.auth; // replace by your own key
import kprop.helper.prettyjson;

/**
    Implemented in the D Programming Language 2015 by Laeeth Isharc and Kaleidic Associates
    Boost Licensed
    Use at your own risk - this is not tested at all and if you end up deleting all your
    instances and creating 10,000 pricey new ones then it will not be my fault
*/

static this()
{
    OceanRegions=[EnumMembers!OceanRegion].map!(a=>a.toString).array.assumeUnique;
    DropletActions=[EnumMembers!DropletAction].map!(a=>a.toString).array.assumeUnique;
    OceanImages=
    [
        OceanGlobalImage(false,"CoreOS-766.4.0-(beta)",13578467,OceanDistro.CoreOS,""),
        OceanGlobalImage(false,"CentOS-5.10-x64",6372321,OceanDistro.CentOS,""),
        OceanGlobalImage(false,"5.10 x32",6372425, OceanDistro.CentOS),
        OceanGlobalImage(false,"6.0 x64",6372581, OceanDistro.Debian),
        OceanGlobalImage(false,"6.0 x32",6372662, OceanDistro.Debian),
        OceanGlobalImage(false,"21 x64",9640922, OceanDistro.Fedora),
        OceanGlobalImage(false,"10.1",10144573, OceanDistro.FreeBSD),
        OceanGlobalImage(false,"12.04.5 x64",10321756, OceanDistro.Ubuntu),
        OceanGlobalImage(false,"12.04.5 x32",10321777, OceanDistro.Ubuntu),
        OceanGlobalImage(false,"7.0 x64",10322059, OceanDistro.Debian),
        OceanGlobalImage(false,"7.0 x32",10322378, OceanDistro.Debian),
        OceanGlobalImage(false,"7 x64",10322623, OceanDistro.CentOS),
        OceanGlobalImage(false,"22 x64",12065782, OceanDistro.Fedora),
        OceanGlobalImage(false,"15.04 x64",12658446, OceanDistro.Ubuntu),
        OceanGlobalImage(false,"15.04 x32",12660649, OceanDistro.Ubuntu),
        OceanGlobalImage(false,"8.1 x64",12778278, OceanDistro.Debian),
        OceanGlobalImage(false,"8.1 x32",12778337, OceanDistro.Debian),
        OceanGlobalImage(false,"14.04 x64",13089493, OceanDistro.Ubuntu),
        OceanGlobalImage(false,"14.04 x32",13089823, OceanDistro.Ubuntu),
        OceanGlobalImage(false,"6.7 x64",13090046, OceanDistro.CentOS),
        OceanGlobalImage(false,"6.7 x32",13090097, OceanDistro.CentOS),
        OceanGlobalImage(false,"10.2",13321858, OceanDistro.FreeBSD),
        OceanGlobalImage(false,"815.0.0 (alpha)",13683512, OceanDistro.CoreOS),
        OceanGlobalImage(false,"766.4.0 (stable)",13750582, OceanDistro.CoreOS),
        OceanGlobalImage(false,"FreeBSD AMP on 10.1",10163059, OceanDistro.FreeBSD),
        OceanGlobalImage(true,"Drone on 14.04",11774848, OceanDistro.Ubuntu,"Drone"),
        OceanGlobalImage(true,"Cassandra on 14.04",12540744, OceanDistro.Ubuntu,"Cassandra"),
        OceanGlobalImage(true,"ELK Logging Stack on 14.04",12542038, OceanDistro.Ubuntu,"ELK Logging"),
        OceanGlobalImage(true,"Django on 14.04",12740667, OceanDistro.Ubuntu,"Django"),
        OceanGlobalImage(true,"Mumble Server (murmur) on 14.04",12914152, OceanDistro.Ubuntu,"murmur"),
        OceanGlobalImage(true,"Joomla! 3.4.3 on 14.04",13014869, OceanDistro.Ubuntu,"Joomla"),
        OceanGlobalImage(true,"Magento-1.9.2.1 CE on 14.04",13115155, OceanDistro.Ubuntu,"Magento"),
        OceanGlobalImage(true,"MongoDB 3.0.5 on 14.04",13115659, OceanDistro.Ubuntu,"MongoDB"),
        OceanGlobalImage(true,"LEMP on 14.04",13138234, OceanDistro.Ubuntu,"LEMP"),
        OceanGlobalImage(true,"LAMP on 14.04",13138235, OceanDistro.Ubuntu,"LAMP"),
        OceanGlobalImage(true,"MediaWiki on 14.04",13185409, OceanDistro.Ubuntu,"MediaWiki"),
        OceanGlobalImage(true,"WordPress on 14.04",13229890, OceanDistro.Ubuntu,"WordPress"),
        OceanGlobalImage(true,"Ruby on Rails on 14.04 (Postgres, Nginx, Unicorn)",13400199, OceanDistro.Ubuntu,"Ruby on Rails"),
        OceanGlobalImage(true,"MEAN on 14.04",13413549, OceanDistro.Ubuntu,"MEAN"),
        OceanGlobalImage(true,"Drupal 7.39 on 14.04",13414327, OceanDistro.Ubuntu,"Drupal"),
        OceanGlobalImage(true,"Docker 1.8.2 on 14.04",13495049, OceanDistro.Ubuntu,"Docker"),
        OceanGlobalImage(true,"node v4.1.0 on 14.04",13586846, OceanDistro.Ubuntu,"nodejs"),
        OceanGlobalImage(true,"Redis 3.0.4 on 14.04",13601457, OceanDistro.Ubuntu,"Redis"),
        OceanGlobalImage(true,"ownCloud 8.1.3 on 14.04",13603669, OceanDistro.Ubuntu,"ownCloud"),
        OceanGlobalImage(true,"GitLab 8.0.1 CE on 14.04",13670476, OceanDistro.Ubuntu,"GitLab"),
        OceanGlobalImage(true,"Ghost 0.7.1 on 14.04",13750431, OceanDistro.Ubuntu,"Ghost"),
        OceanGlobalImage(true,"Dokku v0.4.1 on 14.04",13750783, OceanDistro.Ubuntu,"Dokku"),
        OceanGlobalImage(true,"Discourse on 14.04",13846109, OceanDistro.Ubuntu,"Discourse"),
        OceanGlobalImage(true,"PHPMyAdmin on 14.04",11730661, OceanDistro.Ubuntu,"PHPMyAdmin"),
        OceanGlobalImage(true,"Redmine on 14.04",12438838, OceanDistro.Ubuntu,"Redmine"),
    ];
}

string joinUrl(string url, string endpoint)
{
    enforce(url.length>0, "broken url");
    if (url[$-1]=='/')
        url=url[0..$-1];
    return url~"/"~endpoint;
}
/**
    auto __str__(self):
        return b"<{:s} at {:#x}>".format(type(self).__name__, id(self))

    auto __unicode__(self):
        return "<{:s} at {:#x}>".format(type(self).__name__, id(self))
*/

struct OceanAPI
{
    string endpoint = "https://api.digitalocean.com/v2/";
    string token;

    this(string token)
    {
        this.token=token;
    }
    this(string endpoint, string token)
    {
        this.endpoint=endpoint;
        this.token=token;
    }
}

JSONValue request(OceanAPI api, string url, HTTP.Method method=HTTP.Method.get, JSONValue params=JSONValue(null))
{
    enforce(api.token.length>0,"no token provided");
    url=api.endpoint.joinUrl(url);
    auto client=HTTP(url);
    client.addRequestHeader("Authorization", "Bearer "~api.token);
    auto response=appender!(ubyte[]);
    client.method=method;
    switch(method) with(HTTP.Method)
    {
        case del:
            client.setPostData(cast(void[])params.toString,"application/x-www-form-urlencoded");
            break;
        case get,head:
            client.setPostData(cast(void[])params.toString,"application/json");
            break;
        default:
            client.setPostData(cast(void[])params.toString,"application/json");
            break;
    }
    client.onReceive = (ubyte[] data)
    {
        response.put(data);
        return data.length;
    };
    client.perform();                 // rely on curl to throw exceptions on 204, >=500
    return parseJSON(cast(string)response.data);
}


// List all Actions
auto listActions(OceanAPI api)
{
    return api.request("actions",HTTP.Method.get);
}

// retrieve existing Action
auto retrieveAction(OceanAPI api, string id)
{
    return api.request("actions/"~id, HTTP.Method.get);
}

auto allNeighbours(OceanAPI api)
{
    return api.request("reports/droplet_neighbors",HTTP.Method.get);
}

auto listUpgrades(OceanAPI api)
{
    return api.request("droplet_upgrades",HTTP.Method.get);    
}

// List all Domains (managed through Ocean DNS interface)
auto listDomains(OceanAPI api)
{
    return api.request("domains", HTTP.Method.get);
}

struct OceanDomain
{
    OceanAPI api;
    string id;
    alias id this;
    this(OceanAPI api, string id)
    {
        this.api=api;
        this.id=id;
    }
    // Create new Domain
    static auto create(OceanAPI api, string name, string ip)
    {
        JSONValue params;
        params["name"]=name;
        params["ip_address"]=ip;
        return api.request("domains", HTTP.Method.post, params);
    }
    auto request(string url, HTTP.Method method=HTTP.Method.get, JSONValue params=JSONValue(null))
    {
        return api.request(url,method,params);
    }
}

// Retrieve an existing Domain
auto get(OceanDomain domain)
{
    return domain.request("domains/"~domain.id, HTTP.Method.get);
}

 // Delete a Domain
auto del(OceanDomain domain)
{
    return domain.request("domains/"~domain.id, HTTP.Method.del);
}

//  List all Domain Records
auto listDomainRecords(OceanDomain domain)
{
    return domain.request(format("domains/%s/records",domain.id), HTTP.Method.get);
}

//  Create a new Domain Record
auto createRecord(OceanDomain domain, string rtype=null, string name=null, string data=null,
                         string priority=null, string port=null, string weight=null)
{
    JSONValue params;
    params["type"]=rtype;
    if(name.length>0)
        params["name"]=name;
    if(data.length>0)
        params["data"]=data;
    if(priority.length>0)
        params["priority"]=priority;
    if(port.length>0)
        params["port"]=port;
    if(weight.length>0)
        params["weight"]=weight;
    return domain.request(
        format("domains/%s/records",domain.id), HTTP.Method.post, params);
}

//  Retrieve an existing Domain Record
auto getRecord(OceanDomain domain, string recordId)
{
    return domain.request(
        format("domains/%s/records/%s",domain.id,recordId), HTTP.Method.get);
}

//  Delete a Domain Record
auto delRecord(OceanDomain domain, string recordId)
{
    return domain.request(
        format("domains/%s/records/%s",domain.id,recordId), HTTP.Method.del);
}

//  Update a Domain Record
auto updateRecord(OceanDomain domain, string recordId,string name)
{
    JSONValue params;
    params["name"] = name;
    return domain.request(format("domains/%s/records/%s",domain.id, recordId), HTTP.Method.put, params);
}


// list all droplets
auto listDroplets(OceanAPI api)
{
    return api.request("droplets",HTTP.Method.get);
}

enum OceanRegion
{
    ams2,
    ams3,
    fra1,
    lon1,
    nyc1,
    nyc2,
    nyc3,
    sfo1,
    sgp1,
    tor1,
}


immutable string[] OceanRegions;
OceanRegion oceanRegion(string region)
{
    OceanRegion ret;
    auto i=OceanRegions.countUntil(region);
    enforce(i>=0, new Exception("unknown droplet region: "~region));
    return cast(OceanRegion)i;
}

string toString(OceanRegion region)
{
    final switch(region) with(OceanRegion)
    {
        case ams2:
            return "Amsterdam 2";
        case ams3:
            return "Amsterdam 3";
        case fra1:
            return "Frankfurt 1";
        case lon1:
            return "London 1";
        case nyc1:
            return "New York 1";
        case nyc2:
            return "New York 2";
        case nyc3:
            return "New York 3";
        case sfo1:
            return "San Francisco 1";
        case sgp1:
            return "Singapore 1";
        case tor1:
            return "Toronto 1";
    }
    assert(0);
}

enum OceanDistro
{
    CoreOS,
    Debian,
    Fedora,
    CentOS,
    FreeBSD,
    Ubuntu,
}
alias OceanImageId=Algebraic!(int,string);
struct OceanGlobalImage
{
    bool isApplication=false;
    string slug;
    int id;
    OceanDistro distro;
    string application;
}
OceanGlobalImage[] OceanImages;


struct Droplet
{
    OceanAPI api;
    int id;

    this(OceanAPI api, int id)
    {
        this.api=api;
        this.id=id;
    }

    string toString()
    {
        return id.to!string;
    }
    auto request(string uri, HTTP.Method method=HTTP.Method.get, JSONValue params=JSONValue(null))
    {
        return api.request(uri,method,params);
    }

    //  Create a new Droplet
    static auto create(OceanAPI api,string name, OceanRegion region, string size, OceanImageId image, string[] sshKeys, string backups=null,
               string ipv6=null, string privateNetworking=null, string userData=null)
    {
        JSONValue params;
        params["name"]=name;
        params["region"]=region.to!string;
        params["size"]=size;
        if(image.type==typeid(string))
            params["image"]=image.get!string;
        else
            params["image"]=image.get!int;
        if (sshKeys.length>0)
            params["ssh_keys"]=sshKeys;
        if(backups.length>0)
            params["backups"]=backups.to!bool;
        if (ipv6.length>0)
            params["ipv6"]=ipv6.to!bool;
        if (privateNetworking.length>0)
            params["private_networking"]=privateNetworking.to!bool;
        if (userData.length>0)
            params["user_data"]=userData;
        return api.request("droplets", HTTP.Method.post, params);
    }
}

//  Makes an action
JSONValue action(Droplet droplet, DropletAction actionType,JSONValue params=JSONValue(null))
{
    params["type"]=actionType.toString;
    return droplet.request(format("droplets/%s/actions",droplet.id), HTTP.Method.post, params);
}

enum DropletAction
{
    reboot,
    powerCycle,
    shutdown,
    powerOff,
    powerOn,
    passwordReset,
    resize,
    restore,
    rebuild,
    rename,
    changeKernel,
    enableIPv6,
    disableBackups,
    enablePrivateNetworking,
    snapshot,
    upgrade,
}

string toString(DropletAction action)
{
    final switch(action) with(DropletAction)
    {
        case reboot:
            return "reboot";
        case powerCycle:
            return "power_cycle";
        case shutdown:
            return "shutdown";
        case powerOff:
            return "power_off";
        case powerOn:
            return "power_on";
        case passwordReset:
            return "password_reset";
        case resize:
            return "resize";
        case restore:
            return "restore";
        case rebuild:
            return "rebuild";
        case rename:
            return "rename";
        case changeKernel:
            return "change_kernel";
        case enableIPv6:
            return "enable_ipv6";
        case disableBackups:
            return "disable_backups";
        case enablePrivateNetworking:
            return "enable_private_networking";
        case snapshot:
            return "snapshot";
        case upgrade:
            return "upgrade";
    }
}


immutable string[] DropletActions;
DropletAction dropletAction(string action)
{
    auto i=DropletActions.countUntil(action);
    enforce(i>=0,new Exception("unknown droplet action: "~action));
    return cast(DropletAction)i;
}

struct OceanResult(T)
{
    bool found;
    T result;
}
// find droplet ID from anme
OceanResult!Droplet findDroplet(OceanAPI ocean, string name)
{
    auto ret=ocean.Droplet(-1);
    auto dropletResults=ocean.listDroplets;
    auto droplets="droplets" in dropletResults;
    enforce(droplets !is null, new Exception("bad response from Digital Ocean: "~dropletResults.prettyPrint));
    enforce((*droplets).type==JSON_TYPE.ARRAY, new Exception
        ("bad response from Digital Ocean: "~dropletResults.prettyPrint));
    (*droplets).array.each!(a=>enforce(("name" in a.object) && a.object["name"].type==JSON_TYPE.STRING));
    auto i=(*droplets).array.map!(a=>a.object["name"].str).array.countUntil(name);
    if (i==-1)
    {
        return OceanResult!Droplet(false,ret);
    }
    //auto p=("id" in ((*droplets).array[i]));
    //enforce(p !is null, new Exception
      //  ("findDroplet cannot find id in results - malformed JSON?\n"~dropletResults.prettyPrint));
    return OceanResult!Droplet(true,ocean.Droplet((*droplets).array[i].object["id"].integer.to!int));
}

//  List all available Kernels for a Droplet
auto kernels(Droplet droplet)
{
    return droplet.request(format("droplets/%s/kernels",droplet.id), HTTP.Method.get);
}


//  Retrieve snapshots for a Droplet
auto snapshots(Droplet droplet)
{
    return droplet.request(format("droplets/%s/snapshots",droplet.id), HTTP.Method.get);
}

//  Retrieve backups for a Droplet
auto backups(Droplet droplet)
{
  return droplet.request(format("droplets/%s/backups",droplet.id), HTTP.Method.get);
}

//  Retrieve actions for a Droplet
auto actions(Droplet droplet)
{
    return droplet.request(format("droplets/%s/actions",droplet.id), HTTP.Method.get);
}

//  Retrieve an existing Droplet by id
auto retrieve(Droplet droplet)
{
    return droplet.request("droplets/"~droplet.id.to!string, HTTP.Method.get);
}

//  Delete a Droplet
auto del(Droplet droplet)
{
    return droplet.request("droplets/"~droplet.id.to!string, HTTP.Method.del);
}

auto neighbours(Droplet droplet)
{
    return droplet.request(format("droplets/%s/neighbors",droplet.id),HTTP.Method.get);
}

//  Reboot a Droplet
auto reboot(Droplet droplet)
{
    return droplet.action(DropletAction.reboot);
}

//  Power Cycle a Droplet
auto powerCycle(Droplet droplet)
{
    return droplet.action(DropletAction.powerCycle);
}

//  Shutdown a Droplet
auto shutdown(Droplet droplet)
{
    return droplet.action(DropletAction.shutdown);
}

//  Power Off a Droplet
auto powerOff(Droplet droplet)
{
    return droplet.action(DropletAction.powerOff);
}

//  Power On a Droplet
auto powerOn(Droplet droplet)
{
    return droplet.action(DropletAction.powerOn);
}

//  Password Reset a Droplet
auto passwordReset(Droplet droplet)
{
    return droplet.action(DropletAction.passwordReset);
}

//  Resize a Droplet
auto resize(Droplet droplet, string size)
{
    JSONValue params;
    params["size"]=size;
    return droplet.action(DropletAction.resize, params);
}

//  Restore a Droplet
auto restore(Droplet droplet, string image)
{
    JSONValue params;
    params["image"]=image;
    return droplet.action(DropletAction.restore, params);
}

//  Rebuild a Droplet
auto rebuild(Droplet droplet, string image)
{
    JSONValue params;
    params["image"]=image;
    return droplet.action(DropletAction.rebuild, params);
}

//  Rename a Droplet
auto rename(OceanAPI api, Droplet droplet, string name)
{
    JSONValue params;
    params["name"]=name;
    return droplet.action(DropletAction.rename,params);
}

//  Change the Kernel
auto changeKernel(Droplet droplet, string kernel)
{
    JSONValue params;
    params["kernel"]=kernel;
    return droplet.action(DropletAction.changeKernel, params);
}

//  Enable IPv6
auto enableIPv6(Droplet droplet)
{
    return droplet.action(DropletAction.enableIPv6);
}

//  Disable Backups
auto disableBackups(Droplet droplet)
{
    return droplet.action(DropletAction.disableBackups);
}

//  Enable Private Networking
auto enablePrivateNetworking(Droplet droplet)
{
    return droplet.action(DropletAction.enablePrivateNetworking);
}

//  Snapshot
auto doSnapshot(Droplet droplet, string name=null)
{
    JSONValue params;
    if (name.length>0)
        params["name"]=name;
    return droplet.action(DropletAction.snapshot, params);
}

//  Retrieve a Droplet Action
auto retrieveAction(Droplet droplet, string actionId)
{
    return droplet.request(
        format("droplets/%s/actions/%s",droplet.id, actionId), HTTP.Method.get);
}

auto upgrade(Droplet droplet)
{
    JSONValue params;
    params["upgrade"]=true;
    droplet.action(DropletAction.upgrade,params);
}
struct OceanImage
{
    OceanAPI api;
    string id;
    alias id this;
    this(OceanAPI api, string id)
    {
        this.api=api;
        this.id=id;
    }
    auto request(string uri, HTTP.Method method=HTTP.Method.get, JSONValue params=JSONValue(null))
    {
        return api.request(uri,method,params);
    }
}
// List all images
auto listImages(OceanAPI api)
{
    return api.request("images", HTTP.Method.get);
}

// Retrieve an existing Image by id or slug
auto get(OceanImage image)
{
    return image.request("images/"~image.id, HTTP.Method.get);
}

//  Delete an Image
auto del(OceanImage image)
{
    return image.request("images/"~image.id, HTTP.Method.del);
}

//  Update an Image
auto update(OceanImage image, string name)
{
    JSONValue params;
    params["name"]=name;
    return image.request("images/"~image.id, HTTP.Method.put, params);
}

//  Transfer an Image
auto transfer(OceanImage image, OceanRegion region)
{
    JSONValue params;
    params["type"]="transfer";
    params["region"]=region.to!string;
    return image.request(format("images/%s/actions",image.id), HTTP.Method.post,params);
}

 // Retrieve an existing Image Action

auto getImageAction(OceanImage image, string actionId)
{
    return image.request(format("images/%s/actions/%s",image.id,actionId), HTTP.Method.get);
}

struct OceanKey
{
    OceanAPI api;
    string value;

    this(OceanAPI api,string key)
    {
        this.api=api;
        this.value=key;
    }
    auto request(string uri, HTTP.Method method=HTTP.Method.get, JSONValue params=JSONValue(null))
    {
        return api.request(uri,method,params);
    }

    // Create a new Key
    static auto create(OceanAPI api, string name, string publicKey)
    {
        JSONValue params;
        params["name"]=name;
        params["public_key"]=publicKey;
        return api.request("account/keys", HTTP.Method.post, params);
    }
}

// list all keys
auto listKeys(OceanAPI api)
{
    return api.request("account/keys", HTTP.Method.get);
}


// Retrieve an existing Key by Id or Fingerprint

auto retrieve(OceanKey key)
{
    return key.request("account/keys/"~key.value, HTTP.Method.get);
}

//  Update an existing Key by Id or Fingerprint
auto updateName(OceanKey key, string name)
{
    JSONValue params;
    params["name"]=name;
    return key.request("account/keys/"~key.value, HTTP.Method.put, params);
}

//  Destroy an existing Key by Id or Fingerprint
auto del(OceanKey key)
{
    return key.request("account/keys/"~key.value, HTTP.Method.del);
}


// list all regions
auto listRegions(OceanAPI api)
{
   return api.request("regions", HTTP.Method.get);
}

// list all sizes
auto listSizes(OceanAPI api)
{
    return api.request("sizes", HTTP.Method.get);
}
