import kprop.api.digitalocean.digitalocean;
import kprop.helper.prettyjson;
import kprop.api.digitalocean.auth;
import std.stdio;

void main(string[] args)
{
    auto ocean=OceanAPI(OceanAPIKey);
    auto actions=ocean.listDroplets;
    writefln(actions.prettyPrint);
    auto droplet=ocean.findDroplet("hoelderlin.kaleidicassociates.com").result.retrieve;
    writefln(droplet.prettyPrint);
    auto keys=ocean.listKeys;
    writefln(keys.prettyPrint);
}
