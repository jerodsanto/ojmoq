#!/usr/bin/env narwhal

var FILE = require("file"),
    ENV = require("system").env,
    OS = require("os"),
    jake = require("jake");
	
require(FILE.absolute("common.jake"));

task ("test", function()
{
    var tests = new FileList('tests/*Test.j');
    var cmd = ["ojtest"].concat(tests.items());
    var cmdString = cmd.map(OS.enquote).join(" ");
    
    var code = OS.system(cmdString);
    if (code !== 0)
        OS.exit(code);
});
