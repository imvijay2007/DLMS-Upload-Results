var request = require('request');
var async = require('async');
var url = 'http://localhost:6009/v1/results';

var accessToken = 'bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI5MTU2MTBkNC01ZTFhLTQ4MzctOGFlZi01YzQ0N2Y4NGEzYzIiLCJzdWIiOiI0MjcxMTA1ZS00OWJjLTRkN2QtYThkMS0zNjRhYzk1OTVkOGMiLCJzY29wZSI6WyJjbG91ZF9jb250cm9sbGVyLnJlYWQiLCJwYXNzd29yZC53cml0ZSIsImNsb3VkX2NvbnRyb2xsZXIud3JpdGUiLCJvcGVuaWQiXSwiY2xpZW50X2lkIjoiY2YiLCJjaWQiOiJjZiIsImF6cCI6ImNmIiwiZ3JhbnRfdHlwZSI6InBhc3N3b3JkIiwidXNlcl9pZCI6IjQyNzExMDVlLTQ5YmMtNGQ3ZC1hOGQxLTM2NGFjOTU5NWQ4YyIsIm9yaWdpbiI6InVhYSIsInVzZXJfbmFtZSI6InZqZWdhc2VAdXMuaWJtLmNvbSIsImVtYWlsIjoidmplZ2FzZUB1cy5pYm0uY29tIiwicmV2X3NpZyI6ImUzZWVjZWY4IiwiaWF0IjoxNDc1ODA2NzA0LCJleHAiOjE0NzcwMTYzMDQsImlzcyI6Imh0dHBzOi8vdWFhLnN0YWdlMS5uZy5ibHVlbWl4Lm5ldC9vYXV0aC90b2tlbiIsInppZCI6InVhYSIsImF1ZCI6WyJjbG91ZF9jb250cm9sbGVyIiwicGFzc3dvcmQiLCJjZiIsIm9wZW5pZCJdfQ.dOZ0XZCYJmdZ8UHqf-a6-J23L68QZ2CaxwT9-QI_mdQ';

var d = new Date();
var isotime = d.toJSON();

var builds = [];
for(var i=0; i<15; i++){
    builds.push(i);
}

async.eachSeries(builds, function(a, callback) {
        // Code piece
        var total = Math.floor((Math.random() * 200) + 1);
        var pass = Math.floor((Math.random() * 150) + 1);
        while (pass > total) {
            pass = pass - total;
        }
        var fail = total - pass;
        var timetaken = Math.floor((Math.random() * 500) + 1);

        var mochacontents = {
            stats: {
                suites: 24,
                tests: total,
                passes: pass,
                pending: 0,
                failures: fail,
                start: "2016-09-29T14:49:17.877Z",
                end: "2016-09-29T14:49:17.983Z",
                duration: timetaken
            },
            tests: [],
            pending: [],
            failures: [],
            passes: []
        };
    
    var istanbulcontents = {
            total: {
                lines: {
                    pct: Math.floor((Math.random() * 100) + 1)
                },
                statements: {
                    pct: Math.floor((Math.random() * 100) + 1)
                },
                functions: {
                    pct: Math.floor((Math.random() * 100) + 1)
                }
            }
        };

        var buff = new Buffer(JSON.stringify(mochacontents));
        var base64mochacontents = buff.toString('base64');
    buff = new Buffer(JSON.stringify(istanbulcontents));
    var base64istanbulcontents = buff.toString('base64');

        var testresult = {};
        testresult.org_name = 'vjegase@us.ibm.com';
        testresult.project_name = 'Test-Insights-Tab';
        testresult.environment_name = 'MASTER-BUILD';
        testresult.runtime_name = 'Test-Insights-Tab';
        testresult.module_name = 'Test-Insights-Tab';
        testresult.build_id = 'Master:'+a;
        testresult.timestamp = isotime;
        testresult.lifecycle_stage = 'unittest';
        testresult.url = ['www.github.com', 'www.saucelabs.com', 'newrelic.org'];
        testresult.artifact_name = 'mochatest.json';
        testresult.description = 'Unit test using Mocha.';
        testresult.contents_type = 'application/json';
        testresult.contents = base64mochacontents;

        d.setDate(d.getDate() - 1);
        isotime = d.toJSON();

        request({
            method: 'POST',
            url: url,
            headers: {
                Authorization: 'bearer ' + accessToken
            },
            json: true,
            body: testresult,
            timeout: 30000
        }, function(err, resp, body) {
            if (err) {
                console.log("Process failed with error:", err);
                callback(err, null);
            } else {
                if (resp.statusCode === 200) {
                    console.log("MOCHA Post %s for build:",body.status,testresult.build_id);
                    testresult.lifecycle_stage = 'code';
                    testresult.artifact_name = 'istanbultest.json';
                    testresult.contents_type = 'application/json';
                    testresult.contents = base64istanbulcontents;
                    request({
                        method: 'POST',
                        url: url,
                        headers: {
                            Authorization: 'bearer ' + accessToken
                        },
                        json: true,
                        body: testresult,
                        timeout: 30000
                    },function(err, resp, body) {
                        if (err) {
                            console.log("Process failed with error:", err);
                            callback(err, null);
                        }
                        else {
                            console.log("ISTANBUL Post %s for build:",body.status,testresult.build_id);
                            console.log("---------------------------------------------");
                            callback(null, body.status);
                        }
                    });
                } else {
                    console.log("Process failed with error code:", resp.statusCode);
                    callback("Failed!", null);
                }
            }
        });

        // Code piece
    },
    function(error, response) {
        if (error) {
            console.log("Error:",error);
        } else {
            console.log("RESPONSE:",response);
        }

    });