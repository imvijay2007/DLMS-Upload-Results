var request = require('request');
var async = require('async');
var uuid = require('node-uuid');
var url = 'http://localhost:6009/v1/results';

var accessToken = 'bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI0ZjhhYjIxOS0xMzRmLTQwOGItYmE5Yi00ODJhNDRjZWVlMTAiLCJzdWIiOiI0MjcxMTA1ZS00OWJjLTRkN2QtYThkMS0zNjRhYzk1OTVkOGMiLCJzY29wZSI6WyJjbG91ZF9jb250cm9sbGVyLnJlYWQiLCJwYXNzd29yZC53cml0ZSIsImNsb3VkX2NvbnRyb2xsZXIud3JpdGUiLCJvcGVuaWQiXSwiY2xpZW50X2lkIjoiY2YiLCJjaWQiOiJjZiIsImF6cCI6ImNmIiwiZ3JhbnRfdHlwZSI6InBhc3N3b3JkIiwidXNlcl9pZCI6IjQyNzExMDVlLTQ5YmMtNGQ3ZC1hOGQxLTM2NGFjOTU5NWQ4YyIsIm9yaWdpbiI6InVhYSIsInVzZXJfbmFtZSI6InZqZWdhc2VAdXMuaWJtLmNvbSIsImVtYWlsIjoidmplZ2FzZUB1cy5pYm0uY29tIiwicmV2X3NpZyI6ImUzZWVjZWY4IiwiaWF0IjoxNDc2MTk3OTc5LCJleHAiOjE0Nzc0MDc1NzksImlzcyI6Imh0dHBzOi8vdWFhLnN0YWdlMS5uZy5ibHVlbWl4Lm5ldC9vYXV0aC90b2tlbiIsInppZCI6InVhYSIsImF1ZCI6WyJjbG91ZF9jb250cm9sbGVyIiwicGFzc3dvcmQiLCJjZiIsIm9wZW5pZCJdfQ.7QPt37T2xODocYKj6PhyrpNtm32Lx-p8-SdSGywqr5M';

var d = new Date();
var isotime = d.toJSON();

var builds = [];
for (var i = 15; i >= 0; i--) {
    builds.push(i);
}

var total_execution_time = 0;
var average_execution_time = 0;

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

        var etime = Math.floor((Math.random() * 200) + 1);
        var stime = Math.floor((Math.random() * 150) + 1);
        while (stime > etime) {
            stime = stime - etime;
        }
        var saucelabscontents = [{
            consolidated_status: 'passed',
            end_time: etime,
            start_time: stime
        }, {
            consolidated_status: 'passed',
            end_time: etime,
            start_time: stime
        }, {
            consolidated_status: 'complete',
            end_time: etime,
            start_time: stime
        }, {
            consolidated_status: 'failed',
            end_time: etime,
            start_time: stime
        }, {
            consolidated_status: 'failed',
            end_time: etime,
            start_time: stime
        }, {}];

        var buff = new Buffer(JSON.stringify(mochacontents));
        var base64mochacontents = buff.toString('base64');
        buff = new Buffer(JSON.stringify(istanbulcontents));
        var base64istanbulcontents = buff.toString('base64');
        buff = new Buffer(JSON.stringify(saucelabscontents));
        var base64saucelabscontents = buff.toString('base64');

        var testresult = {};
        testresult.org_name = 'vjegase@us.ibm.com';
        testresult.project_name = 'Test-Insights-Tab';
        testresult.environment_name = 'MASTER-BUILD';
        testresult.runtime_name = 'Test-Insights-Tab';
        testresult.module_name = 'Test-Insights-Tab';
        testresult.build_id = 'Master:' + a;
    //testresult.build_id = 'Master:' + uuid.v4();
        testresult.timestamp = isotime;
        testresult.lifecycle_stage = 'unittest';
        testresult.url = ['www.github.com', 'www.saucelabs.com', 'newrelic.org'];
        testresult.artifact_name = 'mochatest.json';
        testresult.description = 'Unit test using Mocha.';
        testresult.contents_type = 'application/json';
        testresult.contents = base64mochacontents;

        d.setDate(d.getDate() - 1);
        isotime = d.toJSON();

        var start = new Date().getTime();
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
                    console.log("MOCHA Post %s for build:", body.status, testresult.build_id);
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
                    }, function(err, resp, body) {
                        if (err) {
                            console.log("Process failed with error:", err);
                            callback(err, null);
                        } else {
                            console.log("ISTANBUL Post %s for build:", body.status, testresult.build_id);
                            testresult.lifecycle_stage = 'fvt';
                            testresult.artifact_name = 'saucelabstest.json';
                            testresult.contents_type = 'application/json';
                            testresult.contents = base64saucelabscontents;
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
                                    console.log("SAUCELABS Post %s for build:", body.status, testresult.build_id);
                                    var end = new Date().getTime();
                                    var time = end - start;
                                    total_execution_time += time;
                                    console.log('Execution time for build %s: %s',testresult.build_id,time);
                                    console.log("---------------------------------------------");
                                    callback(null, body);
                                }
                            });
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
            console.log("Error:", error);
        } else {
            console.log("Average time:", total_execution_time/builds.length);
        }

    });

