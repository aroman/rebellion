request = require 'request'
cheerio = require 'cheerio'
moment = require 'moment'
twilio = require('twilio')()

PAGE_URL = 'https://www.peco.com/CustomerService/OutageCenter/OutageMap/Pages/CountyDetails.aspx?County=Montgomery'

freakOut = ->
  request PAGE_URL, (err, res, body) ->
    if err
      console.log err
      return
    $ = cheerio.load body
    total_affected = 0
    total_served = 0
    lm_affected = 0
    lm_served = 0
    $('tr', '#outageMapTownshipInformation')[3..].each (num, el) ->
      tr = $(el)
      region = $(tr.children()[0]).text()
      num_affected = Number($(tr.children()[1]).text().replace(/,/g, ''))
      num_served = Number($($(tr.children()[2])).text().replace(/,/g, ''))
      if isNaN(num_affected) # Edge case for text being "less than 5"
        num_affected = 5
      total_affected = total_affected + num_affected
      total_served = total_served + num_served
      if region is "LOWER MERION TWP"
        lm_affected = num_affected
        lm_served = num_served
      console.log("#{region}: #{num_affected}/#{num_served}")
    now = moment().zone("-05:00").format("M/D/YY @ h:mm:ss a")
    total_percent = ((1 - (total_affected / total_served)) * 100).toFixed(2)
    lm_percent = ((1 - (lm_affected / lm_served)) * 100).toFixed(2)
    twilio.sendMessage(
      {
        to: "+1#{process.env.TARGET_TEL}",
        from: '+14842706601',
        body: "PECO outage status for #{now}: Montgomery county #{total_percent}% operational (#{total_affected}/#{total_served}), Lower Merion: #{lm_percent}% operational (#{lm_affected}/#{lm_served})"
      }, (err, res) ->
        console.log err
    )

freakOut()
setInterval(freakOut, 900 * 1000) # 15 minutes