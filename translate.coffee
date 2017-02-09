# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   trans 文字列

request = require 'request'
DOMParser = require('xmldom').DOMParser
API_KEY = process.env.HUBOT_TRANSLATOR_KEY


module.exports = (robot) ->
  robot.hear /trans (.*)/i, (msg) ->
    keyword = encodeURIComponent msg.match[1]
    url = 'https://api.cognitive.microsoft.com/sts/v1.0/issueToken'
    options =
      url: url
      timeout: 2000
      headers: {'Content-Type': 'application/json', 'Accept': 'application/jwt', 'Ocp-Apim-Subscription-Key': API_KEY}
      method: 'POST'

    request options, (error, response, body) ->
      if response.statusCode == 200
        trans_url = 'https://api.microsofttranslator.com/v2/http.svc/Translate?appid=Bearer ' + body + '&text=' + keyword + '&from=ja&to=en&contentType=text/html'
        trans_options =
          url: trans_url
          timeout: 2000
          headers: {'Accept': 'application/xml'}
          method: 'GET'
        request trans_options, (trans_error, trans_response, trans_body) ->
          if trans_response.statusCode == 200
            doc = new DOMParser().parseFromString(trans_body, "application/xml")
            string = doc.getElementsByTagName("string")
            msg.send string[0].childNodes[0].nodeValue
