request = require('request')
cheerio = require('cheerio')

PAGE_URL = 'https://www.peco.com/CustomerService/OutageCenter/OutageMap/Pages/CountyDetails.aspx?County=Montgomery'

client = require('twilio')('AC74e399cdf24846d2e3d65600fff56782', '8b7fd2f5cafc3f9982470d0fa5fb24c2')

`String.prototype.getNums= function(){
    var rx=/[+-]?((\.\d+)|(\d+(\.\d+)?)([eE][+-]?\d+)?)/g,
    mapN= this.match(rx) || [];
    return mapN.map(Number);
};`

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
      num_affected_raw = $(tr.children()[1]).text()
      num_served_raw = $($(tr.children()[2])).text()
      num_affected = "" + num_affected_raw.getNums()[0]
      if num_affected_raw.getNums().length > 1
        num_served = num_affected + num_affected.getNums()[1]
      num_served = "" + num_served_raw.getNums()[0]
      if num_served_raw.getNums().length > 1
        num_served = num_served + num_served_raw.getNums()[1]
      total_affected = total_affected + Number(num_affected)
      total_served = total_served + Number(num_served)
      if region is "LOWER MERION TWP"
        lm_affected = Number(num_affected)
        lm_served = Number(num_served)
      console.log("#{region}: #{num_affected}/#{num_served}")
    now = new Date()
    console.log lm_affected
    console.log lm_served
    total_percent = (total_affected / total_served) * 100
    lm_percent = (lm_affected / lm_served) * 100
    msg = "#{now} Report for Montgomery county: #{total_affected}/#{total_served} (#{total_percent}) Lower Merion: #{lm_affected}/#{lm_served} (#{lm_percent})"
    client.sendMessage(
      {
        to: '+14844316296',
        from: '+14842706601',
        body: msg
      }, (err, res) ->
        console.log err
    )

freakOut()
setInterval(freakOut, 10000)