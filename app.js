// Generated by CoffeeScript 1.7.1
(function() {
  var PAGE_URL, cheerio, freakOut, moment, request, twilio;

  request = require('request');

  cheerio = require('cheerio');

  moment = require('moment');

  twilio = require('twilio')();

  PAGE_URL = 'https://www.peco.com/CustomerService/OutageCenter/OutageMap/Pages/CountyDetails.aspx?County=Montgomery';

  freakOut = function() {
    return request(PAGE_URL, function(err, res, body) {
      var $, lm_affected, lm_percent, lm_served, now, total_affected, total_percent, total_served;
      if (err) {
        console.log(err);
        return;
      }
      $ = cheerio.load(body);
      total_affected = 0;
      total_served = 0;
      lm_affected = 0;
      lm_served = 0;
      $('tr', '#outageMapTownshipInformation').slice(3).each(function(num, el) {
        var num_affected, num_served, region, tr;
        tr = $(el);
        region = $(tr.children()[0]).text();
        num_affected = Number($(tr.children()[1]).text().replace(/,/g, ''));
        num_served = Number($($(tr.children()[2])).text().replace(/,/g, ''));
        if (isNaN(num_affected)) {
          num_affected = 5;
        }
        total_affected = total_affected + num_affected;
        total_served = total_served + num_served;
        if (region === "LOWER MORELAND TWP") {
          lm_affected = num_affected;
          lm_served = num_served;
        }
        return console.log("" + region + ": " + num_affected + "/" + num_served);
      });
      now = moment().zone("-05:00").format("M/D/YY @ h:mm:ss a");
      total_percent = ((1 - (total_affected / total_served)) * 100).toFixed(2);
      lm_percent = ((1 - (lm_affected / lm_served)) * 100).toFixed(2);
      return twilio.sendMessage({
        to: "+1" + process.env.TARGET_TEL,
        from: '+14842706601',
        body: "PECO outage status for " + now + ": Montgomery county " + total_percent + "% operational (" + total_affected + "/" + total_served + "), Lower Moreland: " + lm_percent + "% operational (" + lm_affected + "/" + lm_served + ")"
      }, function(err, res) {
        return console.log(err);
      });
    });
  };

  freakOut();

  setInterval(freakOut, 900 * 1000);

}).call(this);
